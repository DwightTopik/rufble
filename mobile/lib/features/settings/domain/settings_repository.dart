import 'package:rufble/features/settings/domain/app_settings.dart';

/// Reactive access to the single-row settings. Emits [AppSettings.defaults]
/// until the user has saved anything.
abstract interface class SettingsRepository {
  Stream<AppSettings> watch();

  Future<void> update(AppSettings settings);
}
