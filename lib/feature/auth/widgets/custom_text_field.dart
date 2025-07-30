import 'package:flutter/material.dart';
import 'package:whatsappnew/common/theme/dark_theme.dart';
import 'package:whatsappnew/common/utils/coloors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.readOnly,
    this.textAlign,
    required this.keyboardType,
    this.prefixText,
    this.onTap,
    this.suffixIcon,
    this.onChanged,
    this.enabledBorder,
    this.focusedBorder,
    this.fontSize,
    this.autoFocus,
    this.maxLength,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool? readOnly;
  final TextAlign? textAlign;
  final TextInputType keyboardType;
  final String? prefixText;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final double? fontSize;
  final bool? autoFocus;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      controller: controller,
      readOnly: readOnly ?? false,
      textAlign: textAlign ?? TextAlign.center,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLength: maxLength,
      style: TextStyle(
        fontSize: fontSize ?? 16,
      ),
      autofocus: autoFocus ?? false,
      decoration: InputDecoration(
        isDense: true,
        prefixText: prefixText,
        suffix: suffixIcon,
        hintText: hintText,
        hintStyle: TextStyle(
          color: context.customTheme.greyColor,
          fontSize: fontSize ?? 16,
        ),
        counterText: '', // Hide character counter
        enabledBorder: enabledBorder ?? const UnderlineInputBorder(
          borderSide: BorderSide(color: Coloors.greenDark),
        ),
        focusedBorder: focusedBorder ?? const UnderlineInputBorder(
          borderSide: BorderSide(color: Coloors.greenDark, width: 2),
        ),
      ),
    );
  }
}
