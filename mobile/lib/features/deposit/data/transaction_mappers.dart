import 'package:drift/drift.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/core/enums/transaction_type.dart';
import 'package:rufble/features/deposit/domain/transaction_entry.dart';

/// Row ↔ domain mapping for transactions.
extension TransactionRowMapper on TransactionRow {
  TransactionEntry toDomain() => TransactionEntry(
        id: id,
        goalId: goalId,
        type: TransactionType.fromName(type),
        amount: amount,
        counterpartGoalId: counterpartGoalId,
        note: note,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}

extension TransactionCompanionMapper on TransactionEntry {
  TransactionsCompanion toCompanion() => TransactionsCompanion(
        id: Value(id),
        goalId: Value(goalId),
        type: Value(type.name),
        amount: Value(amount),
        counterpartGoalId: Value(counterpartGoalId),
        note: Value(note),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
      );
}
