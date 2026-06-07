import 'package:drift/drift.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/core/enums/currency.dart';
import 'package:rufble/core/enums/goal_status.dart';
import 'package:rufble/features/goals/domain/goal.dart';

/// Row ↔ domain mapping for goals. Enum TEXT ↔ Dart enum lives here so the
/// domain layer stays free of Drift and persistence concerns.
extension GoalRowMapper on GoalRow {
  Goal toDomain() => Goal(
        id: id,
        emoji: emoji,
        name: name,
        targetAmount: targetAmount,
        saved: saved,
        currency: Currency.fromName(currency),
        status: GoalStatus.fromName(status),
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        note: note,
        color: color,
        imagePath: imagePath,
        deadline: deadline,
        completedAt: completedAt,
        deletedAt: deletedAt,
      );
}

extension GoalCompanionMapper on Goal {
  /// Full companion for upsert. Excludes [Goal.saved] is intentional elsewhere;
  /// here we include it because the goals repository never recomputes saved —
  /// saveGoal preserves whatever the caller passed (typically an unchanged
  /// value loaded from the same store).
  GoalsCompanion toCompanion() => GoalsCompanion(
        id: Value(id),
        emoji: Value(emoji),
        name: Value(name),
        targetAmount: Value(targetAmount),
        saved: Value(saved),
        currency: Value(currency.name),
        status: Value(status.name),
        sortOrder: Value(sortOrder),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        note: Value(note),
        color: Value(color),
        imagePath: Value(imagePath),
        deadline: Value(deadline),
        completedAt: Value(completedAt),
        deletedAt: Value(deletedAt),
      );
}
