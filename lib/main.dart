import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:whatsappnew/common/theme/dark_theme.dart';
import 'package:whatsappnew/common/theme/light_theme.dart';
import 'package:whatsappnew/feature/welcome/pages/welcome_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🚀 Firebase başlatma süreci başlıyor...');
    
    // Firebase'i başlat (eğer başlatılmamışsa)
    if (Firebase.apps.isEmpty) {
      print('📱 Firebase başlatılıyor...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase başarıyla başlatıldı');
    } else {
      print('✅ Firebase zaten başlatılmış (${Firebase.apps.length} app)');
    }

    // Firebase Database'i yapılandır
    print('🔗 Firebase Database yapılandırılıyor...');
    await _configureFirebaseDatabase();
    
    // Firebase Auth'u yapılandır
    print('🔐 Firebase Auth yapılandırılıyor...');
    await _configureFirebaseAuth();

    print('✅ Firebase yapılandırması tamamlandı');
  } catch (e) {
    print('❌ Firebase başlatma hatası: $e');
    print('🔍 Hata detayı: ${e.toString()}');
    print('⚠️ Firebase hatası olsa bile uygulama başlatılıyor...');
  }

  print('🎯 Uygulama başlatılıyor...');
  runApp(const MyApp());
}

Future<void> _configureFirebaseDatabase() async {
  try {
    print('🔧 Database yapılandırması başlıyor...');
    
    // Database referansını al
    final database = FirebaseDatabase.instance;
    
    // Database URL'ini manuel olarak ayarla
    database.databaseURL = 'https://whatsappnew-4fa1c-default-rtdb.firebaseio.com';
    print('🔗 Database URL ayarlandı: ${database.databaseURL}');
    
    // Offline persistence'ı etkinleştir
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(50 * 1024 * 1024); // 50MB
    print('💾 Database persistence etkinleştirildi (50MB)');
    
    // Bağlantıyı test et
    final ref = database.ref();
    print('🔍 Database bağlantısı test ediliyor...');
    
    try {
      final snapshot = await ref.child('.info/connected').get().timeout(
        const Duration(seconds: 10), // Timeout süresini artırdım
        onTimeout: () => throw Exception('Database bağlantı zaman aşımı'),
      );
      
      if (snapshot.exists) {
        final isConnected = snapshot.value as bool? ?? false;
        print('📊 Database bağlantı durumu: $isConnected');
        if (isConnected) {
          print('✅ Database bağlantısı başarılı');
        } else {
          print('⚠️ Database bağlantısı yok, ama devam ediliyor');
        }
      } else {
        print('⚠️ Database bağlantı bilgisi bulunamadı, ama devam ediliyor');
      }
    } catch (e) {
      print('⚠️ Database bağlantı testi başarısız: $e');
      print('⚠️ Ama devam ediliyor...');
    }
    
    print('✅ Firebase Database yapılandırması tamamlandı');
  } catch (e) {
    print('❌ Firebase Database yapılandırma hatası: $e');
    print('🔍 Database hatası detayı: ${e.toString()}');
  }
}

Future<void> _configureFirebaseAuth() async {
  try {
    // Debug modunda App Check'i devre dışı bırak
    if (kDebugMode) {
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
      );
      print('✅ Firebase Auth debug modu etkinleştirildi');
    }
    
    print('✅ Firebase Auth yapılandırması tamamlandı');
  } catch (e) {
    print('❌ Firebase Auth yapılandırma hatası: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp Clone',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: ThemeMode.system,
      home: WelcomePage(),
    );
  }
}
