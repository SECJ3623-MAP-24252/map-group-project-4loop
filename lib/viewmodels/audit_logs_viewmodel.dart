import 'package:flutter/material.dart';
import '../models/audit_log.dart';
import '../services/audit_logs_service.dart';
import '../services/firebase/firebase_audit_logs_service.dart';

class AuditLogsViewModel extends ChangeNotifier {
  final AuditLogsService _auditLogsService = FirebaseAuditLogsService();
  final String pharmacyId;

  List<AuditLog> _auditLogs = [];
  List<AuditLog> get auditLogs => _auditLogs;

  String? _error;
  String? get error => _error;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Stream<List<AuditLog>>? _auditLogsStream;

  AuditLogsViewModel(this.pharmacyId) {
    if (pharmacyId.isNotEmpty) {
      loadAuditLogs();
    }
  }

  Future<void> loadAuditLogs() async {
    if (pharmacyId.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _auditLogs = await _auditLogsService.getAuditLogs(pharmacyId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchAuditLogs(String query) async {
    if (pharmacyId.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _auditLogs = await _auditLogsService.searchAuditLogs(pharmacyId, query);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAuditLog(AuditLog log) async {
    if (pharmacyId.isEmpty) return;

    try {
      await _auditLogsService.addAuditLog(pharmacyId, log);
      // Reload logs to show the new entry
      await loadAuditLogs();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
