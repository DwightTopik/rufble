import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:rufble/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Goals,
    ExchangeRates,
    Tags,
    GoalTags,
    GoalLinks,
    Transactions,
    SettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Test/in-memory constructor — pass a custom executor (e.g. NativeDatabase
  /// .memory()) so tests don't touch disk.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'rufble');
  }
}
