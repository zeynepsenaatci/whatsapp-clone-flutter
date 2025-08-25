import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';
import 'package:whatsappnew/common/models/user_model.dart';
import 'package:whatsappnew/common/models/message_model.dart';
import 'package:whatsappnew/common/services/database_service.dart';
import 'package:whatsappnew/feature/chat/pages/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';

class HomeChatPage extends StatefulWidget {
  const HomeChatPage({super.key});

  @override
  State<HomeChatPage> createState() => _HomeChatPageState();
}

class _HomeChatPageState extends State<HomeChatPage> with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  List<UserModel> users = [];
  List<UserModel> filteredUsers = [];
  String? currentUserId;
  Map<String, int> unreadCounts = {};
  Map<String, MessageModel> lastMessages = {};
  StreamSubscription<DatabaseEvent>? _messagesSubscription;
  bool isLoading = true;
  bool isSearching = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _databaseService.initialize();
      await _loadCurrentUser();
      
      // Sohbet geçmişini temizle ve kullanıcı adlarını güncelle
      await _clearChatHistoryAndUpdateNames();
      
      await _loadUsers();
      _startRealtimeListener();
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

  // Sohbet geçmişini temizle ve kullanıcı adlarını güncelle
  Future<void> _clearChatHistoryAndUpdateNames() async {
    try {
      print('🧹 Sohbet geçmişi temizleniyor...');
      await _databaseService.deleteAllMessages();
      print('✅ Tüm mesajlar silindi');
    } catch (e) {
      print('❌ Sohbet geçmişi temizleme hatası: $e');
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
        print('✅ Chat sayfası - Kullanıcı adı: ${user.displayName}');
      } else {
        print('⚠️ Chat sayfası - Kullanıcı adı boş');
      }
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

  void _startRealtimeListener() {
    if (currentUserId == null) return;

    _messagesSubscription = FirebaseDatabase.instance
        .ref()
        .child('messages')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        final messagesData = event.snapshot.value as Map<dynamic, dynamic>;
        _updateUnreadCountsAndLastMessages(messagesData);
      }
    });
  }

  void _updateUnreadCountsAndLastMessages(Map<dynamic, dynamic> messagesData) {
    if (currentUserId == null) return;

    final newUnreadCounts = <String, int>{};
    final newLastMessages = <String, MessageModel>{};

    messagesData.forEach((key, value) {
      if (value is Map<dynamic, dynamic>) {
        final message = MessageModel.fromJson(Map<String, dynamic>.from(value));
        
        // Mesajın bu kullanıcıyla ilgili olup olmadığını kontrol et
        if (message.senderId == currentUserId || message.receiverId == currentUserId) {
          final otherUserId = message.senderId == currentUserId 
              ? message.receiverId 
              : message.senderId;
          
          // Son mesajı güncelle
          if (!newLastMessages.containsKey(otherUserId) ||
              message.timestamp.isAfter(newLastMessages[otherUserId]!.timestamp)) {
            newLastMessages[otherUserId] = message;
          }
          
          // Okunmamış mesaj sayısını hesapla
          if (message.receiverId == currentUserId && !message.isRead) {
            newUnreadCounts[otherUserId] = (newUnreadCounts[otherUserId] ?? 0) + 1;
          }
        }
      }
    });

    if (mounted) {
      setState(() {
        unreadCounts = newUnreadCounts;
        lastMessages = newLastMessages;
      });
    }
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

  void _showNewChatDialog() {
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
                      'Yeni sohbet',
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
            
            // Users list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserItem(user);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(UserModel user) {
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
      onTap: () {
        Navigator.of(context).pop();
        _navigateToChat(user);
      },
    );
  }

  void _navigateToChat(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(user: user),
      ),
    );
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf çekildi: ${image.path}')),
        );
      }
    } catch (e) {
      print('Kamera hatası: $e');
    }
  }





  Future<void> _markAllAsRead() async {
    if (currentUserId == null) return;

    try {
      // Tüm okunmamış mesajları okundu olarak işaretle
      for (final entry in unreadCounts.entries) {
        final otherUserId = entry.key;
        final count = entry.value;
        
        if (count > 0) {
          // Bu kullanıcıyla olan tüm mesajları al ve okundu olarak işaretle
          final messages = await _databaseService.getMessages(currentUserId!, otherUserId);
          for (final message in messages) {
            if (message.receiverId == currentUserId && !message.isRead) {
              await _databaseService.markMessageAsRead(message.id);
            }
          }
        }
      }
      
      // UI'yi güncelle
      setState(() {
        unreadCounts.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tüm mesajlar okundu olarak işaretlendi'),
          backgroundColor: Coloors.greenDark,
        ),
      );
    } catch (e) {
      print('Mesajları okundu işaretleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showChatOptions(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.customTheme.tabColor,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Colors.red,
              ),
              title: Text(
                'Sohbeti sil',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _deleteChat(user);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.block,
                color: context.customTheme.authAppbarTextColor,
              ),
              title: Text(
                'Engelle',
                style: TextStyle(color: context.customTheme.authAppbarTextColor),
              ),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Engelleme özelliği yakında eklenecek!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteChat(UserModel user) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.customTheme.tabColor,
        title: Text(
          'Sohbeti sil',
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '${user.name} ile olan sohbeti silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(color: context.customTheme.authAppbarTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'İptal',
              style: TextStyle(color: context.customTheme.greyColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performDeleteChat(user);
            },
            child: Text(
              'Sil',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteChat(UserModel user) async {
    if (currentUserId == null) return;

    try {
      // Bu kullanıcıyla olan tüm mesajları sil
      final messages = await _databaseService.getMessages(currentUserId!, user.uid);
      for (final message in messages) {
        await _databaseService.deleteMessage(message.id);
      }
      
      // UI'den kullanıcıyı kaldır
      setState(() {
        users.removeWhere((u) => u.uid == user.uid);
        filteredUsers.removeWhere((u) => u.uid == user.uid);
        unreadCounts.remove(user.uid);
        lastMessages.remove(user.uid);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} ile olan sohbet silindi'),
          backgroundColor: Coloors.greenDark,
        ),
      );
    } catch (e) {
      print('Sohbet silme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sohbet silinemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getLastMessageText(String userId) {
    final message = lastMessages[userId];
    if (message == null) return '';
    
    if (message.messageType == 'text') {
      return message.text;
    } else if (message.messageType == 'image') {
      return '📷 Fotoğraf';
    } else if (message.messageType == 'video') {
      return '🎥 Video';
    } else {
      return '📎 Dosya';
    }
  }

  String _getLastMessageTime(String userId) {
    final message = lastMessages[userId];
    if (message == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(message.timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} sa';
    } else {
      return '${difference.inDays} gün';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _messagesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.customTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Sohbetler',
          style: TextStyle(
            color: context.customTheme.authAppbarTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
              IconButton(
                onPressed: _openCamera,
                icon: Icon(
                  Icons.camera_alt,
                  color: context.customTheme.authAppbarTextColor,
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: _showNewChatDialog,
                icon: Icon(
                  Icons.add,
                  color: context.customTheme.authAppbarTextColor,
                  size: 24,
                ),
              ),
              
            ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Coloors.greenDark,
          labelColor: Coloors.greenDark,
          unselectedLabelColor: context.customTheme.greyColor,
          tabs: [
            Tab(text: 'Tümü'),
            Tab(text: 'Okunmamış ${unreadCounts.values.fold(0, (sum, count) => sum + count) > 0 ? '${unreadCounts.values.fold(0, (sum, count) => sum + count)}' : ''}'),
            Tab(text: 'Gruplar'),
            Tab(text: 'Kanallar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(users),
          _buildChatList(users.where((user) => unreadCounts[user.uid] != null && unreadCounts[user.uid]! > 0).toList()),
          _buildEmptyTab('Henüz grup yok', 'Grup oluşturmak için tıklayın'),
          _buildEmptyTab('Henüz kanal yok', 'Kanal oluşturmak için tıklayın'),
        ],
      ),
             floatingActionButton: FloatingActionButton(
         heroTag: "chat_new_button",
         onPressed: _showNewChatDialog,
         backgroundColor: Coloors.greenDark,
         child: const Icon(
           Icons.chat,
           color: Colors.white,
         ),
       ),
    );
  }

  Widget _buildChatList(List<UserModel> userList) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: context.customTheme.greyColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz sohbet yok',
              style: TextStyle(
                color: context.customTheme.greyColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni sohbet başlatmak için + butonuna tıklayın',
              style: TextStyle(
                color: context.customTheme.greyColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
          final user = userList[index];
          return _buildChatItem(user);
        },
      ),
    );
  }

  Widget _buildEmptyTab(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: context.customTheme.greyColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: context.customTheme.greyColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: context.customTheme.greyColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(UserModel user) {
    final unreadCount = unreadCounts[user.uid] ?? 0;
    final lastMessage = _getLastMessageText(user.uid);
    final lastMessageTime = _getLastMessageTime(user.uid);

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
        lastMessage.isNotEmpty ? lastMessage : 'Henüz mesaj yok',
        style: TextStyle(
          color: context.customTheme.greyColor,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            lastMessageTime,
            style: TextStyle(
              color: context.customTheme.greyColor,
              fontSize: 12,
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Coloors.greenDark,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () => _navigateToChat(user),
      onLongPress: () => _showChatOptions(user),
    );
  }
}


