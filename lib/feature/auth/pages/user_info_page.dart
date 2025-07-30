import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/widgets/custom_elevated_button.dart';
import 'package:whatsappnew/feature/auth/widgets/custom_text_field.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          'Kullanıcı Bilgileri',
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Text(
              'Please provide your name and an optional profile photo',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.customTheme.greyColor),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.customTheme.photoIconBgColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3, right: 3),
                child: Icon(
                  Icons.add_a_photo_rounded,
                  size: 48,
                  color: context.customTheme.photoIconColor,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: CustomTextField(
                    hintText: 'Adınızı buraya yazın',
                    textAlign: TextAlign.left,
                    autoFocus: true,
                    controller: nameController,
                    keyboardType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.emoji_emotions_outlined,
                  color: context.customTheme.photoIconColor,
                ),
                const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomElevatedButton(
        onPressed: () {},
        text: 'DEVAM ET',
        buttonwidth: 90,
      ),
    );
  }
}
