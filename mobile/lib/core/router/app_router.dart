import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:rufble/app/app_shell.dart';
import 'package:rufble/features/archive/presentation/archive_screen.dart';
import 'package:rufble/features/auth/presentation/auth_screen.dart';
import 'package:rufble/features/goal_detail/presentation/goal_detail_screen.dart';
import 'package:rufble/features/goals/presentation/goals_screen.dart';
import 'package:rufble/features/settings/presentation/settings_screen.dart';
import 'package:rufble/features/stats/presentation/stats_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/goals',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/goals',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GoalsScreen(),
          ),
          routes: [
            GoRoute(
              path: ':id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => GoalDetailScreen(
                goalId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/archive',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ArchiveScreen(),
          ),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StatsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AuthScreen(),
    ),
  ],
);
