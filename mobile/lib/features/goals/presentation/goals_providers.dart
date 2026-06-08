import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/di/repository_providers.dart';
import 'package:rufble/features/goal_detail/domain/goal_link.dart';
import 'package:rufble/features/goals/domain/goal.dart';
import 'package:rufble/features/goals/domain/tag.dart';
import 'package:rufble/features/settings/domain/app_settings.dart';

/// Stream of active goals for the list screen.
final activeGoalsProvider = StreamProvider<List<Goal>>(
  (ref) => ref.watch(goalsRepositoryProvider).watchActiveGoals(),
);

/// Tags assigned to a specific goal (for chip rows on the card).
final goalTagsProvider = StreamProvider.family<List<Tag>, String>(
  (ref, goalId) => ref.watch(tagsRepositoryProvider).watchForGoal(goalId),
);

/// Links attached to a specific goal (for chip rows on the card).
final goalLinksProvider = StreamProvider.family<List<GoalLink>, String>(
  (ref, goalId) => ref.watch(goalLinksRepositoryProvider).watchForGoal(goalId),
);

/// All tags (for the create/edit multi-select and the management sheet).
final allTagsProvider = StreamProvider<List<Tag>>(
  (ref) => ref.watch(tagsRepositoryProvider).watchAll(),
);

/// App settings stream (quick-deposit presets live here).
final appSettingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);
