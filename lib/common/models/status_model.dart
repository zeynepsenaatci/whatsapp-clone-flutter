class StatusModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String type; // 'text', 'image', 'video'
  final String content;
  final DateTime timestamp;
  final bool isViewed;
  final List<String> viewedBy; // Hangi kullanıcılar gördü

  StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isViewed = false,
    this.viewedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'type': type,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isViewed': isViewed,
      'viewedBy': viewedBy,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map) {
    return StatusModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'] ?? '',
      type: map['type'] ?? 'text',
      content: map['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isViewed: map['isViewed'] ?? false,
      viewedBy: List<String>.from(map['viewedBy'] ?? []),
    );
  }

  StatusModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImage,
    String? type,
    String? content,
    DateTime? timestamp,
    bool? isViewed,
    List<String>? viewedBy,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      type: type ?? this.type,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isViewed: isViewed ?? this.isViewed,
      viewedBy: viewedBy ?? this.viewedBy,
    );
  }
}
