import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';

ThemeData lightTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: Coloors.backgroundLight,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Coloors.greenLight,
        foregroundColor: Coloors.backgroundLight,
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[CustomThemeExtension.lightMode],
  );
}
