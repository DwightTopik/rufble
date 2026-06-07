import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    _TabItem(label: 'Goals', icon: CupertinoIcons.home, path: '/goals'),
    _TabItem(label: 'Archive', icon: CupertinoIcons.archivebox, path: '/archive'),
    _TabItem(label: 'Stats', icon: CupertinoIcons.chart_bar, path: '/stats'),
    _TabItem(label: 'Settings', icon: CupertinoIcons.settings, path: '/settings'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final currentIndex = _currentIndex(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.bg,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: AppDimensions.bottomNavHeight +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: child,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomNavBar(
              tabs: _tabs,
              currentIndex: currentIndex,
              onTap: (i) => context.go(_tabs[i].path),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    required this.theme,
  });

  final List<_TabItem> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppThemeExtension theme;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: AppDimensions.bottomNavHeight + bottomPadding,
      decoration: BoxDecoration(
        color: theme.surface.withAlpha(230),
        border: Border(
          top: BorderSide(color: theme.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _NavItem(
                  item: tabs[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                  theme: theme,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;
  final AppThemeExtension theme;

  @override
  Widget build(BuildContext context) {
    final color = selected ? theme.primary : theme.text3;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: AppDimensions.bottomNavHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: AppDimensions.iconLg, color: color),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'SFProText',
                fontSize: 10,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;
}
