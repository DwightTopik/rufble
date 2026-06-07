import 'package:drift/drift.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/features/goals/domain/tag.dart';
import 'package:rufble/features/goals/domain/tags_repository.dart';

/// Drift-backed [TagsRepository].
class DriftTagsRepository implements TagsRepository {
  DriftTagsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Tag>> watchAll() {
    final query = _db.select(_db.tags)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.name)]);
    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<Tag>> watchForGoal(String goalId) {
    final query = _db.select(_db.tags).join([
      innerJoin(
        _db.goalTags,
        _db.goalTags.tagId.equalsExp(_db.tags.id),
      ),
    ])
      ..where(_db.goalTags.goalId.equals(goalId) & _db.tags.deletedAt.isNull())
      ..orderBy([OrderingTerm.asc(_db.tags.name)]);
    return query.watch().map(
          (rows) => rows.map((r) => _toDomain(r.readTable(_db.tags))).toList(),
        );
  }

  @override
  Future<void> saveTag(Tag tag) => _db.into(_db.tags).insertOnConflictUpdate(
        TagsCompanion(
          id: Value(tag.id),
          emoji: Value(tag.emoji),
          name: Value(tag.name),
          color: Value(tag.color),
          createdAt: Value(tag.createdAt),
          updatedAt: Value(tag.updatedAt),
          deletedAt: Value(tag.deletedAt),
        ),
      );

  @override
  Future<void> softDeleteTag(String id) {
    return _db.transaction(() async {
      final now = DateTime.now();
      await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
        TagsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      // Hard-remove assignments — goal_tags is a pure join table with no
      // history value once the tag is gone.
      await (_db.delete(_db.goalTags)..where((gt) => gt.tagId.equals(id))).go();
    });
  }

  @override
  Future<void> assignTag(String goalId, String tagId) =>
      _db.into(_db.goalTags).insert(
            GoalTagsCompanion.insert(goalId: goalId, tagId: tagId),
            mode: InsertMode.insertOrIgnore,
          );

  @override
  Future<void> removeTag(String goalId, String tagId) =>
      (_db.delete(_db.goalTags)
            ..where((gt) => gt.goalId.equals(goalId) & gt.tagId.equals(tagId)))
          .go();

  Tag _toDomain(TagRow row) => Tag(
        id: row.id,
        name: row.name,
        emoji: row.emoji,
        color: row.color,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );
}
