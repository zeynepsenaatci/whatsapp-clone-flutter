import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';

void showAlertDialog({
  required BuildContext context,
  required String message,
  String? btnText,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(
          message,
          style: TextStyle(color: context.customTheme.greyColor, fontSize: 15),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              btnText ?? 'TAMAM',
              style: TextStyle(color: context.customTheme.circleImageColor),
            ),
          ),
        ],
      );
    },
  );
}
