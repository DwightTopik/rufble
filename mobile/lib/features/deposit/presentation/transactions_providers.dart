import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/di/repository_providers.dart';
import 'package:rufble/features/deposit/domain/transaction_entry.dart';

/// Transaction history for a goal, newest first.
final goalTransactionsProvider =
    StreamProvider.family<List<TransactionEntry>, String>(
  (ref, goalId) =>
      ref.watch(transactionsRepositoryProvider).watchByGoal(goalId),
);
