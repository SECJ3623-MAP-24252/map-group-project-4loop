import 'package:cloud_firestore/cloud_firestore.dart';
import '../audit_logs_service.dart';
import '../../models/audit_log.dart';

class FirebaseAuditLogsService implements AuditLogsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getAuditLogsCollection(String pharmacyId) {
    return _firestore
        .collection('pharmacies')
        .doc(pharmacyId)
        .collection('audit_logs');
  }

  @override
  Future<List<AuditLog>> getAuditLogs(String pharmacyId,
      {int limit = 50}) async {
    final snapshot = await _getAuditLogsCollection(pharmacyId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) =>
            AuditLog.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Stream<List<AuditLog>> getAuditLogsStream(String pharmacyId) {
    return _getAuditLogsCollection(pharmacyId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              AuditLog.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  @override
  Future<void> addAuditLog(String pharmacyId, AuditLog log) async {
    await _getAuditLogsCollection(pharmacyId).add(log.toMap());
  }

  @override
  Future<List<AuditLog>> searchAuditLogs(
      String pharmacyId, String query) async {
    if (query.isEmpty) {
      return await getAuditLogs(pharmacyId);
    }

    // Search in medicine name and details
    final snapshot = await _getAuditLogsCollection(pharmacyId)
        .orderBy('timestamp', descending: true)
        .get();

    final allLogs = snapshot.docs
        .map((doc) =>
            AuditLog.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    return allLogs.where((log) {
      return log.medicineName.toLowerCase().contains(query.toLowerCase()) ||
          log.details.toLowerCase().contains(query.toLowerCase()) ||
          log.userName.toLowerCase().contains(query.toLowerCase()) ||
          log.typeLabel.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
