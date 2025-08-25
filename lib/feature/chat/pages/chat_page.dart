import 'package:flutter/material.dart';
import 'package:whatsappnew/common/extension/custom_theme_extension.dart';
import 'package:whatsappnew/common/utils/coloors.dart';
import 'package:whatsappnew/common/models/user_model.dart';
import 'package:whatsappnew/common/models/message_model.dart';
import 'package:whatsappnew/common/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'dart:async';

class ChatPage extends StatefulWidget {
  final UserModel user;

  const ChatPage({
    super.key,
    required this.user,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final ScrollController _scrollController = ScrollController();
  
  List<MessageModel> messages = [];
  bool isLoading = true;
  String? currentUserId;
  StreamSubscription<DatabaseEvent>? _messageSubscription;
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    try {
      // DatabaseService'i başlat
      await _databaseService.initialize();
      await _loadCurrentUser();
      await _loadMessages();
      _startRealtimeListener();
    } catch (e) {
      print('DatabaseService başlatma hatası: $e');
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
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      if (currentUserId != null) {
        final loadedMessages = await _databaseService.getMessages(
          currentUserId!,
          widget.user.uid,
        ).timeout(
          const Duration(seconds: 3),
          onTimeout: () => <MessageModel>[],
        );
        
        if (mounted) {
          setState(() {
            messages = loadedMessages;
            isLoading = false;
          });
          _scrollToBottom();
          
          // Gelen mesajları okundu olarak işaretle
          _markMessagesAsRead();
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Mesaj yükleme hatası: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _startRealtimeListener() {
    if (currentUserId == null) return;

    try {
      final database = FirebaseDatabase.instance;
      final messagesRef = database.ref('messages');
      
      _messageSubscription = messagesRef
          .orderByChild('timestamp')
          .onValue
          .listen((DatabaseEvent event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final newMessages = <MessageModel>[];
          
          data.forEach((key, value) {
            if (value is Map) {
              final message = MessageModel.fromJson(Map<String, dynamic>.from(value));
              
              // Sadece bu sohbetin mesajlarını al
              if ((message.senderId == currentUserId && message.receiverId == widget.user.uid) ||
                  (message.senderId == widget.user.uid && message.receiverId == currentUserId)) {
                newMessages.add(message);
              }
            }
          });
          
          // Mesajları tarihe göre sırala
          newMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          if (mounted) {
            setState(() {
              messages = newMessages;
            });
            _scrollToBottom();
            _markMessagesAsRead();
          }
        }
      });
    } catch (e) {
      print('Gerçek zamanlı dinleme hatası: $e');
    }
  }

  Future<void> _markMessagesAsRead() async {
    if (currentUserId == null) return;

    try {
      for (final message in messages) {
        if (message.senderId == widget.user.uid && 
            message.receiverId == currentUserId && 
            !message.isRead) {
          await _databaseService.markMessageAsRead(message.id);
        }
      }
    } catch (e) {
      print('Mesaj okundu işaretleme hatası: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTypingChanged(String text) {
    if (!_isTyping && text.isNotEmpty) {
      setState(() {
        _isTyping = true;
      });
      _sendTypingStatus(true);
    } else if (_isTyping && text.isEmpty) {
      setState(() {
        _isTyping = false;
      });
      _sendTypingStatus(false);
    }

    // Typing timer'ı sıfırla
    _typingTimer?.cancel();
    if (text.isNotEmpty) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
          });
          _sendTypingStatus(false);
        }
      });
    }
  }

  void _sendTypingStatus(bool isTyping) {
    if (currentUserId == null) return;

    try {
      final database = FirebaseDatabase.instance;
      final typingRef = database.ref('typing').child('${currentUserId}_${widget.user.uid}');
      
      if (isTyping) {
        typingRef.set({
          'isTyping': true,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      } else {
        typingRef.remove();
      }
    } catch (e) {
      print('Typing status gönderme hatası: $e');
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || currentUserId == null) return;

    // Typing durumunu sıfırla
    _onTypingChanged('');

    // Mesaj gönderme öncesi database bağlantısını test et
    bool isConnected = false;
    try {
      isConnected = await _databaseService.testConnection().timeout(
        const Duration(seconds: 2),
        onTimeout: () => true, // Timeout durumunda da devam et
      );
    } catch (e) {
      print('Database bağlantı testi başarısız: $e');
      isConnected = true; // Hata durumunda da devam et
    }

    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İnternet bağlantısı yok. Mesaj gönderilemedi.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId!,
      receiverId: widget.user.uid,
      text: messageText,
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      // UI'yi hemen güncelle (optimistic update)
      setState(() {
        messages.add(message);
      });
      
      _messageController.clear();
      _scrollToBottom();
      
      // Mesajı Firebase'e kaydet
      await _databaseService.saveMessage(message).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('saveMessage timeout'),
      );
      print('Mesaj başarıyla gönderildi');
      
    } catch (e) {
      print('Mesaj gönderme hatası: $e');
      
      // Hata durumunda mesajı geri al
      setState(() {
        messages.removeLast();
      });
      
      String errorMessage = 'Mesaj gönderilemedi';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Bağlantı zaman aşımı. Lütfen internet bağlantınızı kontrol edin.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Yetki hatası. Lütfen tekrar giriş yapın.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Ağ bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Tekrar Dene',
            textColor: Colors.white,
            onPressed: () => _sendMessage(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageSubscription?.cancel();
    _typingTimer?.cancel();
    _sendTypingStatus(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.customTheme.backgroundColor ?? Colors.white,
      appBar: AppBar(
        backgroundColor: context.customTheme.backgroundColor ?? Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.customTheme.authAppbarTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: context.customTheme.photoIconBgColor,
              child: Text(
                widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: context.customTheme.photoIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name,
                    style: TextStyle(
                      color: context.customTheme.authAppbarTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_isTyping)
                    Text(
                      'yazıyor...',
                      style: TextStyle(
                        color: context.customTheme.greyColor,
                        fontSize: 12,
                      ),
                    )
                  else
                    Text(
                      widget.user.isOnline ? 'çevrimiçi' : 'çevrimdışı',
                      style: TextStyle(
                        color: widget.user.isOnline ? Colors.green : context.customTheme.greyColor,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.call,
              color: context.customTheme.authAppbarTextColor,
            ),
            onPressed: () {
              // Arama özelliği
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Arama özelliği yakında eklenecek!')),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: context.customTheme.authAppbarTextColor,
            ),
            onPressed: () {
              // Görüntülü arama özelliği
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Görüntülü arama özelliği yakında eklenecek!')),
              );
            },
          ),

        ],
      ),
      body: Column(
        children: [
          // Mesajlar listesi
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(
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
                              'Henüz mesaj yok',
                              style: TextStyle(
                                color: context.customTheme.greyColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'İlk mesajı siz gönderin!',
                              style: TextStyle(
                                color: context.customTheme.greyColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == currentUserId;
                          
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),
          
          // Mesaj gönderme alanı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.customTheme.backgroundColor ?? Colors.white,
              border: Border(
                top: BorderSide(
                  color: context.customTheme.greyColor!.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: context.customTheme.greyColor,
                  ),
                  onPressed: () {
                    // Dosya ekleme özelliği
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dosya ekleme özelliği yakında eklenecek!')),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: _onTypingChanged,
                    style: TextStyle(
                      color: context.customTheme.authAppbarTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Mesaj yazın...',
                      hintStyle: TextStyle(
                        color: context.customTheme.greyColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: context.customTheme.tabColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Coloors.greenDark,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: context.customTheme.photoIconBgColor,
              child: Text(
                widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: context.customTheme.photoIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe 
                    ? Coloors.greenDark 
                    : context.customTheme.tabColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : context.customTheme.authAppbarTextColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isMe 
                              ? Colors.white.withOpacity(0.7) 
                              : context.customTheme.greyColor,
                          fontSize: 12,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 16,
                          color: message.isRead 
                              ? Colors.blue 
                              : Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
