import 'package:flutter/material.dart';

enum AuditLogType {
  stockAdded,
  stockUpdated,
  stockRemoved,
  alertGenerated,
  medicineAdded,
  medicineDeleted,
  thresholdChanged
}

class AuditLog {
  final String id;
  final AuditLogType type;
  final String medicineName;
  final String details;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final String pharmacyId;

  AuditLog({
    required this.id,
    required this.type,
    required this.medicineName,
    required this.details,
    required this.userId,
    required this.userName,
    required this.timestamp,
    required this.pharmacyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'medicineName': medicineName,
      'details': details,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp,
      'pharmacyId': pharmacyId,
    };
  }

  factory AuditLog.fromMap(Map<String, dynamic> map, String documentId) {
    return AuditLog(
      id: documentId,
      type: AuditLogType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => AuditLogType.stockUpdated,
      ),
      medicineName: map['medicineName'] ?? '',
      details: map['details'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      timestamp: (map['timestamp'] as dynamic).toDate(),
      pharmacyId: map['pharmacyId'] ?? '',
    );
  }

  String get typeLabel {
    switch (type) {
      case AuditLogType.stockAdded:
        return 'Stock Added';
      case AuditLogType.stockUpdated:
        return 'Stock Updated';
      case AuditLogType.stockRemoved:
        return 'Stock Removed';
      case AuditLogType.alertGenerated:
        return 'Alert Generated';
      case AuditLogType.medicineAdded:
        return 'Medicine Added';
      case AuditLogType.medicineDeleted:
        return 'Medicine Deleted';
      case AuditLogType.thresholdChanged:
        return 'Threshold Changed';
    }
  }

  IconData get icon {
    switch (type) {
      case AuditLogType.stockAdded:
      case AuditLogType.medicineAdded:
        return Icons.add_circle_outline;
      case AuditLogType.stockUpdated:
      case AuditLogType.thresholdChanged:
        return Icons.edit;
      case AuditLogType.stockRemoved:
      case AuditLogType.medicineDeleted:
        return Icons.remove_circle_outline;
      case AuditLogType.alertGenerated:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (type) {
      case AuditLogType.stockAdded:
      case AuditLogType.medicineAdded:
        return Colors.teal;
      case AuditLogType.stockUpdated:
      case AuditLogType.thresholdChanged:
        return Colors.orange;
      case AuditLogType.stockRemoved:
      case AuditLogType.medicineDeleted:
        return Colors.red;
      case AuditLogType.alertGenerated:
        return Colors.amber;
    }
  }
}
