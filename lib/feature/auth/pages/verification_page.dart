import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/helper/show_alert_dialog.dart';
import 'package:whatsappnew/common/widgets/custom_elevated_button.dart';
import 'package:whatsappnew/feature/auth/widgets/custom_text_field.dart';
import 'package:whatsappnew/feature/auth/pages/user_info_page.dart';

class VerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  
  const VerificationPage({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  late TextEditingController codeController;
  bool isLoading = false;

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

  void verifyOTP() async {
    final code = codeController.text.trim();
    
    print('OTP doğrulama başlatılıyor...'); // Debug mesajı
    print('Girilen kod: $code'); // Debug mesajı
    print('VerificationId: ${widget.verificationId}'); // Debug mesajı
    
    // Null kontrolü
    if (widget.verificationId.isEmpty) {
      print('VerificationId boş!');
      showAlertDialog(
        context: context,
        message: 'Doğrulama ID bulunamadı. Lütfen tekrar deneyin.',
      );
      return;
    }
    
    if (code.isEmpty) {
      return showAlertDialog(
        context: context,
        message: 'Lütfen doğrulama kodunu girin.',
      );
    }
    
    if (code.length != 6) {
      return showAlertDialog(
        context: context,
        message: 'Doğrulama kodu 6 haneli olmalıdır.',
      );
    }

    setState(() {
      isLoading = true;
    });

    try {
      print('Firebase credential oluşturuluyor...'); // Debug mesajı
      
      // Null kontrolü
      if (widget.verificationId.isEmpty || code.isEmpty) {
        throw Exception('VerificationId veya kod boş!');
      }
      
      // Firebase ile OTP doğrula
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      print('Kullanıcı giriş yapılıyor...'); // Debug mesajı
      // Kullanıcıyı giriş yaptır
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      print('Giriş başarılı! UserInfoPage\'e yönlendiriliyor...'); // Debug mesajı
      // UserInfoPage'e yönlendir
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoPage(
            phoneNumber: widget.phoneNumber,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Hatası: ${e.code} - ${e.message}'); // Debug mesajı
      String errorMessage = 'Doğrulama hatası';
      
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Geçersiz doğrulama kodu';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Geçersiz doğrulama ID';
          break;
        default:
          errorMessage = 'Doğrulama hatası: ${e.message}';
      }
      
      showAlertDialog(
        context: context,
        message: errorMessage,
      );
    } catch (e) {
      showAlertDialog(
        context: context,
        message: 'Bir hata oluştu: $e',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                      text: widget.phoneNumber,
                      style: TextStyle(
                        color: context.customTheme.authAppbarTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '\nYanlış mı? ',
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
                onChanged: (value) {
                  if (value.length == 6) {
                    verifyOTP();
                  }
                },
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
            const SizedBox(height: 50),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: CustomElevatedButton(
        onPressed: isLoading ? null : verifyOTP,
        text: isLoading ? 'Doğrulanıyor...' : 'DEVAM ET',
        buttonwidth: 90,
      ),
    );
  }
}
