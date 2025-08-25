import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';
import 'package:whatsappnew/common/models/user_model.dart';
import 'package:whatsappnew/common/services/database_service.dart';
import 'package:whatsappnew/feature/chat/pages/chat_page.dart';
import 'package:whatsappnew/feature/calls/pages/calls_page.dart';
import 'package:whatsappnew/feature/chat/pages/home_chat_page.dart';
import 'package:whatsappnew/feature/status/pages/status_page.dart';
import 'package:whatsappnew/feature/auth/pages/community_page.dart';
import 'package:whatsappnew/feature/auth/pages/settings_page.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _bottomTabController;
  final DatabaseService _databaseService = DatabaseService();
  List<UserModel> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _bottomTabController = TabController(length: 5, vsync: this, initialIndex: 3);
    _bottomTabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('🏠 HomePage - Veri yükleme başlıyor...');
      
      // Database durumunu kontrol et
      await _databaseService.checkDatabaseStatus();
      
      await _databaseService.initialize();
      await _loadCurrentUser();
      await _loadUsers();
      
      print('✅ HomePage - Veri yükleme tamamlandı');
    } catch (e) {
      print('❌ HomePage - Veri yükleme hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('✅ HomePage - Kullanıcı yüklendi: ${user.displayName}');
      } else {
        print('⚠️ HomePage - Kullanıcı bulunamadı');
      }
    } catch (e) {
      print('❌ HomePage - Kullanıcı yükleme hatası: $e');
    }
  }

  Future<void> _initializeAndLoadUsers() async {
    try {
      // DatabaseService'i başlat
      await _databaseService.initialize();
      await _loadUsers();
    } catch (e) {
      print('DatabaseService başlatma hatası: $e');
      // Hata durumunda test verilerini kullan
      setState(() {
        users = _getFallbackUsers();
        isLoading = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    try {
      bool isConnected = false;
      try {
        isConnected = await _databaseService.testConnection().timeout(
          const Duration(seconds: 1),
          onTimeout: () => false,
        );
      } catch (e) {
        print('Database bağlantı testi başarısız: $e');
        isConnected = false;
      }
      
      if (isConnected) {
        try {
          final dbUsers = await _databaseService.getAllUsers().timeout(
            const Duration(seconds: 3),
            onTimeout: () => throw TimeoutException('getAllUsers timeout'),
          );
          
          if (mounted) {
            setState(() {
              users = dbUsers.isNotEmpty ? dbUsers : _getFallbackUsers();
              isLoading = false;
            });
          }
        } catch (e) {
          print('Database kullanıcı yükleme hatası: $e');
          if (mounted) {
            setState(() {
              users = _getFallbackUsers();
              isLoading = false;
            });
          }
        }
      } else {
        print('Database bağlantısı yok - test verileri kullanılıyor');
        if (mounted) {
          setState(() {
            users = _getFallbackUsers();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Kullanıcı yükleme hatası: $e');
      if (mounted) {
        setState(() {
          users = _getFallbackUsers();
          isLoading = false;
        });
      }
    }
  }

  List<UserModel> _getFallbackUsers() {
    return [];
  }

  // Test kullanıcılarını sil
  Future<void> _deleteTestUsers() async {
    try {
      await _databaseService.deleteTestUsers();
      // Kullanıcıları yeniden yükle
      await _loadUsers();
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
      // Kullanıcıları yeniden yükle
      await _loadUsers();
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

  // Zeynep kullanıcısını sil
  Future<void> _deleteZeynepUser() async {
    try {
      await _databaseService.deleteZeynepUser();
      // Kullanıcıları yeniden yükle
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zeynep kullanıcısı silindi!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Zeynep kullanıcısını silinirken hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _bottomTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          Row(
            children: [
              const SizedBox(width: 15),
              Icon(
                Icons.camera_alt_outlined,
                color: context.customTheme.greyColor,
                size: 22,
              ),
              const SizedBox(width: 15),
            ],
          ),
        ],
        title: Text(
          'WhatsApp Klonum',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: context.customTheme.authAppbarTextColor,
          ),
        ),
      ),
      body: IndexedStack(
        index: _bottomTabController.index,
        children: [
          // Durumlar
          const StatusPage(),
          // Aramalar
          const CallsPage(),
          // Topluluk
          const CommunityPage(),
          // Sohbetler
          const HomeChatPage(),
          // Ayarlar
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: TabBar(
          controller: _bottomTabController,
          indicatorColor: Coloors.greenDark,
          indicatorWeight: 3,
          labelColor: Coloors.greenDark,
          unselectedLabelColor: context.customTheme.greyColor,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.update, size: 24), text: 'Durumlar'),
            Tab(icon: Icon(Icons.phone, size: 24), text: 'Aramalar'),
            Tab(icon: Icon(Icons.groups, size: 24), text: 'Topluluk'),
            Tab(icon: Icon(Icons.chat_bubble, size: 24), text: 'Sohbet'),
            Tab(icon: Icon(Icons.settings, size: 24), text: 'Ayarlar'),
          ],
        ),
      ),
    );
  }

  // sohbet ana sayfası ayrı sayfaya taşındı (HomeChatPage)
}
