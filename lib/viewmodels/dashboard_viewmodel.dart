import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/audit_log.dart';
import '../services/firebase/firebase_audit_logs_service.dart';

class DashboardViewModel extends ChangeNotifier {
  int totalItems = 0;
  int lowStock = 0;
  int expired = 0;
  int categories = 0;
  List<AuditLog> recentAuditLogs = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  final _auditLogsService = FirebaseAuditLogsService();

  Future<void> loadDashboard(
      List<Medicine> medicines, String pharmacyId) async {
    if (_isLoading) return; // Prevent re-entrancy
    _isLoading = true;
    print('[DashboardViewModel] Loading dashboard for pharmacyId: $pharmacyId');
    notifyListeners();
    totalItems = medicines.fold(0, (sum, m) => sum + m.quantity);
    lowStock = medicines
        .where((m) =>
            m.status == MedicineStatus.lowStock ||
            m.status == MedicineStatus.critical)
        .length;
    expired = medicines.where((m) => m.status == MedicineStatus.expired).length;
    categories = medicines
        .map((m) => m.name)
        .toSet()
        .length; // More accurate category count
    try {
      print('[DashboardViewModel] pharmacyId: $pharmacyId');
      if (pharmacyId.isNotEmpty) {
        recentAuditLogs =
            await _auditLogsService.getAuditLogs(pharmacyId, limit: 3);
        print(
            '[DashboardViewModel] recentAuditLogs: count = [32m${recentAuditLogs.length}[0m');
      } else {
        print(
            '[DashboardViewModel] pharmacyId is empty, skipping audit log fetch');
        recentAuditLogs = [];
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('[DashboardViewModel] Error fetching audit logs: $_error');
      recentAuditLogs = [];
    }
    _isLoading = false;
    notifyListeners();
  }
}
