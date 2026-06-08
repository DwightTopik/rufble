import 'package:flutter/cupertino.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';

/// A labelled section wrapper used inside form sheets — a small caption above
/// its [child].
class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'SFProText',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.text2,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// A themed text input matching the sheet styling. Wraps [CupertinoTextField]
/// with the app's surface/border tokens.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.placeholder,
    this.keyboardType,
    this.maxLines = 1,
    this.prefix,
    this.style,
    this.onChanged,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController controller;
  final String? placeholder;
  final TextInputType? keyboardType;
  final int maxLines;
  final Widget? prefix;
  final TextStyle? style;
  final ValueChanged<String>? onChanged;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      textAlign: textAlign,
      prefix: prefix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: AppDimensions.md),
              child: prefix,
            ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.md,
      ),
      placeholderStyle: TextStyle(
        fontFamily: 'SFProText',
        color: theme.text3,
        decoration: TextDecoration.none,
      ),
      style: style ??
          TextStyle(
            fontFamily: 'SFProText',
            fontSize: 16,
            color: theme.text1,
            decoration: TextDecoration.none,
          ),
      decoration: BoxDecoration(
        color: theme.elevated,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: theme.border, width: 1),
      ),
    );
  }
}

/// A full-width primary action button (filled with [color]).
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final bg = color ?? theme.primary;
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        height: AppDimensions.minTapTarget + AppDimensions.sm,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? bg : bg.withAlpha(90),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'SFProText',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
