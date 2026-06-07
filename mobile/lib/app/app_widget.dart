import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rufble/core/router/app_router.dart';
import 'package:rufble/core/theme/app_cupertino_theme.dart';

class AppWidget extends ConsumerStatefulWidget {
  const AppWidget({super.key, this.skipSplashDelay = false});

  /// When true, removes the native splash immediately instead of after the
  /// brand-reveal delay. Used by widget tests so no [Timer] is left pending
  /// when the tree is disposed.
  final bool skipSplashDelay;

  @override
  ConsumerState<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends ConsumerState<AppWidget> {
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    if (widget.skipSplashDelay) {
      FlutterNativeSplash.remove();
    } else {
      _splashTimer = Timer(const Duration(milliseconds: 350), _removeSplash);
    }
  }

  void _removeSplash() {
    if (!mounted) return;
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    // Cancel a still-pending reveal timer so it can't fire post-dispose and so
    // the test framework doesn't flag a pending timer.
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: 'SFProText',
        decoration: TextDecoration.none,
      ),
      child: MaterialApp.router(
        title: 'Rufble',
        debugShowCheckedModeBanner: false,
        theme: buildThemeData(isDark: false),
        routerConfig: appRouter,
      ),
    );
  }
}
