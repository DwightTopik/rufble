import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/di/database_providers.dart';
import 'package:rufble/features/deposit/data/drift_transactions_repository.dart';
import 'package:rufble/features/deposit/domain/transactions_repository.dart';
import 'package:rufble/features/goals/data/drift_goals_repository.dart';
import 'package:rufble/features/goals/data/drift_tags_repository.dart';
import 'package:rufble/features/goals/domain/goals_repository.dart';
import 'package:rufble/features/goals/domain/tags_repository.dart';
import 'package:rufble/features/settings/data/drift_exchange_rates_repository.dart';
import 'package:rufble/features/settings/data/drift_settings_repository.dart';
import 'package:rufble/features/settings/domain/exchange_rates_repository.dart';
import 'package:rufble/features/settings/domain/settings_repository.dart';

/// Repository providers — the seam between the UI/state layer and Drift. All
/// depend on [appDatabaseProvider]; swap these in tests via overrides.

final goalsRepositoryProvider = Provider<GoalsRepository>(
  (ref) => DriftGoalsRepository(ref.watch(appDatabaseProvider)),
);

final transactionsRepositoryProvider = Provider<TransactionsRepository>(
  (ref) => DriftTransactionsRepository(ref.watch(appDatabaseProvider)),
);

final tagsRepositoryProvider = Provider<TagsRepository>(
  (ref) => DriftTagsRepository(ref.watch(appDatabaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(appDatabaseProvider)),
);

final exchangeRatesRepositoryProvider = Provider<ExchangeRatesRepository>(
  (ref) => DriftExchangeRatesRepository(ref.watch(appDatabaseProvider)),
);
