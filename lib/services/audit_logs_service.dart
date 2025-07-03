import '../models/audit_log.dart';

abstract class AuditLogsService {
  Future<List<AuditLog>> getAuditLogs(String pharmacyId, {int limit = 50});
  Stream<List<AuditLog>> getAuditLogsStream(String pharmacyId);
  Future<void> addAuditLog(String pharmacyId, AuditLog log);
  Future<List<AuditLog>> searchAuditLogs(String pharmacyId, String query);
}
