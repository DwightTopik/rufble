import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/di/repository_providers.dart';
import 'package:rufble/core/enums/transaction_type.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';
import 'package:rufble/core/utils/money.dart';
import 'package:rufble/core/widgets/app_modal_sheet.dart';
import 'package:rufble/core/widgets/form_fields.dart';
import 'package:rufble/core/widgets/undo_snackbar.dart';
import 'package:rufble/features/deposit/domain/transaction_entry.dart';
import 'package:rufble/features/deposit/presentation/transactions_providers.dart';
import 'package:rufble/features/goals/domain/goal.dart';

/// Shows the transaction history for [goal].
Future<void> showTransactionHistorySheet(BuildContext context, Goal goal) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => TransactionHistorySheet(goal: goal),
  );
}

class TransactionHistorySheet extends ConsumerWidget {
  const TransactionHistorySheet({super.key, required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final txs =
        ref.watch(goalTransactionsProvider(goal.id)).value ??
            const <TransactionEntry>[];

    return AppModalSheet(
      title: 'History',
      trailing: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Icon(CupertinoIcons.xmark_circle_fill,
            color: theme.text3, size: AppDimensions.iconLg),
      ),
      child: txs.isEmpty
          ? const _Empty()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.xl,
              ),
              itemCount: txs.length,
              itemBuilder: (context, i) => _TransactionRow(
                tx: txs[i],
                goal: goal,
              ),
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      child: Text(
        'No transactions yet',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'SFProText',
          fontSize: 15,
          color: context.appTheme.text2,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  const _TransactionRow({required this.tx, required this.goal});

  final TransactionEntry tx;
  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final isCredit = tx.type.isCredit;
    final signedColor = isCredit ? theme.primary : theme.warning;

    return Dismissible(
      key: ValueKey(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppDimensions.base),
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        decoration: BoxDecoration(
          color: theme.error,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: const Icon(CupertinoIcons.delete,
            color: CupertinoColors.white, size: AppDimensions.iconMd),
      ),
      onDismissed: (_) async {
        final repo = ref.read(transactionsRepositoryProvider);
        await repo.softDeleteTransaction(tx.id);
        if (!context.mounted) return;
        showUndoSnackbar(
          context,
          message: 'Transaction deleted',
          onUndo: () => repo.updateTransaction(
            tx.copyWith(deletedAt: null, updatedAt: DateTime.now()),
          ),
        );
      },
      child: GestureDetector(
        onLongPress: () => _editTransaction(context, ref),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: theme.elevated,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            children: [
              Icon(_iconFor(tx.type),
                  size: AppDimensions.iconMd, color: signedColor),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _labelFor(tx.type),
                      style: TextStyle(
                        fontFamily: 'SFProText',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.text1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (tx.note != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppDimensions.xs),
                        child: Text(
                          tx.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'SFProText',
                            fontSize: 12,
                            color: theme.text2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.xs),
                      child: Text(
                        _formatDateTime(tx.createdAt),
                        style: TextStyle(
                          fontFamily: 'SFProText',
                          fontSize: 11,
                          color: theme.text3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isCredit ? '+' : '−'}'
                '${formatAmount(tx.amount, goal.currency)}',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: signedColor,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editTransaction(BuildContext context, WidgetRef ref) async {
    // Transfer rows are paired; editing one side would desync the other, so
    // only standalone deposits/withdrawals are editable here.
    if (tx.type == TransactionType.transferIn ||
        tx.type == TransactionType.transferOut) {
      return;
    }
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => _EditTransactionSheet(tx: tx, goal: goal),
    );
  }
}

class _EditTransactionSheet extends ConsumerStatefulWidget {
  const _EditTransactionSheet({required this.tx, required this.goal});

  final TransactionEntry tx;
  final Goal goal;

  @override
  ConsumerState<_EditTransactionSheet> createState() =>
      _EditTransactionSheetState();
}

class _EditTransactionSheetState
    extends ConsumerState<_EditTransactionSheet> {
  late final TextEditingController _amountCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final minor = widget.tx.amount;
    final major = minor ~/ 100;
    final frac = minor % 100;
    _amountCtrl = TextEditingController(
      text: frac == 0 ? '$major' : '$major.${frac.toString().padLeft(2, '0')}',
    );
    _noteCtrl = TextEditingController(text: widget.tx.note ?? '');
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = parseToMinor(_amountCtrl.text, widget.goal.currency);
    if (amount == null || amount <= 0) return;
    final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
    await ref.read(transactionsRepositoryProvider).updateTransaction(
          widget.tx.copyWith(
            amount: amount,
            note: note,
            updatedAt: DateTime.now(),
          ),
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return AppModalSheet(
      title: 'Edit transaction',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.base,
          AppDimensions.sm,
          AppDimensions.base,
          AppDimensions.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FormSection(
              label: 'Amount',
              child: AppTextField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefix: Text(
                  widget.goal.currency.symbol,
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 16,
                    color: theme.text2,
                    decoration: TextDecoration.none,
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 16,
                  color: theme.text1,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.base),
            FormSection(
              label: 'Note (optional)',
              child: AppTextField(controller: _noteCtrl),
            ),
            const SizedBox(height: AppDimensions.xl),
            AppPrimaryButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

IconData _iconFor(TransactionType type) => switch (type) {
      TransactionType.deposit => CupertinoIcons.arrow_down_circle_fill,
      TransactionType.transferIn => CupertinoIcons.arrow_down_left_circle_fill,
      TransactionType.withdrawal => CupertinoIcons.arrow_up_circle_fill,
      TransactionType.transferOut => CupertinoIcons.arrow_up_right_circle_fill,
      TransactionType.writeOff => CupertinoIcons.trash_circle_fill,
    };

String _labelFor(TransactionType type) => switch (type) {
      TransactionType.deposit => 'Deposit',
      TransactionType.transferIn => 'Transfer in',
      TransactionType.withdrawal => 'Withdrawal',
      TransactionType.transferOut => 'Transfer out',
      TransactionType.writeOff => 'Write-off',
    };

String _formatDateTime(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$dd.$mm.${d.year} · $hh:$min';
}
