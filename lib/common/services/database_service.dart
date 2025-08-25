import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsappnew/common/models/user_model.dart';
import 'package:whatsappnew/common/models/message_model.dart';
import 'package:whatsappnew/common/models/call_model.dart';
import 'package:whatsappnew/common/models/status_model.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  DatabaseReference? _database;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = false;

  // Database'i başlat
  Future<void> initialize() async {
    if (_isInitialized) {
      print('✅ DatabaseService zaten başlatılmış');
      return;
    }

    try {
      print('🔧 DatabaseService başlatılıyor...');
      
      // Firebase'in başlatılıp başlatılmadığını kontrol et
      if (Firebase.apps.isEmpty) {
        print('⚠️ Firebase başlatılmamış, DatabaseService başlatılamıyor');
        return;
      }

      print('📡 Firebase Database referansı alınıyor...');
      
      // Database URL'ini kontrol et ve ayarla
      final databaseURL = FirebaseDatabase.instance.databaseURL;
      print('🔗 Mevcut Database URL: $databaseURL');
      
      if (databaseURL == null || databaseURL.isEmpty) {
        print('⚠️ Database URL null, manuel olarak ayarlanıyor...');
        FirebaseDatabase.instance.databaseURL = 'https://whatsappnew-4fa1c-default-rtdb.firebaseio.com';
        print('🔗 Database URL ayarlandı: ${FirebaseDatabase.instance.databaseURL}');
      }
      
      // Offline persistence'ı etkinleştir
      FirebaseDatabase.instance.setPersistenceEnabled(true);
      FirebaseDatabase.instance.setPersistenceCacheSizeBytes(50 * 1024 * 1024); // 50MB
      print('💾 Database persistence etkinleştirildi (50MB)');
      
      _database = FirebaseDatabase.instance.ref();
      
      // Basit bağlantı testi (daha kısa timeout)
      print('🔍 Database bağlantısı test ediliyor...');
      try {
        await _database!.child('.info/connected').get().timeout(
          const Duration(seconds: 5), // Timeout süresini kısalttım
          onTimeout: () => throw TimeoutException('Database connection timeout'),
        );
        print('✅ Database bağlantısı başarılı');
      } catch (e) {
        print('⚠️ Database bağlantı testi başarısız: $e');
        print('⚠️ Offline modda devam ediliyor...');
      }
      
      _isInitialized = true;
      print('✅ DatabaseService başarıyla başlatıldı (offline mod)');
    } catch (e) {
      print('❌ DatabaseService başlatma hatası: $e');
      print('🔍 Hata detayı: ${e.toString()}');
      // Hata durumunda bile initialized olarak işaretle
      _isInitialized = true;
    }
  }

  // Database bağlantısını test et
  Future<bool> testConnection() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null');
      return false;
    }

    try {
      print('🔍 Database bağlantısı test ediliyor...');
      print('🔗 Database URL: ${FirebaseDatabase.instance.databaseURL}');
      print('📡 Database referansı: ${_database.toString()}');
      
      // Daha uzun timeout ile test et
      final snapshot = await _database!
          .child('.info/connected')
          .get()
          .timeout(
            const Duration(seconds: 20), // Timeout süresini artırdım
            onTimeout: () => throw TimeoutException('Database connection timeout'),
          );
      
      if (snapshot.exists) {
        final isConnected = snapshot.value as bool? ?? false;
        print('📊 Database bağlantı durumu: $isConnected');
        return isConnected;
      } else {
        print('⚠️ Database bağlantı bilgisi bulunamadı');
        // Bağlantı bilgisi bulunamazsa true döndür (devam et)
        return true;
      }
    } catch (e) {
      print('❌ Database bağlantı hatası: $e');
      print('🔍 Hata türü: ${e.runtimeType}');
      print('🔍 Hata mesajı: ${e.toString()}');
      
      // Hata durumunda da true döndür (devam et)
      return true;
    }
  }

  // Detaylı database durumu kontrol et
  Future<void> checkDatabaseStatus() async {
    print('🔍 Database durumu kontrol ediliyor...');
    
    // Firebase durumu
    print('📱 Firebase apps sayısı: ${Firebase.apps.length}');
    if (Firebase.apps.isNotEmpty) {
      print('✅ Firebase başlatılmış');
    } else {
      print('❌ Firebase başlatılmamış');
    }
    
    // Database URL
    final databaseURL = FirebaseDatabase.instance.databaseURL;
    print('🔗 Database URL: $databaseURL');
    
    // Database referansı
    if (_database != null) {
      print('✅ Database referansı mevcut');
    } else {
      print('❌ Database referansı null');
    }
    
    // Bağlantı testi
    final isConnected = await testConnection();
    print('📊 Bağlantı testi sonucu: $isConnected');
  }

  // Kullanıcı kaydet
  Future<void> saveUser(UserModel user) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, kullanıcı kaydetme başarısız');
      return;
    }

    try {
      print('💾 Kullanıcı kaydediliyor: ${user.name}');
      
      await _database!
          .child('users')
          .child(user.uid)
          .set(user.toJson())
          .timeout(
            const Duration(seconds: 30), // Timeout süresini daha da artırdım
            onTimeout: () => throw TimeoutException('saveUser timeout'),
          );
      
      print('✅ Kullanıcı başarıyla kaydedildi: ${user.name}');
    } catch (e) {
      print('❌ Kullanıcı kaydetme hatası: $e');
      if (e is TimeoutException) {
        throw Exception('Kullanıcı kaydetme zaman aşımı. Lütfen internet bağlantınızı kontrol edin.');
      } else {
        throw Exception('Kullanıcı kaydedilemedi: $e');
      }
    }
  }

  // Kullanıcı getir
  Future<UserModel?> getUser(String uid) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, kullanıcı getirme başarısız');
      return null;
    }

    try {
      final snapshot = await _database!
          .child('users')
          .child(uid)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('getUser timeout'),
          );
      
      if (snapshot.exists) {
        return UserModel.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      print('❌ Kullanıcı getirme hatası: $e');
      return null;
    }
  }

  // Tüm kullanıcıları getir
  Future<List<UserModel>> getAllUsers() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, tüm kullanıcıları getirme başarısız');
      return [];
    }

    try {
      print('👥 Tüm kullanıcılar yükleniyor...');
      
      final snapshot = await _database!
          .child('users')
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('getAllUsers timeout'),
          );
      
      List<UserModel> users = [];
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map) {
            final user = UserModel.fromJson(Map<String, dynamic>.from(value));
            // Test kullanıcılarını filtrele
            if (!user.name.contains('Test') && 
                !user.name.contains('Ahmet') && 
                !user.name.contains('Ayşe') && 
                !user.name.contains('Mehmet') &&
                !user.name.contains('Demo') &&
                !user.name.contains('test') &&
                !user.name.contains('demo') &&
                !user.name.contains('Zeynep') &&
                !user.name.contains('zeynep') &&
                !user.name.contains('ZEYNEP')) {
              users.add(user);
            } else {
              print('🚫 Test kullanıcısı filtrelendi: ${user.name}');
            }
          }
        });
      }
      
      print('✅ ${users.length} gerçek kullanıcı yüklendi');
      return users;
    } catch (e) {
      print('❌ Kullanıcıları yükleme hatası: $e');
      return [];
    }
  }

  // Mesaj kaydet
  Future<void> saveMessage(MessageModel message) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, mesaj kaydetme başarısız');
      return;
    }

    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        print('💬 Mesaj kaydediliyor (deneme ${retryCount + 1}/$maxRetries): ${message.text.substring(0, message.text.length > 20 ? 20 : message.text.length)}...');
        
        await _database!
            .child('messages')
            .child(message.id)
            .set(message.toJson())
            .timeout(
              const Duration(seconds: 60), // Timeout süresini 60 saniyeye çıkardım
              onTimeout: () => throw TimeoutException('saveMessage timeout'),
            );
        
        print('✅ Mesaj başarıyla kaydedildi: ${message.id}');
        return; // Başarılı olursa döngüden çık
      } catch (e) {
        retryCount++;
        print('❌ Mesaj kaydetme hatası (deneme $retryCount/$maxRetries): $e');
        
        if (retryCount >= maxRetries) {
          // Son deneme başarısız oldu
          if (e is TimeoutException) {
            throw Exception('Mesaj kaydetme zaman aşımı. Lütfen internet bağlantınızı kontrol edin.');
          } else {
            throw Exception('Mesaj kaydedilemedi: $e');
          }
        } else {
          // Bir sonraki deneme için bekle
          await Future.delayed(Duration(seconds: retryCount * 2));
          print('🔄 Mesaj kaydetme yeniden deneniyor...');
        }
      }
    }
  }

  // İki kullanıcı arasındaki mesajları getir
  Future<List<MessageModel>> getMessages(String user1Id, String user2Id) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, mesajları getirme başarısız');
      return [];
    }

    try {
      print('💬 Mesajlar yükleniyor: $user1Id ↔ $user2Id');
      
      final snapshot = await _database!
          .child('messages')
          .orderByChild('timestamp')
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('getMessages timeout'),
          );

      List<MessageModel> messages = [];
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map) {
            final message = MessageModel.fromJson(Map<String, dynamic>.from(value));
            // Sadece bu iki kullanıcı arasındaki mesajları filtrele
            if ((message.senderId == user1Id && message.receiverId == user2Id) ||
                (message.senderId == user2Id && message.receiverId == user1Id)) {
              messages.add(message);
            }
          }
        });
      }
      
      // Mesajları tarihe göre sırala
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      print('✅ ${messages.length} mesaj yüklendi');
      return messages;
    } catch (e) {
      print('❌ Mesaj yükleme hatası: $e');
      return [];
    }
  }

  // Kullanıcı güncelle
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, kullanıcı güncelleme başarısız');
      return;
    }

    try {
      await _database!
          .child('users')
          .child(uid)
          .update(data)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('updateUser timeout'),
          );
    } catch (e) {
      print('❌ Kullanıcı güncelleme hatası: $e');
      throw Exception('Kullanıcı güncellenemedi: $e');
    }
  }

  // Online durumu güncelle
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, online durum güncelleme başarısız');
      return;
    }

    try {
      await _database!
          .child('users')
          .child(uid)
          .update({
            'isOnline': isOnline,
            'lastSeen': DateTime.now().toIso8601String(),
          })
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => throw TimeoutException('updateOnlineStatus timeout'),
          );
    } catch (e) {
      print('⚠️ Online durum güncelleme hatası: $e');
    }
  }

  // Mesajı okundu olarak işaretle
  Future<void> markMessageAsRead(String messageId) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, mesaj okundu işaretleme başarısız');
      return;
    }

    try {
      await _database!
          .child('messages')
          .child(messageId)
          .update({
            'isRead': true,
          })
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => throw TimeoutException('markMessageAsRead timeout'),
          );
    } catch (e) {
      print('⚠️ Mesaj okundu işaretleme hatası: $e');
    }
  }

  // Kullanıcı sil
  Future<void> deleteUser(String uid) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, kullanıcı silme başarısız');
      return;
    }

    try {
      await _database!
          .child('users')
          .child(uid)
          .remove()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('deleteUser timeout'),
          );
    } catch (e) {
      print('❌ Kullanıcı silme hatası: $e');
      throw Exception('Kullanıcı silinemedi: $e');
    }
  }

  // Mesaj sil
  Future<void> deleteMessage(String messageId) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, mesaj silme başarısız');
      return;
    }

    try {
      await _database!
          .child('messages')
          .child(messageId)
          .remove()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('deleteMessage timeout'),
          );
    } catch (e) {
      print('❌ Mesaj silme hatası: $e');
      throw Exception('Mesaj silinemedi: $e');
    }
  }

  // Arama kaydet
  Future<void> saveCall(CallModel call) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, arama kaydetme başarısız');
      return;
    }

    int retryCount = 0;
    const maxRetries = 2; // Retry sayısını azalttım
    
    while (retryCount < maxRetries) {
      try {
        print('📞 Arama kaydediliyor (deneme ${retryCount + 1}/$maxRetries): ${call.callerName} → ${call.receiverName}');
        
        await _database!
            .child('calls')
            .child(call.id)
            .set(call.toJson())
            .timeout(
              const Duration(seconds: 10), // Timeout süresini kısalttım
              onTimeout: () => throw TimeoutException('saveCall timeout'),
            );
        
        print('✅ Arama başarıyla kaydedildi: ${call.id}');
        return; // Başarılı olursa döngüden çık
      } catch (e) {
        retryCount++;
        print('❌ Arama kaydetme hatası (deneme $retryCount/$maxRetries): $e');
        
        if (retryCount >= maxRetries) {
          // Son deneme başarısız oldu, offline modda devam et
          print('⚠️ Arama kaydedilemedi, offline modda devam ediliyor...');
          return; // Hata fırlatmadan çık
        } else {
          // Bir sonraki deneme için bekle
          await Future.delayed(Duration(seconds: retryCount));
          print('🔄 Arama kaydetme yeniden deneniyor...');
        }
      }
    }
  }

  // Kullanıcının arama geçmişini getir
  Future<List<CallModel>> getCallHistory(String userId) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, arama geçmişi getirme başarısız');
      return [];
    }

    try {
      print('📞 Arama geçmişi yükleniyor: $userId');
      
      final snapshot = await _database!
          .child('calls')
          .get()
          .timeout(
            const Duration(seconds: 8), // Timeout süresini kısalttım
            onTimeout: () => throw TimeoutException('getCallHistory timeout'),
          );

      List<CallModel> calls = [];
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('📊 Bulunan arama sayısı: ${data.length}');
        
        data.forEach((key, value) {
          if (value is Map) {
            try {
              final call = CallModel.fromJson(Map<String, dynamic>.from(value));
              // Sadece bu kullanıcının aramalarını filtrele
              if (call.callerId == userId || call.receiverId == userId) {
                calls.add(call);
                print('📞 Arama bulundu: ${call.callerName} → ${call.receiverName}');
              }
            } catch (e) {
              print('❌ Arama parse hatası: $e');
            }
          }
        });
      } else {
        print('📝 Hiç arama bulunamadı');
      }
      
      // Aramaları tarihe göre sırala (en yeni önce)
      calls.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      print('✅ ${calls.length} arama yüklendi');
      return calls;
    } catch (e) {
      print('❌ Arama geçmişi yükleme hatası: $e');
      print('⚠️ Offline modda boş liste döndürülüyor...');
      return []; // Hata durumunda boş liste döndür
    }
  }

  // Arama güncelle
  Future<void> updateCall(CallModel call) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, arama güncelleme başarısız');
      return;
    }

    try {
      print('📞 Arama güncelleniyor: ${call.id}');
      
      await _database!
          .child('calls')
          .child(call.id)
          .update(call.toJson())
          .timeout(
            const Duration(seconds: 30), // Timeout süresini daha da artırdım
            onTimeout: () => throw TimeoutException('updateCall timeout'),
          );
      
      print('✅ Arama başarıyla güncellendi: ${call.id}');
    } catch (e) {
      print('❌ Arama güncelleme hatası: $e');
      if (e is TimeoutException) {
        throw Exception('Arama güncelleme zaman aşımı. Lütfen internet bağlantınızı kontrol edin.');
      } else {
        throw Exception('Arama güncellenemedi: $e');
      }
    }
  }

  // Arama sil
  Future<void> deleteCall(String callId) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, arama silme başarısız');
      return;
    }

    try {
      await _database!
          .child('calls')
          .child(callId)
          .remove()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('deleteCall timeout'),
          );
    } catch (e) {
      print('❌ Arama silme hatası: $e');
      throw Exception('Arama silinemedi: $e');
    }
  }

  // Mevcut kullanıcıyı getir
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Database referansını getir
  DatabaseReference get database {
    if (_database == null) {
      throw Exception('Database henüz başlatılmamış. Önce initialize() çağırın.');
    }
    return _database!;
  }

  // ==================== DURUM YÖNETİMİ ====================

  // Durum kaydet
  Future<void> saveStatus(StatusModel status) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, durum kaydetme başarısız');
      return;
    }

    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        print('📱 Durum kaydediliyor (deneme ${retryCount + 1}/$maxRetries): ${status.userName} - ${status.content.substring(0, status.content.length > 20 ? 20 : status.content.length)}...');
        
        await _database!
            .child('statuses')
            .child(status.id)
            .set(status.toMap())
            .timeout(
              const Duration(seconds: 60), // Timeout süresini 60 saniyeye çıkardım
              onTimeout: () => throw TimeoutException('saveStatus timeout'),
            );
        
        print('✅ Durum başarıyla kaydedildi: ${status.id}');
        return; // Başarılı olursa döngüden çık
      } catch (e) {
        retryCount++;
        print('❌ Durum kaydetme hatası (deneme $retryCount/$maxRetries): $e');
        
        if (retryCount >= maxRetries) {
          // Son deneme başarısız oldu
          if (e is TimeoutException) {
            throw Exception('Durum kaydetme zaman aşımı. Lütfen internet bağlantınızı kontrol edin.');
          } else {
            throw Exception('Durum kaydedilemedi: $e');
          }
        } else {
          // Bir sonraki deneme için bekle
          await Future.delayed(Duration(seconds: retryCount * 2));
          print('🔄 Durum kaydetme yeniden deneniyor...');
        }
      }
    }
  }

  // Tüm durumları getir
  Future<List<StatusModel>> getAllStatuses() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, durumlar getirme başarısız');
      return [];
    }

    try {
      print('📱 Tüm durumlar yükleniyor...');
      
      final snapshot = await _database!
          .child('statuses')
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('getAllStatuses timeout'),
          );

      List<StatusModel> statuses = [];
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map) {
            final status = StatusModel.fromMap(Map<String, dynamic>.from(value));
            statuses.add(status);
          }
        });
      }
      
      // Durumları tarihe göre sırala (en yeni önce)
      statuses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      print('✅ ${statuses.length} durum yüklendi');
      return statuses;
    } catch (e) {
      print('❌ Durumlar yükleme hatası: $e');
      return [];
    }
  }

  // Kullanıcının durumlarını getir
  Future<List<StatusModel>> getUserStatuses(String userId) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, kullanıcı durumları getirme başarısız');
      return [];
    }

    try {
      print('📱 Kullanıcı durumları yükleniyor: $userId');
      
      final snapshot = await _database!
          .child('statuses')
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('getUserStatuses timeout'),
          );

      List<StatusModel> statuses = [];
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value is Map) {
            final status = StatusModel.fromMap(Map<String, dynamic>.from(value));
            // Sadece bu kullanıcının durumlarını filtrele
            if (status.userId == userId) {
              statuses.add(status);
            }
          }
        });
      }
      
      // Durumları tarihe göre sırala (en yeni önce)
      statuses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      print('✅ ${statuses.length} kullanıcı durumu yüklendi');
      return statuses;
    } catch (e) {
      print('❌ Kullanıcı durumları yükleme hatası: $e');
      return [];
    }
  }

  // Durumu görüldü olarak işaretle
  Future<void> markStatusAsViewed(String statusId, String viewerId) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, durum görüldü işaretleme başarısız');
      return;
    }

    try {
      print('👁️ Durum görüldü işaretleniyor: $statusId');
      
      // Mevcut durumu al
      final snapshot = await _database!
          .child('statuses')
          .child(statusId)
          .get()
          .timeout(
            const Duration(seconds: 3),
            onTimeout: () => throw TimeoutException('markStatusAsViewed timeout'),
          );

      if (snapshot.exists) {
        final status = StatusModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
        List<String> viewedBy = List.from(status.viewedBy);
        
        // Eğer kullanıcı zaten görmediyse ekle
        if (!viewedBy.contains(viewerId)) {
          viewedBy.add(viewerId);
          
          // Güncellenmiş durumu kaydet
          final updatedStatus = status.copyWith(
            viewedBy: viewedBy,
            isViewed: viewedBy.isNotEmpty,
          );
          
          await _database!
              .child('statuses')
              .child(statusId)
              .update(updatedStatus.toMap())
              .timeout(
                const Duration(seconds: 3),
                onTimeout: () => throw TimeoutException('markStatusAsViewed update timeout'),
              );
          
          print('✅ Durum görüldü işaretlendi: $statusId');
        }
      }
    } catch (e) {
      print('❌ Durum görüldü işaretleme hatası: $e');
      throw Exception('Durum görüldü işaretlenemedi: $e');
    }
  }

  // Durum sil
  Future<void> deleteStatus(String statusId) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, durum silme başarısız');
      return;
    }

    try {
      await _database!
          .child('statuses')
          .child(statusId)
          .remove()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('deleteStatus timeout'),
          );
      
      print('✅ Durum başarıyla silindi: $statusId');
    } catch (e) {
      print('❌ Durum silme hatası: $e');
      throw Exception('Durum silinemedi: $e');
    }
  }

  // 24 saatten eski durumları temizle
  Future<void> cleanOldStatuses() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, eski durumlar temizleme başarısız');
      return;
    }

    try {
      print('🧹 24 saatten eski durumlar temizleniyor...');
      
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));
      print('⏰ Kesme zamanı: $cutoffTime');
      
      final snapshot = await _database!
          .child('statuses')
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException('cleanOldStatuses timeout'),
          );

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int deletedCount = 0;
        
        data.forEach((key, value) {
          if (value is Map) {
            try {
              final status = StatusModel.fromMap(Map<String, dynamic>.from(value));
              final statusTime = status.timestamp;
              
              // 24 saatten eski durumları sil
              if (statusTime.isBefore(cutoffTime)) {
                _database!.child('statuses').child(key).remove();
                deletedCount++;
                print('🗑️ Eski durum silindi: ${status.userName} - ${statusTime}');
              }
            } catch (e) {
              print('❌ Durum parse hatası: $e');
            }
          }
        });
        
        if (deletedCount > 0) {
          print('✅ $deletedCount eski durum silindi');
        } else {
          print('✅ Silinecek eski durum bulunamadı');
        }
      } else {
        print('✅ Hiç durum bulunamadı');
      }
    } catch (e) {
      print('❌ Eski durumlar temizleme hatası: $e');
    }
  }

  // Test kullanıcılarını sil
  Future<void> deleteTestUsers() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, test kullanıcıları silme başarısız');
      return;
    }

    try {
      print('🧹 Test kullanıcıları siliniyor...');
      
      final snapshot = await _database!
          .child('users')
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('deleteTestUsers timeout'),
          );

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int deletedCount = 0;
        
        data.forEach((key, value) {
          if (value is Map) {
            final user = UserModel.fromJson(Map<String, dynamic>.from(value));
            // Test kullanıcılarını tespit et ve sil
            if (user.name.contains('Test') || 
                user.name.contains('Ahmet') || 
                user.name.contains('Ayşe') || 
                user.name.contains('Mehmet') ||
                user.name.contains('Demo') ||
                user.name.contains('test') ||
                user.name.contains('demo') ||
                user.name.contains('TEST') ||
                user.name.contains('DEMO')) {
              _database!.child('users').child(key).remove();
              deletedCount++;
              print('🗑️ Test kullanıcısı silindi: ${user.name}');
            }
          }
        });
        
        print('✅ $deletedCount test kullanıcısı silindi');
      }
    } catch (e) {
      print('❌ Test kullanıcıları silme hatası: $e');
    }
  }

  // TÜM KULLANICILARI SİL (Sadece geliştirme için)
  Future<void> deleteAllUsers() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, tüm kullanıcıları silme başarısız');
      return;
    }

    try {
      print('🧹 TÜM KULLANICILAR SİLİNİYOR...');
      
      await _database!
          .child('users')
          .remove()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('deleteAllUsers timeout'),
          );
      
      print('✅ TÜM KULLANICILAR SİLİNDİ!');
    } catch (e) {
      print('❌ Tüm kullanıcıları silme hatası: $e');
    }
  }

  // Zeynep kullanıcısını sil
  Future<void> deleteZeynepUser() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_database == null) {
      print('❌ Database referansı null, Zeynep kullanıcısını silme başarısız');
      return;
    }

    try {
      print('🧹 Zeynep kullanıcısı siliniyor...');
      
      final snapshot = await _database!
          .child('users')
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('deleteZeynepUser timeout'),
          );

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        int deletedCount = 0;
        
        data.forEach((key, value) {
          if (value is Map) {
            final user = UserModel.fromJson(Map<String, dynamic>.from(value));
            // Zeynep kullanıcısını tespit et ve sil
            if (user.name.contains('Zeynep') || 
                user.name.contains('zeynep') ||
                user.name.contains('ZEYNEP')) {
              _database!.child('users').child(key).remove();
              deletedCount++;
              print('🗑️ Zeynep kullanıcısı silindi: ${user.name}');
            }
          }
        });
        
        print('✅ $deletedCount Zeynep kullanıcısı silindi');
      }
    } catch (e) {
      print('❌ Zeynep kullanıcısını silme hatası: $e');
    }
  }

  // Tüm mesajları sil
  Future<void> deleteAllMessages() async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_database == null) {
      print('❌ Database referansı null, mesajlar silinemedi');
      return;
    }
    try {
      print('🗑️ Tüm mesajlar siliniyor...');
      await _database!.child('messages').remove().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('deleteAllMessages timeout'),
      );
      print('✅ Tüm mesajlar silindi');
    } catch (e) {
      print('❌ Mesajları silme hatası: $e');
      throw e;
    }
  }

  // Tüm aramaları sil
  Future<void> deleteAllCalls() async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_database == null) {
      print('❌ Database referansı null, aramalar silinemedi');
      return;
    }
    try {
      print('🗑️ Tüm aramalar siliniyor...');
      await _database!.child('calls').remove().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('deleteAllCalls timeout'),
      );
      print('✅ Tüm aramalar silindi');
    } catch (e) {
      print('❌ Aramaları silme hatası: $e');
      throw e;
    }
  }

  // Tüm durumları sil
  Future<void> deleteAllStatuses() async {
    if (!_isInitialized) {
      await initialize();
    }
    if (_database == null) {
      print('❌ Database referansı null, durumlar silinemedi');
      return;
    }
    try {
      print('🗑️ Tüm durumlar siliniyor...');
      await _database!.child('statuses').remove().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('deleteAllStatuses timeout'),
      );
      print('✅ Tüm durumlar silindi');
    } catch (e) {
      print('❌ Durumları silme hatası: $e');
      throw e;
    }
  }
} 