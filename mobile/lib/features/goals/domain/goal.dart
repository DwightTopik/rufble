import 'package:rufble/core/enums/currency.dart';
import 'package:rufble/core/enums/goal_status.dart';

/// Domain model for a savings goal. Plain Dart, decoupled from Drift rows.
///
/// [targetAmount] and [saved] are `int` minor units of [currency].
class Goal {
  const Goal({
    required this.id,
    required this.emoji,
    required this.name,
    required this.targetAmount,
    required this.saved,
    required this.currency,
    required this.status,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.note,
    this.color,
    this.imagePath,
    this.deadline,
    this.completedAt,
    this.deletedAt,
  });

  final String id;
  final String emoji;
  final String name;
  final int targetAmount;
  final int saved;
  final Currency currency;
  final GoalStatus status;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;
  final String? color;
  final String? imagePath;
  final DateTime? deadline;
  final DateTime? completedAt;
  final DateTime? deletedAt;

  Goal copyWith({
    String? id,
    String? emoji,
    String? name,
    int? targetAmount,
    int? saved,
    Currency? currency,
    GoalStatus? status,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,
    String? color,
    String? imagePath,
    DateTime? deadline,
    DateTime? completedAt,
    DateTime? deletedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      saved: saved ?? this.saved,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      deadline: deadline ?? this.deadline,
      completedAt: completedAt ?? this.completedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
