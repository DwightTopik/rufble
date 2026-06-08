import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/constants/app_colors.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';
import 'package:rufble/features/deposit/presentation/deposit_sheet.dart';
import 'package:rufble/features/goals/domain/goal.dart';
import 'package:rufble/features/goals/presentation/goal_actions.dart';
import 'package:rufble/features/goals/presentation/goal_card.dart';
import 'package:rufble/features/goals/presentation/goal_form_sheet.dart';
import 'package:rufble/features/goals/presentation/goals_providers.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final goalsAsync = ref.watch(activeGoalsProvider);
    final presets =
        ref.watch(appSettingsProvider).value?.presets ?? const <int>[];

    return CupertinoPageScaffold(
      backgroundColor: theme.bg,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Rufble'),
        backgroundColor: theme.bg.withAlpha(200),
        border: null,
      ),
      child: Stack(
        children: [
          goalsAsync.when(
            data: (goals) => goals.isEmpty
                ? const _EmptyState()
                : _GoalsList(goals: goals, presets: presets),
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (e, _) => _ErrorState(message: '$e'),
          ),
          Positioned(
            right: AppDimensions.base,
            bottom: AppDimensions.base,
            child: _Fab(onPressed: () => showGoalFormSheet(context)),
          ),
        ],
      ),
    );
  }
}

class _GoalsList extends ConsumerWidget {
  const _GoalsList({required this.goals, required this.presets});

  final List<Goal> goals;
  final List<int> presets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.base,
        AppDimensions.base,
        AppDimensions.base,
        // Leave room for the FAB at the bottom of the scroll.
        AppDimensions.xxxl + AppDimensions.fabSize,
      ),
      itemCount: goals.length,
      itemBuilder: (context, i) {
        final goal = goals[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.cardSpacing),
          child: GoalCard(
            goal: goal,
            // Presets are stored in RUB minor units; only show them on RUB
            // goals so the amount matches the goal's currency.
            presets: goal.currency.name == 'rub' ? presets : const [],
            onTap: () => showDepositSheet(context, goal),
            onMenu: () => showGoalContextMenu(context, ref, goal),
            onAddPressed: () => showDepositSheet(context, goal),
            onPresetDeposit: (amount) =>
                performPresetDeposit(context, ref, goal, amount),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🎯',
            style: TextStyle(
              fontFamily: 'AppleColorEmoji',
              fontSize: 64,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: AppDimensions.base),
          Text(
            'No goals yet',
            style: TextStyle(
              fontFamily: 'SFProText',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: theme.text1,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Tap + to create your first goal',
            style: TextStyle(
              fontFamily: 'SFProText',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: theme.text2,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Text(
          'Could not load goals.\n$message',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SFProText',
            fontSize: 15,
            color: theme.error,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  const _Fab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: AppDimensions.fabSize,
        height: AppDimensions.fabSize,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.add,
          color: CupertinoColors.white,
          size: AppDimensions.fabIconSize,
        ),
      ),
    );
  }
}
