import 'package:flutter/cupertino.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';
import 'package:rufble/features/settings/presentation/tags_management_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return CupertinoPageScaffold(
      backgroundColor: theme.bg,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Settings'),
        backgroundColor: theme.bg.withAlpha(200),
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.base),
          children: [
            _SettingsTile(
              icon: CupertinoIcons.tag,
              label: 'Tags',
              onTap: () => showTagsManagementSheet(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.base),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: AppDimensions.iconMd, color: theme.primary),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'SFProText',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.text1,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Icon(CupertinoIcons.chevron_right,
                size: AppDimensions.iconSm, color: theme.text3),
          ],
        ),
      ),
    );
  }
}
