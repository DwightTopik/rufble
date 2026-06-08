import 'package:flutter/widgets.dart';
import 'package:rufble/core/constants/app_colors.dart';

/// The six selectable goal accent colors. Stored on [Goal.color] as the hex
/// string in [GoalPalette.toHex] form; resolved back to a [Color] for painting
/// the progress bar and accents. Values are drawn from the brand/status tokens
/// so goals stay on-palette (never hardcode hex inline — these are the source).
abstract final class GoalPalette {
  static const List<Color> swatches = [
    AppColors.primary, // forest green
    AppColors.blue, // royal blue
    AppColors.gold, // amber
    AppColors.error, // red
    AppColors.primaryLight, // light green
    AppColors.silver, // neutral
  ];

  /// Default accent when a goal has no explicit color.
  static const Color fallback = AppColors.primary;

  /// `#RRGGBB` (no alpha) for persistence.
  static String toHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Parses a stored `#RRGGBB` value, falling back to [fallback] on null/invalid.
  static Color fromHex(String? hex) {
    if (hex == null) return fallback;
    var cleaned = hex.replaceAll('#', '');
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return fallback;
    return Color(value);
  }
}
