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
}
