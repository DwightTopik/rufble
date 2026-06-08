import 'package:drift/drift.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/features/goal_detail/domain/goal_link.dart';
import 'package:rufble/features/goal_detail/domain/goal_links_repository.dart';

/// Drift-backed [GoalLinksRepository]. All reads exclude soft-deleted rows.
class DriftGoalLinksRepository implements GoalLinksRepository {
  DriftGoalLinksRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<GoalLink>> watchForGoal(String goalId) =>
      _query(goalId).watch().map((rows) => rows.map(_toDomain).toList());

  @override
  Future<List<GoalLink>> getForGoal(String goalId) async =>
      (await _query(goalId).get()).map(_toDomain).toList();

  @override
  Future<void> saveLink(GoalLink link) =>
      _db.into(_db.goalLinks).insertOnConflictUpdate(
            GoalLinksCompanion(
              id: Value(link.id),
              goalId: Value(link.goalId),
              url: Value(link.url),
              title: Value(link.title),
              sortOrder: Value(link.sortOrder),
              createdAt: Value(link.createdAt),
              updatedAt: Value(link.updatedAt),
              deletedAt: Value(link.deletedAt),
            ),
          );

  @override
  Future<void> softDeleteLink(String id) {
    final now = DateTime.now();
    return (_db.update(_db.goalLinks)..where((l) => l.id.equals(id))).write(
      GoalLinksCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  SimpleSelectStatement<$GoalLinksTable, GoalLinkRow> _query(String goalId) =>
      _db.select(_db.goalLinks)
        ..where((l) => l.goalId.equals(goalId) & l.deletedAt.isNull())
        ..orderBy([(l) => OrderingTerm.asc(l.sortOrder)]);

  GoalLink _toDomain(GoalLinkRow row) => GoalLink(
        id: row.id,
        goalId: row.goalId,
        url: row.url,
        title: row.title,
        sortOrder: row.sortOrder,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        deletedAt: row.deletedAt,
      );
}
