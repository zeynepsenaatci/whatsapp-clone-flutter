import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';
import 'package:whatsappnew/common/models/status_model.dart';
import 'package:whatsappnew/common/models/user_model.dart';
import 'package:whatsappnew/common/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final DatabaseService _databaseService = DatabaseService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _searchController = TextEditingController();

  List<StatusModel> allStatuses = [];
  List<StatusModel> myStatuses = [];
  List<StatusModel> otherStatuses = [];
  List<StatusModel> filteredStatuses = [];
  String? currentUserId;
  String currentUserName = 'Ben';
  bool isLoading = true;
  bool isSearching = false;
  Timer? _cleanupTimer; // Eski durumları temizlemek için timer

  @override
  void initState() {
    super.initState();
    _loadData();
    _startCleanupTimer();
  }

  // Periyodik olarak eski durumları temizle
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _cleanOldStatuses();
    });
  }

  // Eski durumları temizle
  Future<void> _cleanOldStatuses() async {
    try {
      await _databaseService.cleanOldStatuses();
      // Durumları yeniden yükle
      await _loadAllStatuses();
      _organizeStatuses();
    } catch (e) {
      print('❌ Eski durumları temizleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      await _databaseService.initialize();
      await _loadCurrentUser();
      
      // Eski durumları temizle ve kullanıcı adını düzelt
      await _clearOldStatusesAndFixName();
      
      await _loadAllStatuses();
      _organizeStatuses();
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

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
        currentUserName = user.displayName ?? 'Ben';
      });
      
      // Kullanıcı adını kontrol et
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        print('✅ Status sayfası - Kullanıcı adı: ${user.displayName}');
      } else {
        print('⚠️ Status sayfası - Kullanıcı adı boş');
      }
      
      // Database'deki kullanıcı bilgilerini kontrol et
      await _checkAndUpdateUserInDatabase(user.uid);
    }
  }

  // Database'deki kullanıcı bilgilerini kontrol et ve güncelle
  Future<void> _checkAndUpdateUserInDatabase(String uid) async {
    try {
      final userInfo = await _databaseService.getUser(uid);
      if (userInfo != null) {
        // Database'deki isim ile Auth'daki isim farklıysa güncelle
        if (userInfo.name != currentUserName) {
          await _databaseService.updateUser(uid, {
            'name': currentUserName,
          });
          print('✅ Database kullanıcı adı güncellendi: $currentUserName');
        }
      }
    } catch (e) {
      print('❌ Database kullanıcı kontrol hatası: $e');
    }
  }

  Future<void> _loadAllStatuses() async {
    try {
      // Önce eski durumları temizle
      await _databaseService.cleanOldStatuses();
      
      final statuses = await _databaseService.getAllStatuses();
      print('📱 Yüklenen durum sayısı: ${statuses.length}');

      if (mounted) {
        setState(() {
          allStatuses = statuses;
        });
      }

      // Eğer hiç durum yoksa boş liste göster
      if (statuses.isEmpty) {
        print('📝 Hiç durum bulunamadı');
      }
    } catch (e) {
      print('Durum yükleme hatası: $e');
    }
  }



  void _organizeStatuses() {
    if (currentUserId == null) {
      print('❌ currentUserId null, durumlar organize edilemiyor');
      return;
    }

    print('📊 Durum organizasyonu:');
    print('   - Toplam durum: ${allStatuses.length}');
    print('   - Mevcut kullanıcı ID: $currentUserId');

    myStatuses = allStatuses
        .where((status) => status.userId == currentUserId)
        .toList();
    otherStatuses = allStatuses
        .where((status) => status.userId != currentUserId)
        .toList();
    filteredStatuses = otherStatuses;

    print('   - Benim durumlarım: ${myStatuses.length}');
    print('   - Diğer kullanıcıların durumları: ${otherStatuses.length}');
    print('   - Filtrelenmiş durumlar: ${filteredStatuses.length}');
  }

  void _onSearchChanged(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredStatuses = allStatuses; // Tüm durumları göster
      } else {
        filteredStatuses = allStatuses
            .where(
              (status) =>
                  status.userName.toLowerCase().contains(query.toLowerCase()) ||
                  status.content.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<String?> _showTextInputDialog() async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          backgroundColor: context.customTheme.tabColor,
          title: Text(
            'Metin Durumu',
            style: TextStyle(
              color: context.customTheme.authAppbarTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            style: TextStyle(color: context.customTheme.authAppbarTextColor),
            decoration: InputDecoration(
              hintText: 'Durumunuzu yazın...',
              hintStyle: TextStyle(color: context.customTheme.greyColor),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                'İptal',
                style: TextStyle(color: context.customTheme.greyColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: Text(
                'Paylaş',
                style: TextStyle(
                  color: Coloors.greenDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTextStatus() async {
    if (currentUserId == null) return;

    // Kullanıcı adını güncelle
    await _updateCurrentUserName();

    final text = await _showTextInputDialog();
    if (text == null || text.trim().isEmpty) return;

    final status = StatusModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUserId!,
      userName: currentUserName,
      userImage: '',
      type: 'text',
      content: text,
      timestamp: DateTime.now(),
    );

    try {
      await _databaseService.saveStatus(status);
      await _loadAllStatuses();
      _organizeStatuses();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Durum paylaşıldı: $currentUserName'),
          backgroundColor: Coloors.greenDark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Durum paylaşılamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Kullanıcı adını güncelle
  Future<void> _updateCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      setState(() {
        currentUserName = user.displayName!;
      });
      print('✅ Kullanıcı adı güncellendi: $currentUserName');
    }
  }

  // Eski durumları temizle ve kullanıcı adını düzelt
  Future<void> _clearOldStatusesAndFixName() async {
    try {
      print('🧹 Eski durumlar temizleniyor...');
      await _databaseService.deleteAllStatuses();
      print('✅ Tüm durumlar silindi');
      
      // Kullanıcı adını güncelle
      setState(() {
        currentUserName = 'aaaaaaa';
      });
      print('✅ Kullanıcı adı düzeltildi: aaaaaaa');
    } catch (e) {
      print('❌ Durum temizleme hatası: $e');
    }
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        await _saveImageStatus(image.path);
      }
    } catch (e) {
      print('Kamera hatası: $e');
    }
  }

  Future<void> _openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _saveImageStatus(image.path);
      }
    } catch (e) {
      print('Galeri hatası: $e');
    }
  }

  Future<void> _saveImageStatus(String imagePath) async {
    if (currentUserId == null) return;

    // Kullanıcı adını güncelle
    await _updateCurrentUserName();

    final status = StatusModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUserId!,
      userName: currentUserName,
      userImage: '',
      type: 'image',
      content: imagePath,
      timestamp: DateTime.now(),
    );

    try {
      await _databaseService.saveStatus(status);
      await _loadAllStatuses();
      _organizeStatuses();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf durumu paylaşıldı: $currentUserName'),
          backgroundColor: Coloors.greenDark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf paylaşılamadı: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _viewStatus(StatusModel status) async {
    // Durumu görüldü olarak işaretle
    if (currentUserId != null && !status.viewedBy.contains(currentUserId!)) {
      try {
        await _databaseService.markStatusAsViewed(status.id, currentUserId!);
        await _loadAllStatuses();
        _organizeStatuses();
      } catch (e) {
        print('Durum görüldü işaretleme hatası: $e');
      }
    }

    _showStatusDetail(status);
  }

  void _showStatusDetail(StatusModel status) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.customTheme.tabColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: context.customTheme.photoIconBgColor,
              child: Text(
                status.userName.isNotEmpty
                    ? status.userName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: context.customTheme.photoIconColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.userName,
                    style: TextStyle(
                      color: context.customTheme.authAppbarTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatTime(status.timestamp),
                    style: TextStyle(
                      color: context.customTheme.greyColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: status.type == 'text'
            ? Text(
                status.content,
                style: TextStyle(
                  color: context.customTheme.authAppbarTextColor,
                  fontSize: 16,
                ),
              )
            : Image.file(File(status.content), fit: BoxFit.cover),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Kapat', style: TextStyle(color: Coloors.greenDark)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.customTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Güncellemeler',
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
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Arama çubuğu
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.customTheme.tabColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  color: context.customTheme.authAppbarTextColor,
                ),
                decoration: InputDecoration(
                  hintText: 'Ara...',
                  hintStyle: TextStyle(color: context.customTheme.greyColor),
                  prefixIcon: Icon(
                    Icons.search,
                    color: context.customTheme.greyColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Ana içerik
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _buildMyStatusSection(),
                    const SizedBox(height: 16),
                    _buildOtherStatusesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "status_edit_button",
            onPressed: _addTextStatus,
            backgroundColor: context.customTheme.tabColor,
            mini: true,
            child: Icon(
              Icons.edit,
              color: context.customTheme.authAppbarTextColor,
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "status_add_button",
            onPressed: _showMediaOptions,
            backgroundColor: Coloors.greenDark,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showMediaOptions() {
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
                Icons.camera_alt,
                color: context.customTheme.authAppbarTextColor,
              ),
              title: Text(
                'Kamera',
                style: TextStyle(
                  color: context.customTheme.authAppbarTextColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _openCamera();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: context.customTheme.authAppbarTextColor,
              ),
              title: Text(
                'Galeri',
                style: TextStyle(
                  color: context.customTheme.authAppbarTextColor,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _openGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyStatusSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Durumum',
            style: TextStyle(
              color: context.customTheme.authAppbarTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _addTextStatus,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.customTheme.tabColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      context.customTheme.greyColor?.withOpacity(0.3) ??
                      Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: context.customTheme.photoIconBgColor,
                    child: Text(
                      currentUserName.isNotEmpty
                          ? currentUserName[0].toUpperCase()
                          : 'B',
                      style: TextStyle(
                        color: context.customTheme.photoIconColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Durum ekle',
                          style: TextStyle(
                            color: context.customTheme.authAppbarTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Durumunuzu paylaşın',
                          style: TextStyle(
                            color: context.customTheme.greyColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherStatusesSection() {
    // Görülen güncellemeler için tüm durumları göster (kendi durumlarınız dahil)
    final statusesToShow = isSearching ? filteredStatuses : allStatuses;

    if (statusesToShow.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Görülen güncellemeler',
              style: TextStyle(
                color: context.customTheme.authAppbarTextColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                isSearching ? 'Arama sonucu bulunamadı' : 'Henüz durum yok',
                style: TextStyle(
                  color: context.customTheme.greyColor,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Görülen güncellemeler',
            style: TextStyle(
              color: context.customTheme.authAppbarTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...statusesToShow.map((status) => _buildStatusItem(status)),
        ],
      ),
    );
  }

  Widget _buildStatusItem(StatusModel status) {
    return GestureDetector(
      onTap: () => _viewStatus(status),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.customTheme.tabColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: status.viewedBy.contains(currentUserId)
                ? context.customTheme.greyColor?.withOpacity(0.3) ??
                      Colors.grey.withOpacity(0.3)
                : Coloors.greenDark.withOpacity(0.5),
            width: status.viewedBy.contains(currentUserId) ? 1 : 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: context.customTheme.photoIconBgColor,
              child: Text(
                status.userName.isNotEmpty
                    ? status.userName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: context.customTheme.photoIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.userName,
                    style: TextStyle(
                      color: context.customTheme.authAppbarTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatTime(status.timestamp),
                    style: TextStyle(
                      color: context.customTheme.greyColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              status.type == 'text' ? Icons.text_fields : Icons.image,
              color: context.customTheme.greyColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
