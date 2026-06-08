import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/constants/goal_palette.dart';
import 'package:rufble/core/di/id_provider.dart';
import 'package:rufble/core/di/repository_providers.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';
import 'package:rufble/core/widgets/app_modal_sheet.dart';
import 'package:rufble/core/widgets/emoji_picker_sheet.dart';
import 'package:rufble/core/widgets/form_fields.dart';
import 'package:rufble/features/goals/domain/tag.dart';
import 'package:rufble/features/goals/presentation/goals_providers.dart';

/// Shows the tag management sheet (create / edit / delete tags).
Future<void> showTagsManagementSheet(BuildContext context) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => const TagsManagementSheet(),
  );
}

class TagsManagementSheet extends ConsumerWidget {
  const TagsManagementSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final tags = ref.watch(allTagsProvider).value ?? const <Tag>[];

    return AppModalSheet(
      title: 'Tags',
      trailing: GestureDetector(
        onTap: () => showTagEditorSheet(context),
        child: Icon(CupertinoIcons.add_circled_solid,
            color: theme.primary, size: AppDimensions.iconLg),
      ),
      child: tags.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppDimensions.xxl),
              child: Text(
                'No tags yet. Tap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SFProText',
                  fontSize: 15,
                  color: theme.text2,
                  decoration: TextDecoration.none,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.sm,
                AppDimensions.base,
                AppDimensions.xl,
              ),
              itemCount: tags.length,
              itemBuilder: (context, i) => _TagRow(tag: tags[i]),
            ),
    );
  }
}

class _TagRow extends ConsumerWidget {
  const _TagRow({required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    return GestureDetector(
      onTap: () => showTagEditorSheet(context, existing: tag),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: theme.elevated,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: AppDimensions.iconLg,
              height: AppDimensions.iconLg,
              decoration: BoxDecoration(
                color: GoalPalette.fromHex(tag.color),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            if (tag.emoji != null) ...[
              Text(tag.emoji!,
                  style: const TextStyle(
                    fontFamily: 'AppleColorEmoji',
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  )),
              const SizedBox(width: AppDimensions.sm),
            ],
            Expanded(
              child: Text(
                tag.name,
                style: TextStyle(
                  fontFamily: 'SFProText',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: theme.text1,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  ref.read(tagsRepositoryProvider).softDeleteTag(tag.id),
              child: Icon(CupertinoIcons.delete,
                  size: AppDimensions.iconMd, color: theme.error),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the create/edit tag sheet. Pass [existing] to edit.
Future<void> showTagEditorSheet(BuildContext context, {Tag? existing}) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => _TagEditorSheet(existing: existing),
  );
}

class _TagEditorSheet extends ConsumerStatefulWidget {
  const _TagEditorSheet({this.existing});

  final Tag? existing;

  @override
  ConsumerState<_TagEditorSheet> createState() => _TagEditorSheetState();
}

class _TagEditorSheetState extends ConsumerState<_TagEditorSheet> {
  late final TextEditingController _nameCtrl;
  String? _emoji;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _emoji = widget.existing?.emoji;
    _color = GoalPalette.fromHex(widget.existing?.color);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEmoji() async {
    final picked = await showEmojiPickerSheet(context);
    if (picked != null) setState(() => _emoji = picked);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final now = DateTime.now();
    final existing = widget.existing;
    final tag = Tag(
      id: existing?.id ?? ref.read(idGeneratorProvider)(),
      name: name,
      emoji: _emoji,
      color: GoalPalette.toHex(_color),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    await ref.read(tagsRepositoryProvider).saveTag(tag);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return AppModalSheet(
      title: widget.existing == null ? 'New tag' : 'Edit tag',
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
            Row(
              children: [
                GestureDetector(
                  onTap: _pickEmoji,
                  child: Container(
                    width: AppDimensions.emojiButtonSize,
                    height: AppDimensions.emojiButtonSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.elevated,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: theme.border),
                    ),
                    child: Text(
                      _emoji ?? '🏷️',
                      style: const TextStyle(
                        fontFamily: 'AppleColorEmoji',
                        fontSize: 28,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.base),
                Expanded(
                  child: AppTextField(
                    controller: _nameCtrl,
                    placeholder: 'Tag name',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            FormSection(
              label: 'Color',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final color in GoalPalette.swatches)
                    GestureDetector(
                      onTap: () => setState(() => _color = color),
                      child: Container(
                        width: AppDimensions.colorSwatchSize,
                        height: AppDimensions.colorSwatchSize,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.toARGB32() == _color.toARGB32()
                                ? CupertinoColors.white
                                : CupertinoColors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            AppPrimaryButton(label: 'Save', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
