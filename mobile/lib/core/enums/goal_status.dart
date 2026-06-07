/// Lifecycle status of a goal. Persisted as `.name` TEXT in Drift.
enum GoalStatus {
  active,
  paused,
  completed,
  cancelled;

  /// Parses a persisted `.name` value, falling back to [active] on unknown
  /// input (defensive against legacy/corrupt rows).
  static GoalStatus fromName(String name) => GoalStatus.values.firstWhere(
        (s) => s.name == name,
        orElse: () => GoalStatus.active,
      );
}
