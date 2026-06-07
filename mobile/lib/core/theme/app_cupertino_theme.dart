import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rufble/core/constants/app_colors.dart';
import 'package:rufble/core/theme/app_theme_extension.dart';

final lightCupertinoTheme = CupertinoThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.lightBg,
  textTheme: const CupertinoTextThemeData(
    textStyle: TextStyle(
      fontFamily: 'SFProText',
      color: AppColors.lightText1,
    ),
    navTitleTextStyle: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w600,
      fontSize: 17,
      color: AppColors.lightText1,
    ),
    navLargeTitleTextStyle: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w700,
      fontSize: 34,
      color: AppColors.lightText1,
    ),
  ),
);

final darkCupertinoTheme = CupertinoThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.darkBg,
  textTheme: const CupertinoTextThemeData(
    textStyle: TextStyle(
      fontFamily: 'SFProText',
      color: AppColors.darkText1,
    ),
    navTitleTextStyle: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w600,
      fontSize: 17,
      color: AppColors.darkText1,
    ),
    navLargeTitleTextStyle: TextStyle(
      fontFamily: 'SFProDisplay',
      fontWeight: FontWeight.w700,
      fontSize: 34,
      color: AppColors.darkText1,
    ),
  ),
);

ThemeData buildThemeData({required bool isDark}) {
  final cupertino = isDark ? darkCupertinoTheme : lightCupertinoTheme;
  return ThemeData(
    brightness: isDark ? Brightness.dark : Brightness.light,
    fontFamily: 'SFProText',
    extensions: [isDark ? AppThemeExtension.dark : AppThemeExtension.light],
    cupertinoOverrideTheme: cupertino,
  );
}
