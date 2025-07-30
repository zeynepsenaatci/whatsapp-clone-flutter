import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final double? buttonWidth;
  final VoidCallback? onPressed;
  final String? text;
  const CustomElevatedButton({
    super.key,
    this.buttonWidth,
    this.onPressed,
    this.text, required int buttonwidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      width: MediaQuery.of(context).size.width - 100,
      child: ElevatedButton(
        onPressed: onPressed,

        child: Text(text ?? 'KABUL ET VE DEVAM ET'),
      ),
    );
  }
}
