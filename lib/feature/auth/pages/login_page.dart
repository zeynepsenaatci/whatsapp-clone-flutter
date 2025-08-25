import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/helper/show_alert_dialog.dart';
import 'package:whatsappnew/common/utils/coloors.dart';
import 'package:whatsappnew/common/widgets/custom_elevated_button.dart';
import 'package:whatsappnew/common/widgets/custom_icon_button.dart';
import 'package:whatsappnew/feature/auth/widgets/custom_text_field.dart';
import 'package:whatsappnew/feature/auth/pages/verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController countryNameController;
  late TextEditingController countryCodeController;
  late TextEditingController phoneNumberController;

  sendCodeToPhone() async {
    final phone = phoneNumberController.text.trim().replaceAll(' ', '').replaceAll('-', '');
    final name = countryNameController.text.trim();
    final countryCode = countryCodeController.text.trim();

    if (phone.isEmpty) {
      return showAlertDialog(
        context: context,
        message: 'Lütfen telefon numaranızı girin.',
      );
    } else if (phone.length < 8) {
      return showAlertDialog(
        context: context,
        message: 'Telefon numarası çok kısa',
      );
    } else if (phone.length > 15) {
      return showAlertDialog(
        context: context,
        message: 'Telefon numarası çok uzun',
      );
    }

    try {
      
      // Telefon numarasını temizle ve formatla
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      
      // Eğer numara 0 ile başlıyorsa, 0'ı kaldır
      if (cleanPhone.startsWith('0')) {
        cleanPhone = cleanPhone.substring(1);
      }
      
      final formattedPhone = '+$countryCode$cleanPhone';
      print('OTP gönderiliyor: $formattedPhone'); // Debug mesajı
      
      // Firebase Auth ile OTP gönder
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          print('Otomatik doğrulama yapılıyor...'); // Debug mesajı
          // Otomatik doğrulama (Android'de)
          FirebaseAuth.instance.signInWithCredential(credential);
        },
                 verificationFailed: (FirebaseAuthException e) {
           print('Firebase Auth Hatası: ${e.code} - ${e.message}'); // Debug mesajı
           String errorMessage = 'Doğrulama hatası';
           
           switch (e.code) {
             case 'invalid-phone-number':
               errorMessage = 'Geçersiz telefon numarası';
               break;
             case 'too-many-requests':
               errorMessage = 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
               break;
             case 'quota-exceeded':
               errorMessage = 'Kota aşıldı. Lütfen daha sonra tekrar deneyin';
               break;
             case 'network-request-failed':
               errorMessage = 'Ağ bağlantı hatası. İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
               break;
             case 'app-not-authorized':
               errorMessage = 'Uygulama yetkilendirilmedi. Firebase yapılandırmasını kontrol edin.';
               break;
             default:
               errorMessage = 'Doğrulama hatası: ${e.message}';
           }
          
                     showAlertDialog(
             context: context,
             message: errorMessage,
           );
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP başarıyla gönderildi!'); // Debug mesajı
          print('VerificationId: $verificationId'); // Debug mesajı
          print('PhoneNumber: $formattedPhone'); // Debug mesajı
          
          // Null kontrolü
          if (verificationId.isEmpty) {
            print('VerificationId boş!');
            showAlertDialog(
              context: context,
              message: 'Doğrulama ID alınamadı. Lütfen tekrar deneyin.',
            );
            return;
          }
          
          // OTP gönderildi, VerificationPage'e geç
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationPage(
                phoneNumber: formattedPhone,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // OTP otomatik alınamadı
        },
      );
    } catch (e) {
      showAlertDialog(context: context, message: 'Bir hata oluştu: $e');
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
        // Use the actual dial code (e.g., 90) instead of the ISO code (e.g., TR)
        countryCodeController.text = country.phoneCode;
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
