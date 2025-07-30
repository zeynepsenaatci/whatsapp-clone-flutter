import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/feature/auth/widgets/custom_text_field.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late TextEditingController codeController;
  

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          'Numara Doğrulama',
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: context.customTheme.greyColor),
            splashColor: Colors.transparent,
            splashRadius: 22,
            iconSize: 22,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: context.customTheme.greyColor,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text:
                          "Kodunuzu içeren bir SMS veya arama isteğinde bulunmadan önce numarayı kontrol edin.\n ",
                    ),
                    TextSpan(
                      text: 'Yanlış mı? ',
                      style: TextStyle(color: context.customTheme.blueColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: CustomTextField(
                hintText: '------',
                keyboardType: TextInputType.number,
                onChanged: (value) {},
                fontSize: 25,
                autoFocus: true,
                controller: codeController,
                maxLength: 6,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '6 haneli kodu girin',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.message, color: context.customTheme.greyColor),
                const SizedBox(width: 20),
                Text(
                  'SMS ile kod gönder',
                  style: TextStyle(color: context.customTheme.greyColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: context.customTheme.blueColor!.withOpacity(0.2)),
            Row(
              children: [
                Icon(Icons.phone, color: context.customTheme.greyColor),
                const SizedBox(width: 20),
                Text(
                  'Çağrı ile kod gönder',
                  style: TextStyle(color: context.customTheme.greyColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
