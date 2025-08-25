import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum CallType {
  incoming,
  outgoing,
  missed,
}

enum CallMediaType {
  voice,
  video,
}

class CallModel {
  final String id;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String receiverName;
  final DateTime timestamp;
  final Duration duration;
  final CallType callType;
  final CallMediaType mediaType;
  final bool isAnswered;

  CallModel({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    required this.receiverName,
    required this.timestamp,
    required this.duration,
    required this.callType,
    required this.mediaType,
    required this.isAnswered,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'receiverName': receiverName,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration.inSeconds,
      'callType': callType.name,
      'mediaType': mediaType.name,
      'isAnswered': isAnswered,
    };
  }

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      id: json['id'] ?? '',
      callerId: json['callerId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      callerName: json['callerName'] ?? '',
      receiverName: json['receiverName'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      duration: Duration(seconds: json['duration'] ?? 0),
      callType: CallType.values.firstWhere(
        (e) => e.name == json['callType'],
        orElse: () => CallType.outgoing,
      ),
      mediaType: CallMediaType.values.firstWhere(
        (e) => e.name == json['mediaType'],
        orElse: () => CallMediaType.voice,
      ),
      isAnswered: json['isAnswered'] ?? false,
    );
  }

  CallModel copyWith({
    String? id,
    String? callerId,
    String? receiverId,
    String? callerName,
    String? receiverName,
    DateTime? timestamp,
    Duration? duration,
    CallType? callType,
    CallMediaType? mediaType,
    bool? isAnswered,
  }) {
    return CallModel(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      callerName: callerName ?? this.callerName,
      receiverName: receiverName ?? this.receiverName,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      callType: callType ?? this.callType,
      mediaType: mediaType ?? this.mediaType,
      isAnswered: isAnswered ?? this.isAnswered,
    );
  }

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  IconData get callTypeIcon {
    switch (callType) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
    }
  }

  Color get callTypeColor {
    switch (callType) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.green;
      case CallType.missed:
        return Colors.red;
    }
  }

  IconData get mediaTypeIcon {
    switch (mediaType) {
      case CallMediaType.voice:
        return Icons.call;
      case CallMediaType.video:
        return Icons.videocam;
    }
  }
}
