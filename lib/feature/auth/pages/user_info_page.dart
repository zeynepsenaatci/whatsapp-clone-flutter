import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/helper/show_alert_dialog.dart';
import 'package:whatsappnew/common/widgets/custom_elevated_button.dart';
import 'package:whatsappnew/feature/auth/widgets/custom_text_field.dart';
import 'package:whatsappnew/feature/auth/pages/home_page.dart';
import 'package:whatsappnew/common/models/user_model.dart';
import 'package:whatsappnew/common/services/database_service.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class UserInfoPage extends StatefulWidget {
  final String phoneNumber;
  
  const UserInfoPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  late TextEditingController nameController;
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _databaseService = DatabaseService();
  bool isLoading = false;
  File? _selectedImage;

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

  Future<void> saveUserInfo() async {
    if (nameController.text.trim().isEmpty) {
      showAlertDialog(
        context: context,
        message: 'Lütfen adınızı girin',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final name = nameController.text.trim();
        
        // Auth display name'i güncelle
        await user.updateDisplayName(name);
        print('✅ Auth display name güncellendi: $name');

        // Database bağlantısını kontrol et
        try {
          await _databaseService.initialize();
          
          bool isConnected = false;
          try {
            // Database bağlantısını hızlıca test et
            isConnected = await _databaseService.testConnection().timeout(
              const Duration(seconds: 2),
              onTimeout: () => false,
            );
          } catch (e) {
            print('Database bağlantı testi başarısız: $e');
            isConnected = false;
          }

          if (isConnected) {
            // Database'e kaydet
            final userModel = UserModel(
              uid: user.uid,
              phoneNumber: widget.phoneNumber,
              name: name,
              createdAt: DateTime.now(),
              isOnline: true,
            );
            
            // Database kaydını arka planda yap
            _databaseService.saveUser(userModel).catchError((e) {
              print('Database kayıt hatası (arka plan): $e');
            });
            print('✅ Kullanıcı modeli oluşturuldu ve kayıt başlatıldı');
          } else {
            print('Database bağlantısı yok - sadece Auth ile devam ediliyor');
          }
        } catch (e) {
          print('DatabaseService başlatma hatası: $e');
          // Database hatası olsa bile Auth ile devam et
        }

        // Hemen ana sayfaya geç
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print('Kullanıcı bilgisi kaydetme hatası: $e');
      if (mounted) {
        showAlertDialog(
          context: context,
          message: 'Kullanıcı bilgisi kaydedilemedi: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Test kullanıcılarını sil
  Future<void> _deleteTestUsers() async {
    try {
      await _databaseService.deleteTestUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test kullanıcıları silindi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test kullanıcıları silinirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // TÜM KULLANICILARI SİL
  Future<void> _deleteAllUsers() async {
    try {
      await _databaseService.deleteAllUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('TÜM KULLANICILAR SİLİNDİ!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tüm kullanıcıları silinirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        return;
      }
      
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      showAlertDialog(
        context: context,
        message: 'Fotoğraf seçilirken hata oluştu: $e',
      );
    }
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
            const SizedBox(height: 20),
                         Text(
               'Lütfen profil fotoğrafınızı ve adınızı ekleyin.',
               textAlign: TextAlign.center,
               style: TextStyle(
                 color: context.customTheme.greyColor,
                 fontSize: 16,
               ),
             ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.customTheme.photoIconBgColor,
                ),
                                 child: _selectedImage != null
                     ? ClipOval(
                         child: Image.file(
                           _selectedImage!,
                           width: 120,
                           height: 120,
                           fit: BoxFit.cover,
                         ),
                       )
                     : Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Icon(
                             Icons.add_a_photo_rounded,
                             size: 48,
                             color: context.customTheme.photoIconColor,
                           ),
                           const SizedBox(height: 8),
                           Text(
                             'Fotoğraf Ekle',
                             style: TextStyle(
                               color: context.customTheme.photoIconColor,
                               fontSize: 12,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                         ],
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
                                 Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: context.customTheme.photoIconBgColor,
                     borderRadius: BorderRadius.circular(20),
                   ),
                   child: Icon(
                     Icons.emoji_emotions_outlined,
                     color: context.customTheme.photoIconColor,
                     size: 20,
                   ),
                 ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
             floatingActionButton: isLoading 
         ? Container(
             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
             decoration: BoxDecoration(
               color: context.customTheme.photoIconBgColor,
               borderRadius: BorderRadius.circular(8),
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 SizedBox(
                   width: 16,
                   height: 16,
                   child: CircularProgressIndicator(
                     strokeWidth: 2,
                     valueColor: AlwaysStoppedAnimation<Color>(
                       context.customTheme.photoIconColor!,
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 Text(
                   'Kaydediliyor...',
                   style: TextStyle(
                     color: context.customTheme.photoIconColor,
                     fontSize: 14,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
               ],
             ),
           )
         : CustomElevatedButton(
             onPressed: saveUserInfo,
             text: 'DEVAM ET',
             buttonwidth: 90,
           ),
    );
  }
}
