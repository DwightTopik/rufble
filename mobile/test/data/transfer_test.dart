import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/core/enums/currency.dart';
import 'package:rufble/core/enums/goal_status.dart';
import 'package:rufble/features/deposit/data/drift_transactions_repository.dart';
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

  Goal makeGoal(String id) {
    final now = DateTime(2026, 6, 8);
    return Goal(
      id: id,
      emoji: '🎯',
      name: 'Goal $id',
      targetAmount: 5000000,
      saved: 0,
      currency: Currency.rub,
      status: GoalStatus.active,
      sortOrder: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  test('transfer moves funds between goals and recalcs both', () async {
    await goals.saveGoal(makeGoal('a'));
    await goals.saveGoal(makeGoal('b'));

    // Seed source with 100 000 ₽ then transfer 30 000 ₽ to the target.
    await transactions.transfer(
      outId: 'seed-out',
      inId: 'seed-in',
      fromGoalId: 'a',
      toGoalId: 'b',
      amount: 3000000,
    );

    final a = await goals.getById('a');
    final b = await goals.getById('b');
    expect(a!.saved, -3000000); // source went negative (no prior deposit)
    expect(b!.saved, 3000000);
  });

  test('undoing both legs of a transfer nets to zero', () async {
    await goals.saveGoal(makeGoal('a'));
    await goals.saveGoal(makeGoal('b'));

    await transactions.transfer(
      outId: 'out-1',
      inId: 'in-1',
      fromGoalId: 'a',
      toGoalId: 'b',
      amount: 1000000,
    );
    await transactions.softDeleteTransaction('out-1');
    await transactions.softDeleteTransaction('in-1');

    expect((await goals.getById('a'))!.saved, 0);
    expect((await goals.getById('b'))!.saved, 0);
  });
}
