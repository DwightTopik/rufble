import 'package:drift/drift.dart';

/// Drift table definitions for Rufble's local store.
///
/// Conventions (see CLAUDE.md "Data Model"):
/// - All amount columns are `int` minor units (kopecks / cents).
/// - Enums persist as `.name` TEXT — plain [TextColumn]s here, mapped to Dart
///   enums in the repository layer. No Drift enum annotations leak into domain.
/// - Soft-delete via nullable `deleted_at` (tombstones). UI reads filter these
///   out; rows are kept for Phase 2 sync.
/// - Ids are app-generated TEXT (UUID v4) so they survive offline creation and
///   Phase 2 sync without server round-trips.

@DataClassName('GoalRow')
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get emoji => text()();
  TextColumn get name => text()();
  IntColumn get targetAmount => integer()();
  IntColumn get saved => integer().withDefault(const Constant(0))();
  TextColumn get currency => text()();
  TextColumn get note => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ExchangeRateRow')
class ExchangeRates extends Table {
  /// Single-row table — fixed id keeps it to one row.
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// Decimal-string rates (never `double`) — parsed via `Decimal` when used.
  TextColumn get usdToRub => text()();
  TextColumn get eurToRub => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get emoji => text().nullable()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GoalTagRow')
class GoalTags extends Table {
  TextColumn get goalId => text().references(Goals, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {goalId, tagId};
}

@DataClassName('GoalLinkRow')
class GoalLinks extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text().references(Goals, #id)();
  TextColumn get url => text()();
  TextColumn get title => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get goalId =>
      text().references(Goals, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  IntColumn get amount => integer()();
  TextColumn get counterpartGoalId => text()
      .nullable()
      .references(Goals, #id, onDelete: KeyAction.setNull)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingsRow')
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';

  /// Single-row table.
  IntColumn get id => integer().withDefault(const Constant(0))();

  /// JSON-encoded `List<int>` of preset amounts in RUB minor units.
  TextColumn get presets => text()();
  TextColumn get theme => text()();
  TextColumn get defaultReminderTime => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
