import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rufble/core/database/app_database.dart';
import 'package:rufble/features/settings/domain/app_settings.dart';
import 'package:rufble/features/settings/domain/settings_repository.dart';

/// Drift-backed [SettingsRepository] over the single settings row (id 0).
/// Emits [AppSettings.defaults] when the row is absent.
class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  static const _rowId = 0;
  final AppDatabase _db;

  @override
  Stream<AppSettings> watch() {
    final query = _db.select(_db.settingsTable)
      ..where((s) => s.id.equals(_rowId));
    return query.watchSingleOrNull().map(
          (row) => row == null ? AppSettings.defaults : _toDomain(row),
        );
  }

  @override
  Future<void> update(AppSettings settings) =>
      _db.into(_db.settingsTable).insertOnConflictUpdate(
            SettingsTableCompanion(
              id: const Value(_rowId),
              presets: Value(jsonEncode(settings.presets)),
              theme: Value(settings.theme),
              defaultReminderTime: Value(settings.defaultReminderTime),
            ),
          );

  AppSettings _toDomain(SettingsRow row) {
    final decoded = jsonDecode(row.presets) as List<dynamic>;
    return AppSettings(
      presets: decoded.cast<int>(),
      theme: row.theme,
      defaultReminderTime: row.defaultReminderTime,
    );
  }
}
