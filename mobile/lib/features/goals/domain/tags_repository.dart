import 'package:rufble/features/goals/domain/tag.dart';

/// Reactive access to tags and goal↔tag assignments.
abstract interface class TagsRepository {
  /// All non-deleted tags, ordered by name.
  Stream<List<Tag>> watchAll();

  /// Tags assigned to [goalId].
  Stream<List<Tag>> watchForGoal(String goalId);

  /// Inserts or updates [tag] (upsert by id).
  Future<void> saveTag(Tag tag);

  /// Soft-deletes a tag and removes its goal assignments.
  Future<void> softDeleteTag(String id);

  /// Assigns [tagId] to [goalId] (no-op if already assigned).
  Future<void> assignTag(String goalId, String tagId);

  /// Removes the [tagId] assignment from [goalId].
  Future<void> removeTag(String goalId, String tagId);
}
