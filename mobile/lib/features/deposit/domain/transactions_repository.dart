import 'package:rufble/features/deposit/domain/transaction_entry.dart';

/// Reactive access to transactions. Every mutation recomputes the affected
/// goal's denormalized [saved] amount from its non-deleted transactions.
abstract interface class TransactionsRepository {
  /// Non-deleted transactions for [goalId], newest first.
  Stream<List<TransactionEntry>> watchByGoal(String goalId);

  /// Inserts [tx] and recalculates the goal's `saved`.
  Future<void> addTransaction(TransactionEntry tx);

  /// Updates an existing [tx] (e.g. edit amount/note) and recalculates `saved`.
  Future<void> updateTransaction(TransactionEntry tx);

  /// Soft-deletes a transaction and recalculates its goal's `saved`.
  Future<void> softDeleteTransaction(String id);

  /// Moves [amount] minor units from [fromGoalId] to [toGoalId] as one logical
  /// operation: writes a paired `transfer_out` / `transfer_in` (each pointing at
  /// the other goal via `counterpart_goal_id`) and recalculates both goals'
  /// `saved`. [outId] and [inId] are the ids for the two rows.
  ///
  /// Amount is in the **source** goal's currency minor units; cross-currency
  /// transfers are out of scope for Phase 1 (callers restrict to same currency).
  Future<void> transfer({
    required String outId,
    required String inId,
    required String fromGoalId,
    required String toGoalId,
    required int amount,
    String? note,
  });
}
