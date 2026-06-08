import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rufble/core/constants/app_dimensions.dart';
import 'package:rufble/core/constants/app_durations.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';

/// Shows a transient bottom snackbar with an "Undo" action over the root
/// overlay. The bar auto-dismisses after [AppDurations.undoWindow]; tapping
/// "Undo" runs [onUndo] and dismisses immediately. Safe to call repeatedly —
/// each call replaces any visible bar.
void showUndoSnackbar(
  BuildContext context, {
  required String message,
  required FutureOr<void> Function() onUndo,
}) {
  _UndoController.instance.show(context, message: message, onUndo: onUndo);
}

class _UndoController {
  _UndoController._();
  static final instance = _UndoController._();

  OverlayEntry? _entry;
  Timer? _timer;

  void show(
    BuildContext context, {
    required String message,
    required FutureOr<void> Function() onUndo,
  }) {
    _dismiss();
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (context) => _UndoBar(
        message: message,
        onUndo: () async {
          _dismiss();
          await onUndo();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(AppDurations.undoWindow, _dismiss);
  }

  void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _UndoBar extends StatelessWidget {
  const _UndoBar({required this.message, required this.onUndo});

  final String message;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final media = MediaQuery.of(context);
    return Positioned(
      left: AppDimensions.base,
      right: AppDimensions.base,
      bottom: media.padding.bottom +
          AppDimensions.bottomNavHeight +
          AppDimensions.base,
      child: _SlideIn(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.base,
            vertical: AppDimensions.md,
          ),
          decoration: BoxDecoration(
            color: theme.text1,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            boxShadow: [
              BoxShadow(
                color: const Color(0x33000000),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'SFProText',
                    fontSize: 14,
                    color: theme.bg,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onUndo,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.base),
                  child: Text(
                    'Undo',
                    style: TextStyle(
                      fontFamily: 'SFProText',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.primaryLight,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Slides the snackbar up from below with a fade on first build.
class _SlideIn extends StatefulWidget {
  const _SlideIn({required this.child});

  final Widget child;

  @override
  State<_SlideIn> createState() => _SlideInState();
}

class _SlideInState extends State<_SlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppDurations.snackbarSlide,
  )..forward();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.5),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}
