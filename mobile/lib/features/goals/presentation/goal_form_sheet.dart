import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rufble/core/enums/transaction_type.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/constants/goal_palette.dart';
import 'package:rufble/core/di/id_provider.dart';
import 'package:rufble/core/di/repository_providers.dart';
import 'package:rufble/core/enums/currency.dart';
import 'package:rufble/core/enums/goal_status.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';
import 'package:rufble/core/utils/money.dart';
import 'package:rufble/core/widgets/app_modal_sheet.dart';
import 'package:rufble/core/widgets/emoji_picker_sheet.dart';
import 'package:rufble/core/widgets/form_fields.dart';
import 'package:rufble/features/deposit/domain/transaction_entry.dart';
import 'package:rufble/features/goal_detail/domain/goal_link.dart';
import 'package:rufble/features/goals/domain/goal.dart';
import 'package:rufble/features/goals/domain/tag.dart';
import 'package:rufble/features/goals/presentation/goals_providers.dart';

/// Shows the create/edit goal modal sheet. Pass [existing] to edit an existing
/// goal, or null to create a new one.
Future<void> showGoalFormSheet(
  BuildContext context, {
  Goal? existing,
}) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => GoalFormSheet(existing: existing),
  );
}

class GoalFormSheet extends ConsumerStatefulWidget {
  const GoalFormSheet({super.key, this.existing});

  final Goal? existing;

  @override
  ConsumerState<GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<GoalFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _targetCtrl;
  late final TextEditingController _savedCtrl;
  late final TextEditingController _noteCtrl;

  String _emoji = '🎯';
  Currency _currency = Currency.rub;
  String? _imagePath;
  DateTime? _deadline;
  Color _color = GoalPalette.fallback;
  final Set<String> _selectedTagIds = {};

  /// Working list of links (id, url, title). Persisted on save.
  final List<_LinkDraft> _links = [];

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _nameCtrl = TextEditingController(text: g?.name ?? '');
    _targetCtrl = TextEditingController(
      text: g == null ? '' : _toEditText(g.targetAmount),
    );
    _savedCtrl = TextEditingController();
    _noteCtrl = TextEditingController(text: g?.note ?? '');
    if (g != null) {
      _emoji = g.emoji;
      _currency = g.currency;
      _imagePath = g.imagePath;
      _deadline = g.deadline;
      _color = GoalPalette.fromHex(g.color);
    }
    if (_isEditing) {
      _hydrateAssociations();
    }
  }

  Future<void> _hydrateAssociations() async {
    final goalId = widget.existing!.id;
    final tags = await ref
        .read(tagsRepositoryProvider)
        .watchForGoal(goalId)
        .first;
    final links =
        await ref.read(goalLinksRepositoryProvider).getForGoal(goalId);
    if (!mounted) return;
    setState(() {
      _selectedTagIds
        ..clear()
        ..addAll(tags.map((t) => t.id));
      _links
        ..clear()
        ..addAll(links.map((l) => _LinkDraft(l.id, l.url, l.title)));
    });
  }

  /// Minor units → plain editable text (no symbol, `.` decimal only if needed).
  String _toEditText(int minor) {
    final major = minor ~/ 100;
    final frac = minor % 100;
    return frac == 0 ? '$major' : '$major.${frac.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _savedCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEmoji() async {
    final picked = await showEmojiPickerSheet(context);
    if (picked != null) setState(() => _emoji = picked);
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file != null) setState(() => _imagePath = file.path);
  }

  Future<void> _pickDeadline() async {
    DateTime temp = _deadline ?? DateTime.now().add(const Duration(days: 90));
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => _DatePickerSheet(
        initial: temp,
        onChanged: (d) => temp = d,
        onDone: () {
          setState(() => _deadline = temp);
          Navigator.of(context).pop();
        },
        onClear: () {
          setState(() => _deadline = null);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _toggleTag(String id) {
    setState(() {
      if (!_selectedTagIds.remove(id)) _selectedTagIds.add(id);
    });
  }

  Future<void> _addLink() async {
    final draft = await showCupertinoModalPopup<_LinkDraft>(
      context: context,
      builder: (_) => const _LinkEditorSheet(),
    );
    if (draft != null) {
      final id = ref.read(idGeneratorProvider)();
      setState(() => _links.add(draft.copyWithId(id)));
    }
  }

  bool get _canSave {
    final target = parseToMinor(_targetCtrl.text, _currency);
    return _nameCtrl.text.trim().isNotEmpty && target != null && target > 0;
  }

  Future<void> _save() async {
    final target = parseToMinor(_targetCtrl.text, _currency);
    if (target == null || target <= 0) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;

    final newId = ref.read(idGeneratorProvider)();
    final now = DateTime.now();
    final existing = widget.existing;

    final goal = Goal(
      id: existing?.id ?? newId,
      emoji: _emoji,
      name: name,
      targetAmount: target,
      saved: existing?.saved ?? 0,
      currency: _currency,
      status: existing?.status ?? GoalStatus.active,
      sortOrder: existing?.sortOrder ?? _nextSortOrder(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      color: GoalPalette.toHex(_color),
      imagePath: _imagePath,
      deadline: _deadline,
      completedAt: existing?.completedAt,
    );

    final goalsRepo = ref.read(goalsRepositoryProvider);
    final tagsRepo = ref.read(tagsRepositoryProvider);
    final linksRepo = ref.read(goalLinksRepositoryProvider);
    final txRepo = ref.read(transactionsRepositoryProvider);
    final idGen = ref.read(idGeneratorProvider);

    await goalsRepo.saveGoal(goal);

    // Sync tag assignments (diff against current).
    final current = (await tagsRepo.watchForGoal(goal.id).first)
        .map((t) => t.id)
        .toSet();
    for (final id in _selectedTagIds.difference(current)) {
      await tagsRepo.assignTag(goal.id, id);
    }
    for (final id in current.difference(_selectedTagIds)) {
      await tagsRepo.removeTag(goal.id, id);
    }

    // Persist links: upsert drafts, soft-delete removed ones.
    final existingLinks = await linksRepo.getForGoal(goal.id);
    final draftIds = _links.map((l) => l.id).toSet();
    for (final l in existingLinks) {
      if (!draftIds.contains(l.id)) {
        await linksRepo.softDeleteLink(l.id);
      }
    }
    for (var i = 0; i < _links.length; i++) {
      final d = _links[i];
      await linksRepo.saveLink(
        GoalLink(
          id: d.id,
          goalId: goal.id,
          url: d.url,
          title: d.title,
          sortOrder: i,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Optional opening balance — only on create, recorded as a real deposit so
    // the transactions table stays the source of truth for `saved`.
    if (!_isEditing) {
      final opening = parseToMinor(_savedCtrl.text, _currency);
      if (opening != null && opening > 0) {
        await txRepo.addTransaction(
          _openingDeposit(idGen(), goal.id, opening, now),
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  int _nextSortOrder() {
    final goals = ref.read(activeGoalsProvider).value ?? const [];
    if (goals.isEmpty) return 0;
    return goals.map((g) => g.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final allTags = ref.watch(allTagsProvider).value ?? const <Tag>[];

    return AppModalSheet(
      title: _isEditing ? 'Edit goal' : 'New goal',
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
          _EmojiPhotoRow(
            emoji: _emoji,
            imagePath: _imagePath,
            onPickEmoji: _pickEmoji,
            onPickPhoto: _pickPhoto,
            onRemovePhoto: () => setState(() => _imagePath = null),
          ),
          const SizedBox(height: AppDimensions.lg),
          FormSection(
            label: 'Name',
            child: AppTextField(
              controller: _nameCtrl,
              placeholder: 'e.g. New phone',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: AppDimensions.base),
          FormSection(
            label: 'Currency',
            child: _CurrencySelector(
              selected: _currency,
              onChanged: (c) => setState(() => _currency = c),
            ),
          ),
          const SizedBox(height: AppDimensions.base),
          FormSection(
            label: 'Target amount',
            child: AppTextField(
              controller: _targetCtrl,
              placeholder: '0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefix: Text(
                _currency.symbol,
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
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (!_isEditing) ...[
            const SizedBox(height: AppDimensions.base),
            FormSection(
              label: 'Already saved (optional)',
              child: AppTextField(
                controller: _savedCtrl,
                placeholder: '0',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefix: Text(
                  _currency.symbol,
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
          ],
          const SizedBox(height: AppDimensions.base),
          FormSection(
            label: 'Color',
            child: _ColorSelector(
              selected: _color,
              onChanged: (c) => setState(() => _color = c),
            ),
          ),
          const SizedBox(height: AppDimensions.base),
          FormSection(
            label: 'Deadline (optional)',
            child: _DeadlineField(
              deadline: _deadline,
              onTap: _pickDeadline,
              onClear: () => setState(() => _deadline = null),
            ),
          ),
          if (allTags.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.base),
            FormSection(
              label: 'Tags',
              child: _TagSelector(
                tags: allTags,
                selectedIds: _selectedTagIds,
                onToggle: _toggleTag,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.base),
          FormSection(
            label: 'Links',
            child: _LinksEditor(
              links: _links,
              onAdd: _addLink,
              onRemove: (id) =>
                  setState(() => _links.removeWhere((l) => l.id == id)),
            ),
          ),
          const SizedBox(height: AppDimensions.base),
          FormSection(
            label: 'Notes',
            child: AppTextField(
              controller: _noteCtrl,
              placeholder: 'Optional note',
              maxLines: 3,
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          AppPrimaryButton(
            label: _isEditing ? 'Save changes' : 'Create goal',
            color: _color,
            enabled: _canSave,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

/// An opening-balance deposit recorded on create so the transactions table
/// stays the single source of truth for `saved`.
TransactionEntry _openingDeposit(
  String id,
  String goalId,
  int amount,
  DateTime now,
) =>
    TransactionEntry(
      id: id,
      goalId: goalId,
      type: TransactionType.deposit,
      amount: amount,
      note: 'Opening balance',
      createdAt: now,
      updatedAt: now,
    );

class _LinkDraft {
  const _LinkDraft(this.id, this.url, this.title);

  final String id;
  final String url;
  final String? title;

  _LinkDraft copyWithId(String id) => _LinkDraft(id, url, title);
}

class _EmojiPhotoRow extends StatelessWidget {
  const _EmojiPhotoRow({
    required this.emoji,
    required this.imagePath,
    required this.onPickEmoji,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  final String emoji;
  final String? imagePath;
  final VoidCallback onPickEmoji;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPickEmoji,
          child: Container(
            width: AppDimensions.emojiButtonSize,
            height: AppDimensions.emojiButtonSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.elevated,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: theme.border),
            ),
            child: Text(
              emoji,
              style: const TextStyle(
                fontFamily: 'AppleColorEmoji',
                fontSize: 32,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.base),
        Expanded(
          child: imagePath == null
              ? GestureDetector(
                  onTap: onPickPhoto,
                  child: Container(
                    height: AppDimensions.emojiButtonSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.elevated,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.photo,
                            size: AppDimensions.iconMd, color: theme.text2),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          'Add photo',
                          style: TextStyle(
                            fontFamily: 'SFProText',
                            fontSize: 14,
                            color: theme.text2,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _PhotoPreview(path: imagePath!, onRemove: onRemovePhoto),
        ),
      ],
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Stack(
        children: [
          SizedBox(
            height: AppDimensions.photoPreviewHeight,
            width: double.infinity,
            child: Image.file(File(path), fit: BoxFit.cover),
          ),
          Positioned(
            top: AppDimensions.sm,
            right: AppDimensions.sm,
            child: GestureDetector(
              onTap: onRemove,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0x8C000000),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.xs),
                  child: Icon(CupertinoIcons.xmark,
                      size: AppDimensions.iconSm,
                      color: CupertinoColors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({required this.selected, required this.onChanged});

  final Currency selected;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Row(
      children: [
        for (final c in Currency.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(c),
              child: Container(
                height: AppDimensions.chipHeight + AppDimensions.sm,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c == selected ? theme.primary : theme.elevated,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: c == selected ? theme.primary : theme.border,
                  ),
                ),
                child: Text(
                  '${c.symbol} ${c.name.toUpperCase()}',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c == selected
                        ? CupertinoColors.white
                        : theme.text1,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
          if (c != Currency.values.last)
            const SizedBox(width: AppDimensions.sm),
        ],
      ],
    );
  }
}

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({required this.selected, required this.onChanged});

  final Color selected;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final color in GoalPalette.swatches)
          GestureDetector(
            onTap: () => onChanged(color),
            child: Container(
              width: AppDimensions.colorSwatchSize,
              height: AppDimensions.colorSwatchSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.toARGB32() == selected.toARGB32()
                      ? CupertinoColors.white
                      : CupertinoColors.transparent,
                  width: 3,
                ),
                boxShadow: color.toARGB32() == selected.toARGB32()
                    ? [
                        BoxShadow(
                          color: color.withAlpha(120),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _DeadlineField extends StatelessWidget {
  const _DeadlineField({
    required this.deadline,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? deadline;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppDimensions.minTapTarget + AppDimensions.xs,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        decoration: BoxDecoration(
          color: theme.elevated,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.calendar,
                size: AppDimensions.iconMd, color: theme.text2),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                deadline == null
                    ? 'No deadline'
                    : '${deadline!.day.toString().padLeft(2, '0')}.'
                        '${deadline!.month.toString().padLeft(2, '0')}.'
                        '${deadline!.year}',
                style: TextStyle(
                  fontFamily: 'SFProText',
                  fontSize: 15,
                  color: deadline == null ? theme.text3 : theme.text1,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            if (deadline != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(CupertinoIcons.clear,
                    size: AppDimensions.iconSm, color: theme.text3),
              ),
          ],
        ),
      ),
    );
  }
}

class _TagSelector extends StatelessWidget {
  const _TagSelector({
    required this.tags,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<Tag> tags;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: [
        for (final tag in tags)
          GestureDetector(
            onTap: () => onToggle(tag.id),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.sm,
              ),
              decoration: BoxDecoration(
                color: selectedIds.contains(tag.id)
                    ? GoalPalette.fromHex(tag.color).withAlpha(40)
                    : theme.elevated,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(
                  color: selectedIds.contains(tag.id)
                      ? GoalPalette.fromHex(tag.color)
                      : theme.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tag.emoji != null) ...[
                    Text(tag.emoji!,
                        style: const TextStyle(
                          fontFamily: 'AppleColorEmoji',
                          fontSize: 13,
                          decoration: TextDecoration.none,
                        )),
                    const SizedBox(width: AppDimensions.xs),
                  ],
                  Text(
                    tag.name,
                    style: TextStyle(
                      fontFamily: 'SFProText',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.text1,
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

class _LinksEditor extends StatelessWidget {
  const _LinksEditor({
    required this.links,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_LinkDraft> links;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.sm,
              ),
              decoration: BoxDecoration(
                color: theme.elevated,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.link,
                      size: AppDimensions.iconSm, color: theme.blue),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Text(
                      link.title ?? link.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'SFProText',
                        fontSize: 14,
                        color: theme.text1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onRemove(link.id),
                    child: Icon(CupertinoIcons.minus_circle,
                        size: AppDimensions.iconMd, color: theme.error),
                  ),
                ],
              ),
            ),
          ),
        GestureDetector(
          onTap: onAdd,
          child: Row(
            children: [
              Icon(CupertinoIcons.add_circled,
                  size: AppDimensions.iconMd, color: theme.blue),
              const SizedBox(width: AppDimensions.sm),
              Text(
                'Add link',
                style: TextStyle(
                  fontFamily: 'SFProText',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.blue,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkEditorSheet extends StatefulWidget {
  const _LinkEditorSheet();

  @override
  State<_LinkEditorSheet> createState() => _LinkEditorSheetState();
}

class _LinkEditorSheetState extends State<_LinkEditorSheet> {
  final _urlCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();

  @override
  void dispose() {
    _urlCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppModalSheet(
      title: 'Add link',
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
              label: 'URL',
              child: AppTextField(
                controller: _urlCtrl,
                placeholder: 'https://...',
                keyboardType: TextInputType.url,
              ),
            ),
            const SizedBox(height: AppDimensions.base),
            FormSection(
              label: 'Title (optional)',
              child: AppTextField(
                controller: _titleCtrl,
                placeholder: 'e.g. Product page',
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            AppPrimaryButton(
              label: 'Add',
              onPressed: () {
                final url = _urlCtrl.text.trim();
                if (url.isEmpty) return;
                final title = _titleCtrl.text.trim();
                Navigator.of(context).pop(
                  _LinkDraft('', url, title.isEmpty ? null : title),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerSheet extends StatelessWidget {
  const _DatePickerSheet({
    required this.initial,
    required this.onChanged,
    required this.onDone,
    required this.onClear,
  });

  final DateTime initial;
  final ValueChanged<DateTime> onChanged;
  final VoidCallback onDone;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onClear,
                  child: Text('Clear',
                      style: TextStyle(color: theme.error, fontSize: 15)),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: onDone,
                  child: Text('Done',
                      style: TextStyle(color: theme.primary, fontSize: 15)),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: initial,
              minimumDate: DateTime.now().subtract(const Duration(days: 1)),
              onDateTimeChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
