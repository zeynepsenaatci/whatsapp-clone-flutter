import 'package:flutter/material.dart';
import 'package:whatsappnew/common/utils/coloors.dart';

@immutable
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final Color? circleImageColor;
  final Color? greyColor;
  final Color? blueColor;
  final Color? langBtnBgColor;
  final Color? langBtnHighlightColor;
  final Color? authAppbarTextColor;
  final Color? photoIconBgColor;
  final Color? photoIconColor;
  final Color? searchBarColor;
  final Color? tabColor;
  final Color? tabText;

  const CustomThemeExtension({
    this.circleImageColor,
    this.greyColor,
    this.blueColor,
    this.langBtnBgColor,
    this.langBtnHighlightColor,
    this.authAppbarTextColor,
    this.photoIconBgColor,
    this.photoIconColor,
    this.searchBarColor,
    this.tabColor,
    this.tabText,
  });

  static const lightMode = CustomThemeExtension(
    circleImageColor: Color(0xFF25D366),
    greyColor: Coloors.greyLight,
    blueColor: Coloors.blueLight,
    langBtnBgColor: Color(0xFFF7F8FA),
    langBtnHighlightColor: Color(0xFFE8E8ED),
    authAppbarTextColor: Coloors.greenLight,
    photoIconBgColor: Color(0XFFF0F2F3),
    photoIconColor: Color(0XFF9DAAB3),
    searchBarColor: Coloors.searchLight,
    tabColor: Coloors.tabLight,
    tabText: Colors.white,
  );

  static const darkMode = CustomThemeExtension(
    circleImageColor: Coloors.greenDark,
    greyColor: Coloors.greyDark,
    blueColor: Coloors.blueDark,
    langBtnBgColor: Color(0xFF182229),
    langBtnHighlightColor: Color(0xFF09141A),
    authAppbarTextColor: Color(0xFFE9EDEF),
    photoIconBgColor: Color(0XFF202C33),
    photoIconColor: Color(0XFF8696A0),
    searchBarColor: Coloors.searchDark,
    tabColor: Coloors.tabDark,
    tabText: Colors.white,
  );

  @override
  CustomThemeExtension copyWith({
    Color? circleImageColor,
    Color? greyColor,
    Color? blueColor,
    Color? langBtnBgColor,
    Color? langBtnHighlightColor,
    Color? authAppbarTextColor,
    Color? photoIconBgColor,
    Color? photoIconColor,
    Color? searchBarColor,
    Color? tabColor,
    Color? tabText,
  }) {
    return CustomThemeExtension(
      photoIconBgColor: photoIconBgColor ?? this.photoIconBgColor,
      photoIconColor: photoIconColor ?? this.photoIconColor,
      circleImageColor: circleImageColor ?? this.circleImageColor,
      greyColor: greyColor ?? this.greyColor,
      blueColor: blueColor ?? this.blueColor,
      langBtnBgColor: langBtnBgColor ?? this.langBtnBgColor,
      langBtnHighlightColor:
          langBtnHighlightColor ?? this.langBtnHighlightColor,
      authAppbarTextColor: authAppbarTextColor ?? this.authAppbarTextColor,
      searchBarColor: searchBarColor ?? this.searchBarColor,
      tabColor: tabColor ?? this.tabColor,
      tabText: tabText ?? this.tabText,
    );
  }

  @override
  CustomThemeExtension lerp(
    ThemeExtension<CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! CustomThemeExtension) {
      return this;
    }
    return CustomThemeExtension(
      photoIconColor: Color.lerp(photoIconColor, other.photoIconColor, t),
      photoIconBgColor: Color.lerp(photoIconBgColor, other.photoIconBgColor, t),
      circleImageColor: Color.lerp(circleImageColor, other.circleImageColor, t),
      greyColor: Color.lerp(greyColor, other.greyColor, t),
      blueColor: Color.lerp(blueColor, other.blueColor, t),
      langBtnBgColor: Color.lerp(langBtnBgColor, other.langBtnBgColor, t),
      langBtnHighlightColor: Color.lerp(
        langBtnHighlightColor,
        other.langBtnHighlightColor,
        t,
      ),
      authAppbarTextColor: Color.lerp(
        authAppbarTextColor,
        other.authAppbarTextColor,
        t,
      ),
      searchBarColor: Color.lerp(searchBarColor, other.searchBarColor, t),
      tabColor: Color.lerp(tabColor, other.tabColor, t),
      tabText: Color.lerp(tabText, other.tabText, t),
    );
  }
}

extension CustomThemeExtensionGetter on BuildContext {
  CustomThemeExtension get customTheme =>
      Theme.of(this).extension<CustomThemeExtension>()!;
}
