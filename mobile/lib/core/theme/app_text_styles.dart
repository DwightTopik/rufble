import 'package:flutter/cupertino.dart';

abstract final class AppTextStyles {
  static TextStyle numeric(double size, FontWeight weight, Color color) =>
      TextStyle(
        fontFamily: 'SpaceMono',
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle display(double size, FontWeight weight, Color color) =>
      TextStyle(
        fontFamily: 'SFProDisplay',
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle body(double size, FontWeight weight, Color color) =>
      TextStyle(
        fontFamily: 'SFProText',
        fontSize: size,
        fontWeight: weight,
        color: color,
      );
}
