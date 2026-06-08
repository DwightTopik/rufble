import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/di/id_provider.dart';
import 'package:rufble/core/di/repository_providers.dart';
import 'package:rufble/core/enums/goal_status.dart';
import 'package:rufble/core/enums/transaction_type.dart';
import 'package:rufble/features/deposit/domain/transaction_entry.dart';
import 'package:rufble/features/deposit/presentation/transaction_history_sheet.dart';
import 'package:rufble/features/goals/domain/goal.dart';
import 'package:rufble/features/goals/presentation/goal_form_sheet.dart';

/// Shows the goal context menu (edit / pause-resume / history / write-off /
/// delete) as a Cupertino action sheet for [goal].
Future<void> showGoalContextMenu(
  BuildContext context,
  WidgetRef ref,
  Goal goal,
) async {
  final isPaused = goal.status == GoalStatus.paused;
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) => CupertinoActionSheet(
      title: Text(goal.name),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(sheetContext).pop();
            showGoalFormSheet(context, existing: goal);
          },
          child: const Text('Edit'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(sheetContext).pop();
            showTransactionHistorySheet(context, goal);
          },
          child: const Text('History'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(sheetContext).pop();
            _togglePause(ref, goal);
          },
          child: Text(isPaused ? 'Resume' : 'Pause'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(sheetContext).pop();
            _confirmWriteOff(context, ref, goal);
          },
          child: const Text('Write off'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(sheetContext).pop();
            _confirmDelete(context, ref, goal);
          },
          child: const Text('Delete'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(sheetContext).pop(),
        child: const Text('Cancel'),
      ),
    ),
  );
}

Future<void> _togglePause(WidgetRef ref, Goal goal) {
  final next =
      goal.status == GoalStatus.paused ? GoalStatus.active : GoalStatus.paused;
  return ref.read(goalsRepositoryProvider).saveGoal(
        goal.copyWith(status: next, updatedAt: DateTime.now()),
      );
}

Future<void> _confirmWriteOff(
  BuildContext context,
  WidgetRef ref,
  Goal goal,
) async {
  final confirmed = await _confirmDialog(
    context,
    title: 'Write off goal?',
    message:
        'All saved funds will be recorded as written off and the goal moves to '
        'the archive as cancelled.',
    confirmLabel: 'Write off',
    destructive: true,
  );
  if (!confirmed) return;

  final goalsRepo = ref.read(goalsRepositoryProvider);
  final txRepo = ref.read(transactionsRepositoryProvider);
  final now = DateTime.now();

  // Record the full saved balance as a write-off so saved nets to zero, then
  // mark the goal cancelled. Skip the transaction when nothing is saved.
  if (goal.saved > 0) {
    await txRepo.addTransaction(
      TransactionEntry(
        id: ref.read(idGeneratorProvider)(),
        goalId: goal.id,
        type: TransactionType.writeOff,
        amount: goal.saved,
        note: 'Write-off',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
  // Reload to pick up the recalculated saved (now 0) before flipping status.
  final refreshed = await goalsRepo.getById(goal.id) ?? goal;
  await goalsRepo.saveGoal(
    refreshed.copyWith(
      status: GoalStatus.cancelled,
      completedAt: now,
      updatedAt: now,
    ),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Goal goal,
) async {
  final confirmed = await _confirmDialog(
    context,
    title: 'Delete goal?',
    message: 'This goal and its history will be removed.',
    confirmLabel: 'Delete',
    destructive: true,
  );
  if (!confirmed) return;
  await ref.read(goalsRepositoryProvider).softDeleteGoal(goal.id);
}

Future<bool> _confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (dialogContext) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(message),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: destructive,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
