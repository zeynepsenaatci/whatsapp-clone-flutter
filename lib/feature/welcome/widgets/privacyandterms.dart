import 'package:flutter/material.dart';
import 'package:whatsappnew/common/utils/Coloors.dart';

class PrivacyandTerms extends StatelessWidget {
  const PrivacyandTerms({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 20,
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          text: 'Devam ederek WhatsApp\'ın ',
          style: TextStyle(color:Coloors.greyDark, height: 1.5),
          children: [
            TextSpan(
              text: 'Hizmet Koşulları ',
              style: TextStyle(color: Coloors.blueLight),
            ),
            TextSpan(text: 've '),
            TextSpan(
              text: 'Gizlilik Politikasını ',
              style: TextStyle(color:Coloors.blueLight),
            ),
            TextSpan(text: 'kabul etmiş olursunuz.'),
          ],
        ),
      ),
    );
  }
}
