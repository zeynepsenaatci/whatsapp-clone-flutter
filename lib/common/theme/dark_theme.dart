import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';

ThemeData darkTheme() {
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: Coloors.backgroundDark,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Coloors.greenDark,
        foregroundColor: Coloors.backgroundDark,
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),

    extensions: <ThemeExtension<dynamic>>[CustomThemeExtension.darkMode],
  );
}

extension CustomThemeExtensionGetter on BuildContext {
  CustomThemeExtension get customTheme =>
      Theme.of(this).extension<CustomThemeExtension>() ??
      CustomThemeExtension.lightMode;
}
