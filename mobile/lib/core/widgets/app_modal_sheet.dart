import 'package:flutter/cupertino.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';

/// A reusable rounded modal-sheet container with a drag handle and a title row.
/// Content is provided by [child]; the sheet caps its height at
/// [AppDimensions.sheetMaxHeightFactor] of the screen and lets [child] scroll.
class AppModalSheet extends StatelessWidget {
  const AppModalSheet({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final media = MediaQuery.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: media.size.height * AppDimensions.sheetMaxHeightFactor,
      ),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimensions.sm),
            _Handle(color: theme.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.base,
                AppDimensions.md,
                AppDimensions.base,
                AppDimensions.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'SFProDisplay',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: theme.text1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.sheetHandleWidth,
      height: AppDimensions.sheetHandleHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
    );
  }
}
