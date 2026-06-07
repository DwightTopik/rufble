import 'package:drift/drift.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/core/enums/transaction_type.dart';
import 'package:rufble/features/deposit/data/transaction_mappers.dart';
import 'package:rufble/features/deposit/domain/transaction_entry.dart';
import 'package:rufble/features/deposit/domain/transactions_repository.dart';

/// Drift-backed [TransactionsRepository]. Every mutation runs inside a
/// transaction that writes the row and then recomputes the goal's denormalized
/// `saved` from the sum of its non-deleted transactions.
class DriftTransactionsRepository implements TransactionsRepository {
  DriftTransactionsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<TransactionEntry>> watchByGoal(String goalId) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.goalId.equals(goalId) & t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<void> addTransaction(TransactionEntry tx) {
    return _db.transaction(() async {
      await _db
          .into(_db.transactions)
          .insertOnConflictUpdate(tx.toCompanion());
      await recalcSaved(_db, tx.goalId);
    });
  }

  @override
  Future<void> updateTransaction(TransactionEntry tx) {
    return _db.transaction(() async {
      await (_db.update(_db.transactions)..where((t) => t.id.equals(tx.id)))
          .write(tx.toCompanion());
      await recalcSaved(_db, tx.goalId);
    });
  }

  @override
  Future<void> softDeleteTransaction(String id) {
    return _db.transaction(() async {
      final row = await (_db.select(_db.transactions)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;
      final now = DateTime.now();
      await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await recalcSaved(_db, row.goalId);
    });
  }
}

/// Recomputes `goals.saved` for [goalId] from the sum of its non-deleted
/// transactions: credits ([TransactionType.deposit], [TransactionType.transferIn])
/// minus debits (withdrawal, transferOut, writeOff).
///
/// Top-level so it can be reused by the goals/transfer flows and tests. The
/// caller is responsible for wrapping this in a transaction when needed.
Future<void> recalcSaved(AppDatabase db, String goalId) async {
  final rows = await (db.select(db.transactions)
        ..where((t) => t.goalId.equals(goalId) & t.deletedAt.isNull()))
      .get();

  var saved = 0;
  for (final row in rows) {
    final type = TransactionType.fromName(row.type);
    saved += type.isCredit ? row.amount : -row.amount;
  }

  await (db.update(db.goals)..where((g) => g.id.equals(goalId))).write(
    GoalsCompanion(saved: Value(saved), updatedAt: Value(DateTime.now())),
  );
}
