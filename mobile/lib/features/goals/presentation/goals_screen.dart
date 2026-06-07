import 'package:flutter/cupertino.dart';
import 'package:rufble/core/constants/app_colors.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return CupertinoPageScaffold(
      backgroundColor: theme.bg,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Rufble'),
        backgroundColor: theme.bg.withAlpha(200),
        border: null,
      ),
      child: Stack(
        children: [
          const _EmptyState(),
          Positioned(
            right: AppDimensions.base,
            bottom: AppDimensions.base,
            child: _Fab(onPressed: () {}),
          ),
        ],
      ),
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
          Text(
            '🎯',
            style: const TextStyle(
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
