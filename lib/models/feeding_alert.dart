import 'package:flutter/material.dart';

enum AlertLevel {
  low,
  warning,
  critical,
}

class FeedingAlert {
  final String id;
  final String farmId;
  final String? pigId;
  final DateTime alertDate;
  final DateTime createdAt;
  final String message;
  final AlertLevel level;
  final bool isRead;

  FeedingAlert({
    required this.id,
    required this.farmId,
    this.pigId,
    required this.alertDate,
    required this.message,
    required this.level,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'pigId': pigId,
      'alertDate': alertDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'message': message,
      'level': level.name,
      'isRead': isRead,
    };
  }

  factory FeedingAlert.fromJson(Map<String, dynamic> json) {
    return FeedingAlert(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      pigId: json['pigId'] as String?,
      alertDate: DateTime.parse(json['alertDate'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      message: json['message'] as String,
      level: AlertLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => AlertLevel.low,
      ),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  // Getters para compatibilidad
  Color get levelColor {
    switch (level) {
      case AlertLevel.low:
        return Colors.blue;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.critical:
        return Colors.red;
    }
  }

  IconData get levelIcon {
    switch (level) {
      case AlertLevel.low:
        return Icons.info;
      case AlertLevel.warning:
        return Icons.warning;
      case AlertLevel.critical:
        return Icons.error;
    }
  }

  String get levelString {
    switch (level) {
      case AlertLevel.low:
        return 'Baja';
      case AlertLevel.warning:
        return 'Advertencia';
      case AlertLevel.critical:
        return 'Crítica';
    }
  }
}




