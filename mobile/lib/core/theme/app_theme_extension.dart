import 'package:flutter/material.dart';
import 'package:rufble/core/constants/app_colors.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.bg,
    required this.surface,
    required this.elevated,
    required this.border,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.primary,
    required this.primaryLight,
    required this.gold,
    required this.silver,
    required this.blue,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  final Color bg;
  final Color surface;
  final Color elevated;
  final Color border;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color primary;
  final Color primaryLight;
  final Color gold;
  final Color silver;
  final Color blue;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  static const light = AppThemeExtension(
    bg: AppColors.lightBg,
    surface: AppColors.lightSurface,
    elevated: AppColors.lightElevated,
    border: AppColors.lightBorder,
    text1: AppColors.lightText1,
    text2: AppColors.lightText2,
    text3: AppColors.lightText3,
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    gold: AppColors.gold,
    silver: AppColors.silver,
    blue: AppColors.blue,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
  );

  static const dark = AppThemeExtension(
    bg: AppColors.darkBg,
    surface: AppColors.darkSurface,
    elevated: AppColors.darkElevated,
    border: AppColors.darkBorder,
    text1: AppColors.darkText1,
    text2: AppColors.darkText2,
    text3: AppColors.darkText3,
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    gold: AppColors.gold,
    silver: AppColors.silver,
    blue: AppColors.blueDark,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.blueDark,
  );

  @override
  AppThemeExtension copyWith({
    Color? bg,
    Color? surface,
    Color? elevated,
    Color? border,
    Color? text1,
    Color? text2,
    Color? text3,
    Color? primary,
    Color? primaryLight,
    Color? gold,
    Color? silver,
    Color? blue,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppThemeExtension(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      elevated: elevated ?? this.elevated,
      border: border ?? this.border,
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      gold: gold ?? this.gold,
      silver: silver ?? this.silver,
      blue: blue ?? this.blue,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other == null) return this;
    return AppThemeExtension(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      text1: Color.lerp(text1, other.text1, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      silver: Color.lerp(silver, other.silver, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

extension AppThemeExtensionX on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
