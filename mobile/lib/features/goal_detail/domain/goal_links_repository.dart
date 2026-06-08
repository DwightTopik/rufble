import 'package:rufble/features/goal_detail/domain/goal_link.dart';

/// Reactive access to a goal's external links. Reads exclude soft-deleted rows.
abstract interface class GoalLinksRepository {
  /// Non-deleted links for [goalId], ordered by [GoalLink.sortOrder].
  Stream<List<GoalLink>> watchForGoal(String goalId);

  /// Non-deleted links for [goalId] as a one-shot read.
  Future<List<GoalLink>> getForGoal(String goalId);

  /// Inserts or updates [link] (upsert by id).
  Future<void> saveLink(GoalLink link);

  /// Soft-deletes a link.
  Future<void> softDeleteLink(String id);
}
