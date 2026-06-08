import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/di/id_provider.dart';
import 'package:rufble/core/di/repository_providers.dart';
import 'package:rufble/core/enums/transaction_type.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';
import 'package:rufble/core/utils/money.dart';
import 'package:rufble/core/widgets/app_modal_sheet.dart';
import 'package:rufble/core/widgets/form_fields.dart';
import 'package:rufble/core/widgets/undo_snackbar.dart';
import 'package:rufble/features/deposit/domain/transaction_entry.dart';
import 'package:rufble/features/goals/domain/goal.dart';
import 'package:rufble/features/goals/presentation/goals_providers.dart';

/// The kind of movement the deposit sheet is recording.
enum _Mode { deposit, withdrawal, transfer }

/// Shows the deposit/withdrawal/transfer sheet for [goal].
Future<void> showDepositSheet(BuildContext context, Goal goal) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => DepositSheet(goal: goal),
  );
}

/// Records a quick-preset deposit directly (no sheet) and shows the undo
/// snackbar. [amountMinor] is in [goal]'s currency minor units.
Future<void> performPresetDeposit(
  BuildContext context,
  WidgetRef ref,
  Goal goal,
  int amountMinor,
) async {
  final txRepo = ref.read(transactionsRepositoryProvider);
  final id = ref.read(idGeneratorProvider)();
  final now = DateTime.now();
  await txRepo.addTransaction(
    TransactionEntry(
      id: id,
      goalId: goal.id,
      type: TransactionType.deposit,
      amount: amountMinor,
      createdAt: now,
      updatedAt: now,
    ),
  );
  if (!context.mounted) return;
  showUndoSnackbar(
    context,
    message: 'Added ${formatAmount(amountMinor, goal.currency)}',
    onUndo: () => txRepo.softDeleteTransaction(id),
  );
}

class DepositSheet extends ConsumerStatefulWidget {
  const DepositSheet({super.key, required this.goal});

  final Goal goal;

  @override
  ConsumerState<DepositSheet> createState() => _DepositSheetState();
}

class _DepositSheetState extends ConsumerState<DepositSheet> {
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  _Mode _mode = _Mode.deposit;
  Goal? _transferTarget;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _canConfirm {
    final amount = parseToMinor(_amountCtrl.text, widget.goal.currency);
    if (amount == null || amount <= 0) return false;
    if (_mode == _Mode.transfer && _transferTarget == null) return false;
    return true;
  }

  Future<void> _confirm() async {
    final goal = widget.goal;
    final amount = parseToMinor(_amountCtrl.text, goal.currency);
    if (amount == null || amount <= 0) return;
    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
    final txRepo = ref.read(transactionsRepositoryProvider);
    final idGen = ref.read(idGeneratorProvider);
    final now = DateTime.now();

    if (_mode == _Mode.transfer) {
      final target = _transferTarget!;
      final outId = idGen();
      final inId = idGen();
      await txRepo.transfer(
        outId: outId,
        inId: inId,
        fromGoalId: goal.id,
        toGoalId: target.id,
        amount: amount,
        note: note,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showUndoSnackbar(
        context,
        message:
            'Transferred ${formatAmount(amount, goal.currency)} to ${target.name}',
        onUndo: () async {
          await txRepo.softDeleteTransaction(outId);
          await txRepo.softDeleteTransaction(inId);
        },
      );
      return;
    }

    final id = idGen();
    final type =
        _mode == _Mode.deposit ? TransactionType.deposit : TransactionType.withdrawal;
    await txRepo.addTransaction(
      TransactionEntry(
        id: id,
        goalId: goal.id,
        type: type,
        amount: amount,
        note: note,
        createdAt: now,
        updatedAt: now,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    final verb = _mode == _Mode.deposit ? 'Added' : 'Withdrew';
    showUndoSnackbar(
      context,
      message: '$verb ${formatAmount(amount, goal.currency)}',
      onUndo: () => txRepo.softDeleteTransaction(id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final goal = widget.goal;
    // Same-currency goals are the only valid transfer targets in Phase 1.
    final allGoals = ref.watch(activeGoalsProvider).value ?? const <Goal>[];
    final transferTargets = allGoals
        .where((g) => g.id != goal.id && g.currency == goal.currency)
        .toList();

    return AppModalSheet(
      title: goal.name,
      trailing: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Icon(CupertinoIcons.xmark_circle_fill,
            color: theme.text3, size: AppDimensions.iconLg),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.base,
          AppDimensions.sm,
          AppDimensions.base,
          AppDimensions.xl,
        ),
        children: [
          _ModeSelector(
            mode: _mode,
            canTransfer: transferTargets.isNotEmpty,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: AppDimensions.lg),
          FormSection(
            label: 'Amount',
            child: AppTextField(
              controller: _amountCtrl,
              placeholder: '0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              prefix: const SizedBox.shrink(),
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: theme.text1,
                decoration: TextDecoration.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_mode == _Mode.transfer) ...[
            const SizedBox(height: AppDimensions.base),
            FormSection(
              label: 'Transfer to',
              child: _TransferTargetSelector(
                targets: transferTargets,
                selected: _transferTarget,
                onChanged: (g) => setState(() => _transferTarget = g),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.base),
          FormSection(
            label: 'Note (optional)',
            child: AppTextField(
              controller: _noteCtrl,
              placeholder: 'What is this for?',
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          AppPrimaryButton(
            label: switch (_mode) {
              _Mode.deposit => 'Add deposit',
              _Mode.withdrawal => 'Withdraw',
              _Mode.transfer => 'Transfer',
            },
            color: _mode == _Mode.deposit ? theme.primary : theme.warning,
            enabled: _canConfirm,
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({
    required this.mode,
    required this.canTransfer,
    required this.onChanged,
  });

  final _Mode mode;
  final bool canTransfer;
  final ValueChanged<_Mode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final modes = [
      (_Mode.deposit, 'Deposit'),
      (_Mode.withdrawal, 'Withdraw'),
      if (canTransfer) (_Mode.transfer, 'Transfer'),
    ];
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xs),
      decoration: BoxDecoration(
        color: theme.elevated,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          for (final (m, label) in modes)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(m),
                child: Container(
                  height: AppDimensions.chipHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: m == mode ? theme.surface : null,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'SFProText',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: m == mode ? theme.text1 : theme.text2,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TransferTargetSelector extends StatelessWidget {
  const _TransferTargetSelector({
    required this.targets,
    required this.selected,
    required this.onChanged,
  });

  final List<Goal> targets;
  final Goal? selected;
  final ValueChanged<Goal> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: [
        for (final g in targets)
          GestureDetector(
            onTap: () => onChanged(g),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.sm,
              ),
              decoration: BoxDecoration(
                color: g.id == selected?.id ? theme.primary : theme.elevated,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(
                  color: g.id == selected?.id ? theme.primary : theme.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(g.emoji,
                      style: const TextStyle(
                        fontFamily: 'AppleColorEmoji',
                        fontSize: 14,
                        decoration: TextDecoration.none,
                      )),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    g.name,
                    style: TextStyle(
                      fontFamily: 'SFProText',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: g.id == selected?.id
                          ? CupertinoColors.white
                          : theme.text1,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
