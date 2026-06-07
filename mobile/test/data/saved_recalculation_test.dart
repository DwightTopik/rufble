import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/core/enums/currency.dart';
import 'package:rufble/core/enums/goal_status.dart';
import 'package:rufble/core/enums/transaction_type.dart';
import 'package:rufble/features/deposit/data/drift_transactions_repository.dart';
import 'package:rufble/features/deposit/domain/transaction_entry.dart';
import 'package:rufble/features/goals/data/drift_goals_repository.dart';
import 'package:rufble/features/goals/domain/goal.dart';

void main() {
  late AppDatabase db;
  late DriftGoalsRepository goals;
  late DriftTransactionsRepository transactions;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    goals = DriftGoalsRepository(db);
    transactions = DriftTransactionsRepository(db);
  });

  tearDown(() => db.close());

  Goal makeGoal() {
    final now = DateTime(2026, 6, 8);
    return Goal(
      id: 'goal-1',
      emoji: '🎯',
      name: 'New phone',
      targetAmount: 5000000, // 50 000 ₽
      saved: 0,
      currency: Currency.rub,
      status: GoalStatus.active,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  TransactionEntry tx(
    String id,
    TransactionType type,
    int amount,
  ) {
    final now = DateTime(2026, 6, 8);
    return TransactionEntry(
      id: id,
      goalId: 'goal-1',
      type: type,
      amount: amount,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('saved is recalculated after a deposit', () async {
    await goals.saveGoal(makeGoal());

    await transactions
        .addTransaction(tx('tx-1', TransactionType.deposit, 150000));

    final goal = await goals.getById('goal-1');
    expect(goal!.saved, 150000);
  });

  test('saved nets credits and debits across transaction types', () async {
    await goals.saveGoal(makeGoal());

    await transactions
        .addTransaction(tx('tx-1', TransactionType.deposit, 200000));
    await transactions
        .addTransaction(tx('tx-2', TransactionType.transferIn, 50000));
    await transactions
        .addTransaction(tx('tx-3', TransactionType.withdrawal, 30000));
    await transactions
        .addTransaction(tx('tx-4', TransactionType.writeOff, 20000));

    // 200000 + 50000 - 30000 - 20000 = 200000
    final goal = await goals.getById('goal-1');
    expect(goal!.saved, 200000);
  });

  test('soft-deleting a transaction excludes it from saved', () async {
    await goals.saveGoal(makeGoal());
    await transactions
        .addTransaction(tx('tx-1', TransactionType.deposit, 100000));
    await transactions
        .addTransaction(tx('tx-2', TransactionType.deposit, 40000));

    await transactions.softDeleteTransaction('tx-2');

    final goal = await goals.getById('goal-1');
    expect(goal!.saved, 100000);
  });
}
