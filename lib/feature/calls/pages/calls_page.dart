import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';
import 'package:whatsappnew/common/models/user_model.dart';
import 'package:whatsappnew/common/models/call_model.dart';
import 'package:whatsappnew/common/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  int _currentPage = 0;
  List<CallModel> callHistory = [];
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  bool isLoading = true;
  bool isSearching = false;
  String? currentUserId;
  
  final List<Map<String, String>> _infoSlides = [
    {
      'title': 'Gizli aramalar yapın',
      'description': 'Herhangi bir cihazda yapacağınız güvenli görüntülü ve sesli aramalarla bağlantıda kalın.',
      'image': 'assets/images/gizliarama.png',
    },
    {
      'title': 'Grup aramaları',
      'description': 'Arkadaşlarınızla birlikte grup görüntülü ve sesli aramalar yapın.',
      'image': 'assets/images/grupfoto.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _databaseService.initialize();
      await _loadCurrentUser();
      
      // Arama geçmişini temizle ve kullanıcı adlarını güncelle
      await _clearCallHistoryAndUpdateNames();
      
      await _loadCallHistory();
      await _loadUsers();
    } catch (e) {
      print('Veri yükleme hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Arama geçmişini temizle ve kullanıcı adlarını güncelle
  Future<void> _clearCallHistoryAndUpdateNames() async {
    try {
      print('🧹 Arama geçmişi temizleniyor...');
      await _databaseService.deleteAllCalls();
      print('✅ Tüm aramalar silindi');
    } catch (e) {
      print('❌ Arama geçmişi temizleme hatası: $e');
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
      
      // Kullanıcı adını kontrol et
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        print('✅ Calls sayfası - Kullanıcı adı: ${user.displayName}');
      } else {
        print('⚠️ Calls sayfası - Kullanıcı adı boş');
      }
    }
  }

  Future<void> _loadCallHistory() async {
    if (currentUserId == null) {
      print('❌ currentUserId null, arama geçmişi yüklenemiyor');
      return;
    }

    try {
      print('📞 Arama geçmişi yükleniyor: $currentUserId');
      final calls = await _databaseService.getCallHistory(currentUserId!);
      
      if (mounted) {
        setState(() {
          callHistory = calls;
        });
        print('✅ Arama geçmişi yüklendi: ${calls.length} arama');
        
        // Arama geçmişini kontrol et
        if (calls.isEmpty) {
          print('📝 Arama geçmişi boş');
        } else {
          calls.forEach((call) {
            print('📞 Arama: ${call.callerName} → ${call.receiverName} (${call.timestamp})');
          });
        }
      } else {
        print('⚠️ Widget unmounted, arama geçmişi güncellenmedi');
      }
    } catch (e) {
      print('❌ Arama geçmişi yükleme hatası: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final dbUsers = await _databaseService.getAllUsers().timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('getAllUsers timeout'),
      );
      
      if (mounted) {
        setState(() {
          users = dbUsers.isNotEmpty ? dbUsers : _getFallbackUsers();
          filteredUsers = users;
        });
      }
    } catch (e) {
      print('Kullanıcı yükleme hatası: $e');
      if (mounted) {
        setState(() {
          users = _getFallbackUsers();
          filteredUsers = users;
        });
      }
    }
  }

  List<UserModel> _getFallbackUsers() {
    return [];
  }

  void _onSearchChanged(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredUsers = users;
      } else {
        filteredUsers = users.where((user) =>
          user.name.toLowerCase().contains(query.toLowerCase()) ||
          user.phoneNumber.contains(query)
        ).toList();
      }
    });
  }

  void _showNewCallDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.customTheme.tabColor,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.customTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: context.customTheme.authAppbarTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Yeni arama',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.customTheme.authAppbarTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${filteredUsers.length}',
                    style: TextStyle(
                      color: context.customTheme.greyColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.customTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: context.customTheme.authAppbarTextColor),
                decoration: InputDecoration(
                  hintText: 'Ara',
                  hintStyle: TextStyle(color: context.customTheme.greyColor),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.customTheme.greyColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            
            // Call options
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildCallOption(
                    icon: Icons.link,
                    title: 'Yeni arama bağlantısı',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Arama bağlantısı özelliği yakında eklenecek!')),
                      );
                    },
                  ),
                  _buildCallOption(
                    icon: Icons.dialpad,
                    title: 'Bir numara çevirin',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Numara çevirme özelliği yakında eklenecek!')),
                      );
                    },
                  ),
                  _buildCallOption(
                    icon: Icons.person_add,
                    title: 'Yeni kişi',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kişi ekleme özelliği yakında eklenecek!')),
                      );
                    },
                  ),
                  _buildCallOption(
                    icon: Icons.schedule,
                    title: 'Arama planlayın',
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Arama planlama özelliği yakında eklenecek!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            
                         // Divider
             Container(
               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               child: Divider(color: context.customTheme.greyColor?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3)),
             ),
            
            // Users list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildCallUserItem(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: context.customTheme.authAppbarTextColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: context.customTheme.authAppbarTextColor,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCallUserItem(UserModel user) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: context.customTheme.photoIconBgColor,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: context.customTheme.photoIconColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          if (user.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.customTheme.backgroundColor ?? Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user.name,
        style: TextStyle(
          color: context.customTheme.authAppbarTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        user.phoneNumber,
        style: TextStyle(
          color: context.customTheme.greyColor,
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              _makeCall(user, CallMediaType.voice);
            },
            icon: Icon(
              Icons.call,
              color: Coloors.greenDark,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
              _makeCall(user, CallMediaType.video);
            },
            icon: Icon(
              Icons.videocam,
              color: Coloors.greenDark,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  void _makeCall(UserModel user, CallMediaType mediaType) {
    if (currentUserId == null) return;

    // Mevcut kullanıcının adını al
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserName = currentUser?.displayName ?? 'Ben';

    final call = CallModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      callerId: currentUserId!,
      receiverId: user.uid,
      callerName: currentUserName, // Gerçek kullanıcı adını kullan
      receiverName: user.name,
      timestamp: DateTime.now(),
      duration: const Duration(seconds: 0),
      callType: CallType.outgoing,
      mediaType: mediaType,
      isAnswered: false,
    );

    // Arama kaydet
    _databaseService.saveCall(call).then((_) {
      print('Arama başarıyla kaydedildi');
      // Arama geçmişini güncelle
      _loadCallHistory();
    }).catchError((e) {
      print('Arama kaydetme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Arama kaydedilemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    });

    // Arama simülasyonu
    _showCallDialog(user, mediaType, call);
  }

  void _showCallDialog(UserModel user, CallMediaType mediaType, CallModel call) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: context.customTheme.tabColor,
        title: Text(
          '${mediaType == CallMediaType.voice ? 'Sesli' : 'Görüntülü'} Arama',
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: context.customTheme.photoIconBgColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: context.customTheme.photoIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(
                color: context.customTheme.authAppbarTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aranıyor...',
              style: TextStyle(
                color: context.customTheme.greyColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _endCall(call, false);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );

    // 3 saniye sonra otomatik kapat
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        _endCall(call, false);
      }
    });
  }

  void _endCall(CallModel call, bool wasAnswered) {
    // Arama durumunu güncelle
    final updatedCall = call.copyWith(
      isAnswered: wasAnswered,
      duration: wasAnswered ? const Duration(seconds: 30) : const Duration(seconds: 0),
    );

    // Firebase'de arama durumunu güncelle
    _databaseService.updateCall(updatedCall).then((_) {
      print('Arama durumu güncellendi');
      _loadCallHistory();
    }).catchError((e) {
      print('Arama güncelleme hatası: $e');
    });

    _showCallEndedDialog(updatedCall);
  }

  void _showCallEndedDialog(CallModel call) {
    final userName = call.callerId == currentUserId ? call.receiverName : call.callerName;
    final mediaType = call.mediaType;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.customTheme.tabColor,
        title: Text(
          'Arama Sonlandı',
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$userName ile ${mediaType == CallMediaType.voice ? 'sesli' : 'görüntülü'} arama sonlandı.',
              style: TextStyle(
                color: context.customTheme.authAppbarTextColor,
              ),
            ),
            if (call.isAnswered && call.duration.inSeconds > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Süre: ${call.formattedDuration}',
                style: TextStyle(
                  color: context.customTheme.greyColor,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tamam',
              style: TextStyle(
                color: Coloors.greenDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customTheme.backgroundColor ?? Colors.white,
      appBar: AppBar(
        backgroundColor: context.customTheme.backgroundColor ?? Colors.white,
        elevation: 0,
        title: Text(
          'Aramalar',
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showNewCallDialog,
              child: CircleAvatar(
                backgroundColor: Coloors.greenDark,
                radius: 20,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Tab bar
            Container(
              color: context.customTheme.backgroundColor ?? Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Coloors.greenDark,
                labelColor: Coloors.greenDark,
                unselectedLabelColor: context.customTheme.greyColor,
                tabs: const [
                  Tab(text: 'Arama başlatın'),
                  Tab(text: 'Arama geçmişi'),
                ],
              ),
            ),
            
            // Tab içeriği
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStartCallTab(),
                  _buildCallHistoryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartCallTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Slider bölümü
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _infoSlides.length,
              itemBuilder: (context, index) {
                final slide = _infoSlides[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        slide['image']!,
                        height: 72,
                        width: 72,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide['title']!,
                        style: TextStyle(
                          color: context.customTheme.authAppbarTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        slide['description']!,
                        style: TextStyle(
                          color: context.customTheme.greyColor,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Slider noktaları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _infoSlides.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index 
                    ? Coloors.greenDark 
                    : context.customTheme.greyColor,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Kullanıcı listesi
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildCallUser(user);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCallHistoryTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (callHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.call_end,
              size: 64,
              color: context.customTheme.greyColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz arama geçmişi yok',
              style: TextStyle(
                color: context.customTheme.greyColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk aramayı siz yapın!',
              style: TextStyle(
                color: context.customTheme.greyColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: callHistory.length,
      itemBuilder: (context, index) {
        final call = callHistory[index];
        return _buildCallHistoryItem(call);
      },
    );
  }

  Widget _buildCallUser(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: context.customTheme.photoIconBgColor,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: context.customTheme.photoIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (user.isOnline)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.customTheme.backgroundColor ?? Colors.grey,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          user.name,
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _makeCall(user, CallMediaType.voice),
              icon: Icon(
                Icons.call,
                color: Coloors.greenDark,
                size: 22,
              ),
            ),
            IconButton(
              onPressed: () => _makeCall(user, CallMediaType.video),
              icon: Icon(
                Icons.videocam,
                color: Coloors.greenDark,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallHistoryItem(CallModel call) {
    final isOutgoing = call.callerId == currentUserId;
    final displayName = isOutgoing ? call.receiverName : call.callerName;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: context.customTheme.photoIconBgColor,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: TextStyle(
              color: context.customTheme.photoIconColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(
              call.callTypeIcon,
              color: call.callTypeColor,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              call.formattedTime,
              style: TextStyle(
                color: context.customTheme.greyColor,
                fontSize: 14,
              ),
            ),
            if (call.isAnswered && call.duration.inSeconds > 0) ...[
              const SizedBox(width: 8),
              Text(
                '• ${call.formattedDuration}',
                style: TextStyle(
                  color: context.customTheme.greyColor,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Telefon arama butonu - her zaman ilk
            IconButton(
              onPressed: () => _makeCall(
                UserModel(
                  uid: isOutgoing ? call.receiverId : call.callerId,
                  phoneNumber: '',
                  name: displayName,
                  createdAt: DateTime.now(),
                  isOnline: false,
                ),
                CallMediaType.voice,
              ),
              icon: Icon(
                Icons.call,
                color: call.mediaType == CallMediaType.voice ? Coloors.greenDark : context.customTheme.greyColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 8),
            // Video arama butonu - her zaman ikinci
            IconButton(
              onPressed: () => _makeCall(
                UserModel(
                  uid: isOutgoing ? call.receiverId : call.callerId,
                  phoneNumber: '',
                  name: displayName,
                  createdAt: DateTime.now(),
                  isOnline: false,
                ),
                CallMediaType.video,
              ),
              icon: Icon(
                Icons.videocam,
                color: call.mediaType == CallMediaType.video ? Coloors.greenDark : context.customTheme.greyColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 