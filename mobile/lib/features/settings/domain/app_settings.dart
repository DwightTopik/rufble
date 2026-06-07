/// Domain model for user settings.
///
/// [presets] are quick-deposit amounts in RUB minor units (kopecks).
class AppSettings {
  const AppSettings({
    required this.presets,
    required this.theme,
    this.defaultReminderTime,
  });

  /// Default settings used on first launch / when the row is missing.
  static const defaults = AppSettings(
    presets: [100000, 500000, 1000000], // 1 000 / 5 000 / 10 000 ₽
    theme: 'system',
  );

  final List<int> presets;
  final String theme;

  /// `HH:mm` 24h string, or null if no default reminder is set.
  final String? defaultReminderTime;

  AppSettings copyWith({
    List<int>? presets,
    String? theme,
    String? defaultReminderTime,
  }) {
    return AppSettings(
      presets: presets ?? this.presets,
      theme: theme ?? this.theme,
      defaultReminderTime: defaultReminderTime ?? this.defaultReminderTime,
    );
  }
}
