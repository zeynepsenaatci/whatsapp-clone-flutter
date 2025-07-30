import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';

import 'package:whatsappnew/common/widgets/custom_elevated_button.dart';
import 'package:whatsappnew/feature/welcome/widgets/privacyandterms.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                child: Image.asset(
                  'assets/images/circle.png',
                  color: context.customTheme.circleImageColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'WhatsApp\'a Hoş Geldiniz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const PrivacyandTerms(),
                SizedBox(height: 40),
                CustomElevatedButton(
                  onPressed: () {},
                  text: 'KABUL ET VE DEVAM ET',
                  buttonwidth: 130,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
