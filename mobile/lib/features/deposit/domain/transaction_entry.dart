import 'package:rufble/core/enums/transaction_type.dart';

/// Domain model for a single money movement on a goal.
///
/// [amount] is always a positive `int` in the goal's currency minor units; the
/// sign/direction is carried by [type] (see [TransactionType.isCredit]).
class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.goalId,
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.counterpartGoalId,
    this.note,
    this.deletedAt,
  });

  final String id;
  final String goalId;
  final TransactionType type;
  final int amount;
  final String? counterpartGoalId;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  TransactionEntry copyWith({
    String? id,
    String? goalId,
    TransactionType? type,
    int? amount,
    String? counterpartGoalId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TransactionEntry(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      counterpartGoalId: counterpartGoalId ?? this.counterpartGoalId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
