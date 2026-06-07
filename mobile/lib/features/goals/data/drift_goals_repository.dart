import 'package:drift/drift.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/core/enums/goal_status.dart';
import 'package:rufble/features/goals/data/goal_mappers.dart';
import 'package:rufble/features/goals/domain/goal.dart';
import 'package:rufble/features/goals/domain/goals_repository.dart';

/// Drift-backed [GoalsRepository]. All reads exclude soft-deleted rows.
class DriftGoalsRepository implements GoalsRepository {
  DriftGoalsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Goal>> watchActiveGoals() => watchByStatus(GoalStatus.active);

  @override
  Stream<List<Goal>> watchByStatus(GoalStatus status) {
    final query = _db.select(_db.goals)
      ..where((g) => g.status.equals(status.name) & g.deletedAt.isNull())
      ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]);
    return query.watch().map((rows) => rows.map((r) => r.toDomain()).toList());
  }

  @override
  Future<Goal?> getById(String id) async {
    final row = await (_db.select(_db.goals)
          ..where((g) => g.id.equals(id) & g.deletedAt.isNull()))
        .getSingleOrNull();
    return row?.toDomain();
  }

  @override
  Future<void> saveGoal(Goal goal) =>
      _db.into(_db.goals).insertOnConflictUpdate(goal.toCompanion());

  @override
  Future<void> softDeleteGoal(String id) {
    final now = DateTime.now();
    return (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(
      GoalsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }

  @override
  Future<void> reorderGoals(List<String> orderedIds) {
    final now = DateTime.now();
    return _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.goals)..where((g) => g.id.equals(orderedIds[i])))
            .write(GoalsCompanion(sortOrder: Value(i), updatedAt: Value(now)));
      }
    });
  }
}
