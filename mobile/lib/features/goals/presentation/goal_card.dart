import 'dart:io';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/constants/app_durations.dart';
import 'package:rufble/core/constants/goal_palette.dart';
import 'package:rufble/core/enums/currency.dart';
import 'package:rufble/core/enums/goal_status.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';
import 'package:rufble/core/utils/money.dart';
import 'package:rufble/core/widgets/goal_progress_bar.dart';
import 'package:rufble/features/goal_detail/domain/goal_link.dart';
import 'package:rufble/features/goals/domain/goal.dart';
import 'package:rufble/features/goals/domain/tag.dart';
import 'package:rufble/features/goals/presentation/goals_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// A single goal card: photo or emoji anchor, name, progress, amounts, optional
/// deadline hint, tag + link chips, and quick-deposit presets.
class GoalCard extends ConsumerWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.presets,
    required this.onTap,
    required this.onMenu,
    required this.onPresetDeposit,
    required this.onAddPressed,
  });

  final Goal goal;

  /// Quick-deposit preset amounts in RUB minor units (from settings).
  final List<int> presets;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  /// Called with a preset amount (minor units) when a quick chip is tapped.
  final void Function(int amountMinor) onPresetDeposit;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final accent = GoalPalette.fromHex(goal.color);
    final isPaused = goal.status == GoalStatus.paused;

    final tags = ref.watch(goalTagsProvider(goal.id)).value ?? const <Tag>[];
    final links =
        ref.watch(goalLinksProvider(goal.id)).value ?? const <GoalLink>[];

    final card = Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: theme.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (goal.imagePath != null)
            _CardImage(path: goal.imagePath!)
          else
            _EmojiAnchor(emoji: goal.emoji, accent: accent),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderRow(
                  goal: goal,
                  isPaused: isPaused,
                  onMenu: onMenu,
                ),
                const SizedBox(height: AppDimensions.md),
                _AmountBlock(goal: goal, accent: accent),
                const SizedBox(height: AppDimensions.md),
                GoalProgressBar(
                  progress: progressFraction(goal.saved, goal.targetAmount),
                  color: accent,
                  trackColor: theme.elevated,
                  height: AppDimensions.progressBarHeight,
                ),
                if (goal.deadline != null) ...[
                  const SizedBox(height: AppDimensions.sm),
                  _DeadlineHint(goal: goal),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.md),
                  _TagChips(tags: tags),
                ],
                if (links.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.sm),
                  _LinkChips(links: links),
                ],
                const SizedBox(height: AppDimensions.md),
                _PresetRow(
                  presets: presets,
                  accent: accent,
                  onPresetDeposit: onPresetDeposit,
                  onAddPressed: onAddPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      onLongPress: onMenu,
      child: Opacity(opacity: isPaused ? 0.55 : 1, child: card),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.cardImageHeight,
      width: double.infinity,
      child: Image.file(File(path), fit: BoxFit.cover),
    );
  }
}

class _EmojiAnchor extends StatelessWidget {
  const _EmojiAnchor({required this.emoji, required this.accent});

  final String emoji;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
      decoration: BoxDecoration(
        color: accent.withAlpha(20),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: const TextStyle(
          fontFamily: 'AppleColorEmoji',
          fontSize: AppDimensions.cardEmojiSize,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.goal,
    required this.isPaused,
    required this.onMenu,
  });

  final Goal goal;
  final bool isPaused;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (goal.imagePath != null) ...[
          Text(
            goal.emoji,
            style: const TextStyle(
              fontFamily: 'AppleColorEmoji',
              fontSize: 22,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
        Expanded(
          child: Text(
            goal.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SFProText',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: theme.text1,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        if (isPaused) const _PausedBadge(),
        GestureDetector(
          onTap: onMenu,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: AppDimensions.sm),
            child: Icon(
              CupertinoIcons.ellipsis,
              size: AppDimensions.iconMd,
              color: theme.text2,
            ),
          ),
        ),
      ],
    );
  }
}

class _PausedBadge extends StatelessWidget {
  const _PausedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: theme.warning.withAlpha(40),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        'Paused',
        style: TextStyle(
          fontFamily: 'SFProText',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: theme.warning,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _AmountBlock extends StatelessWidget {
  const _AmountBlock({required this.goal, required this.accent});

  final Goal goal;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final pct = progressPercent(goal.saved, goal.targetAmount);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saved amount with slot-machine roll on change.
              _MoneyFlip(
                minor: goal.saved,
                currency: goal.currency,
                size: 22,
                weight: FontWeight.w700,
                color: theme.text1,
              ),
              const SizedBox(height: AppDimensions.xs),
              Text(
                'of ${formatAmount(goal.targetAmount, goal.currency)}',
                style: TextStyle(
                  fontFamily: 'SpaceMono',
                  fontSize: 13,
                  color: theme.text1.withAlpha(115), // ~0.45 opacity
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
        AnimatedFlipCounter(
          value: pct,
          suffix: '%',
          duration: AppDurations.normal,
          textStyle: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: accent,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

/// Money value rendered with an [AnimatedFlipCounter] for the digit roll while
/// keeping the symbol/grouping from [formatAmount]. The counter animates the
/// integer minor value; the prefix carries the currency symbol.
class _MoneyFlip extends StatelessWidget {
  const _MoneyFlip({
    required this.minor,
    required this.currency,
    required this.size,
    required this.weight,
    required this.color,
  });

  final int minor;
  final Currency currency;
  final double size;
  final FontWeight weight;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'SpaceMono',
      fontSize: size,
      fontWeight: weight,
      color: color,
      decoration: TextDecoration.none,
    );
    final major = minor.abs() ~/ 100;
    final frac = minor.abs() % 100;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('${minor < 0 ? '−' : ''}${currency.symbol} ', style: style),
        AnimatedFlipCounter(
          value: major,
          thousandSeparator: ' ',
          duration: AppDurations.normal,
          textStyle: style,
        ),
        if (frac != 0)
          Text('.${frac.toString().padLeft(2, '0')}', style: style),
      ],
    );
  }
}

class _DeadlineHint extends StatelessWidget {
  const _DeadlineHint({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final deadline = goal.deadline!;
    final remaining = goal.targetAmount - goal.saved;
    final monthsLeft = _monthsUntil(deadline);
    // Required monthly contribution — integer ceil division, no double.
    final perMonth = (remaining > 0 && monthsLeft > 0)
        ? (remaining + monthsLeft - 1) ~/ monthsLeft
        : 0;

    final dateLabel = _formatDate(deadline);
    return Row(
      children: [
        Icon(
          CupertinoIcons.calendar,
          size: AppDimensions.iconSm,
          color: theme.text2,
        ),
        const SizedBox(width: AppDimensions.xs),
        Expanded(
          child: Text(
            perMonth > 0
                ? '$dateLabel · ${formatAmount(perMonth, goal.currency)}/мес'
                : dateLabel,
            style: TextStyle(
              fontFamily: 'SFProText',
              fontSize: 12,
              color: theme.text2,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// Whole months between now and [deadline], at least 0.
int _monthsUntil(DateTime deadline) {
  final now = DateTime.now();
  final months =
      (deadline.year - now.year) * 12 + (deadline.month - now.month);
  return months < 0 ? 0 : months;
}

String _formatDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd.$mm.${d.year}';
}

class _TagChips extends StatelessWidget {
  const _TagChips({required this.tags});

  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: AppDimensions.xs,
            ),
            decoration: BoxDecoration(
              color: GoalPalette.fromHex(tag.color).withAlpha(28),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tag.emoji != null) ...[
                  Text(
                    tag.emoji!,
                    style: const TextStyle(
                      fontFamily: 'AppleColorEmoji',
                      fontSize: 12,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                ],
                Text(
                  tag.name,
                  style: TextStyle(
                    fontFamily: 'SFProText',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.text1,
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

class _LinkChips extends StatelessWidget {
  const _LinkChips({required this.links});

  final List<GoalLink> links;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.sm,
      children: [
        for (final link in links)
          GestureDetector(
            onTap: () => _openLink(link.url),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sm,
                vertical: AppDimensions.xs,
              ),
              decoration: BoxDecoration(
                color: theme.blue.withAlpha(24),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.link,
                    size: 12,
                    color: theme.blue,
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    link.title ?? _hostOf(link.url),
                    style: TextStyle(
                      fontFamily: 'SFProText',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.blue,
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

String _hostOf(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return url;
  return uri.host.replaceFirst('www.', '');
}

Future<void> _openLink(String url) async {
  var normalized = url.trim();
  if (!normalized.startsWith('http://') &&
      !normalized.startsWith('https://')) {
    normalized = 'https://$normalized';
  }
  final uri = Uri.tryParse(normalized);
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.presets,
    required this.accent,
    required this.onPresetDeposit,
    required this.onAddPressed,
  });

  final List<int> presets;
  final Color accent;
  final void Function(int amountMinor) onPresetDeposit;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (presets.isEmpty) const Spacer(),
        for (final preset in presets) ...[
          Expanded(
            child: _PresetButton(
              label: '+${formatAmount(preset, Currency.rub)}',
              accent: accent,
              onPressed: () => onPresetDeposit(preset),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
        ],
        GestureDetector(
          onTap: onAddPressed,
          child: Container(
            height: AppDimensions.presetButtonHeight,
            width: AppDimensions.presetButtonHeight,
            decoration: BoxDecoration(
              color: accent.withAlpha(28),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              CupertinoIcons.add,
              size: AppDimensions.iconMd,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.accent,
    required this.onPressed,
  });

  final String label;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: AppDimensions.presetButtonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: accent.withAlpha(20),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: accent,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
