import 'package:flutter/animation.dart';

abstract final class AppDurations {
  // Base durations
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const slower = Duration(milliseconds: 600);

  // Splash
  static const splashReveal = Duration(milliseconds: 350);

  // Cards
  static const cardEntrance = Duration(milliseconds: 300);
  static const cardStaggerDelay = Duration(milliseconds: 50);

  // Progress bar
  static const progressFill = Duration(milliseconds: 500);

  // Confetti
  static const confettiBurst = Duration(milliseconds: 3000);

  // Snackbar
  static const snackbarSlide = Duration(milliseconds: 200);
  static const undoWindow = Duration(seconds: 5);

  // FAB pulse
  static const fabPulse = Duration(milliseconds: 1800);

  // Sheet spring
  static const sheetOpen = Duration(milliseconds: 350);

  // Curves
  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve springCurve = Curves.elasticOut;
  static const Curve bounceCurve = Curves.bounceOut;
}
