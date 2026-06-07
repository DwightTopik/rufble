import 'package:rufble/core/enums/goal_status.dart';
import 'package:rufble/features/goals/domain/goal.dart';

/// Reactive access to goals. UI watches Drift-backed streams; all reads exclude
/// soft-deleted rows.
abstract interface class GoalsRepository {
  /// Active goals only, ordered by [Goal.sortOrder].
  Stream<List<Goal>> watchActiveGoals();

  /// Goals with the given [status], ordered by [Goal.sortOrder].
  Stream<List<Goal>> watchByStatus(GoalStatus status);

  /// Single goal by id, or null if missing/soft-deleted.
  Future<Goal?> getById(String id);

  /// Inserts or updates [goal] (upsert by id). Does not touch [Goal.saved];
  /// that is owned by transaction mutations / recalculation.
  Future<void> saveGoal(Goal goal);

  /// Soft-deletes a goal (sets `deleted_at`), keeping it for Phase 2 sync.
  Future<void> softDeleteGoal(String id);

  /// Rewrites [Goal.sortOrder] to match the given id order.
  Future<void> reorderGoals(List<String> orderedIds);
}
