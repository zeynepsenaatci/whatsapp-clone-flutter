import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/helper/show_alert_dialog.dart';
import 'package:whatsappnew/common/utils/coloors.dart';
import 'package:whatsappnew/common/widgets/custom_elevated_button.dart';
import 'package:whatsappnew/common/widgets/custom_icon_button.dart';
import 'package:whatsappnew/feature/auth/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController countryNameController;
  late TextEditingController countryCodeController;
  late TextEditingController phoneNumberController;

  sendCodeToPhone() {
    final phone = phoneNumberController.text.trim();
    final name = countryNameController.text.trim();

    if (phone.isEmpty) {
      return showAlertDialog(
        context: context,
        message: 'Lütfen telefon numaranızı girin.',
      );
    } else if (phone.length < 10) {
      return showAlertDialog(
        context: context,
        message: 'Telefon numarası seçili ülke için çok kısa: $name',
      );
    } else if (phone.length > 10) {
      return showAlertDialog(
        context: context,
        message: 'Telefon numarası seçili ülke için çok uzun: $name',
      );
    }
  }

  void showCountryCodePicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: ['TR'],
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: 600,
        backgroundColor: Theme.of(context).colorScheme.background,
        flagSize: 22,
        borderRadius: BorderRadius.circular(20),
        textStyle: TextStyle(color: context.customTheme.greyColor),
        inputDecoration: InputDecoration(
          labelStyle: TextStyle(color: context.customTheme.greyColor),
          prefixIcon: const Icon(Icons.language, color: Coloors.greenDark),
        ),
      ),
      onSelect: (country) {
        countryNameController.text = country.name;
        countryCodeController.text = country.countryCode;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    countryNameController = TextEditingController(text: 'Türkiye');
    countryCodeController = TextEditingController(text: '90');
    phoneNumberController = TextEditingController();
  }

  @override
  void dispose() {
    countryNameController.dispose();
    countryCodeController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Telefon Numaranızı Girin',
          style: TextStyle(color: context.customTheme.authAppbarTextColor),
        ),
        centerTitle: true,
        actions: [CustomIconButton(onTap: () {}, icon: Icons.more_vert)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    'Uygulamayı kullanmak için numaranızı doğrulamamız gerekli.',
                style: TextStyle(
                  color: context.customTheme.greyColor,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: " Numaram Ne?",
                    style: TextStyle(color: context.customTheme.blueColor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: CustomTextField(
              onTap: showCountryCodePicker,
              controller: countryNameController,
              readOnly: true,
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: Coloors.greenDark,
              ),
              hintText: 'Ülke kodu ve ismi girin',
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.customTheme.greyColor!.withOpacity(0.2),
                ),
              ),

              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Coloors.greenDark),
              ),

              keyboardType: TextInputType.text,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: CustomTextField(
                    onTap: showCountryCodePicker,
                    controller: countryCodeController,
                    prefixText: '+',
                    readOnly: true,
                    keyboardType: TextInputType.number,
                    enabledBorder: null,
                    focusedBorder: null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomTextField(
                    controller: phoneNumberController,
                    hintText: 'telefon numarası',
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.number,
                    enabledBorder: null,
                    focusedBorder: null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Operatörünüze bağlı ücret alınabilir.',
            style: TextStyle(color: context.customTheme.greyColor),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomElevatedButton(
        onPressed: sendCodeToPhone,
        text: 'DEVAM ET',
        buttonwidth: 90,
      ),
    );
  }
}
