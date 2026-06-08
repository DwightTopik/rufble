import 'package:flutter/widgets.dart';

/// A rounded progress bar painted with a CustomPainter. [progress] is clamped
/// to 0..1. The fill uses [color] (the goal's accent); the track uses
/// [trackColor]. Used on goal cards — kept dependency-free so it can paint in
/// long scrolling lists without shader glass (see CLAUDE.md "Glass rule").
class GoalProgressBar extends StatelessWidget {
  const GoalProgressBar({
    super.key,
    required this.progress,
    required this.color,
    required this.trackColor,
    this.height = _defaultHeight,
  });

  static const double _defaultHeight = 8;

  final double progress;
  final Color color;
  final Color trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _ProgressPainter(
          progress: progress.clamp(0.0, 1.0),
          color: color,
          trackColor: trackColor,
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final trackPaint = Paint()..color = trackColor;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );
    canvas.drawRRect(track, trackPaint);

    if (progress <= 0) return;
    final fillWidth = (size.width * progress).clamp(size.height, size.width);
    final fillPaint = Paint()..color = color;
    final fill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, size.height),
      radius,
    );
    canvas.drawRRect(fill, fillPaint);
  }

  @override
  bool shouldRepaint(_ProgressPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}

/// Convenience: integer-safe progress fraction from minor units. Returns 0 when
/// [target] <= 0. Computed in double only for the paint ratio — never for money.
double progressFraction(int saved, int target) {
  if (target <= 0) return 0;
  if (saved <= 0) return 0;
  if (saved >= target) return 1;
  return saved / target;
}

/// Whole-percent integer for display (0..100), saturating at 100.
int progressPercent(int saved, int target) {
  if (target <= 0 || saved <= 0) return 0;
  final pct = saved * 100 ~/ target;
  return pct > 100 ? 100 : pct;
}
