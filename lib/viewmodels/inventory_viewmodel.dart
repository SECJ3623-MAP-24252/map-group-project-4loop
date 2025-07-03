import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../models/audit_log.dart';
import '../services/inventory_service.dart';
import '../services/firebase/firebase_inventory_service.dart';
import '../services/audit_logs_service.dart';
import '../services/firebase/firebase_audit_logs_service.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';
import '../main.dart';

typedef MedicineListCallback = void Function(List<Medicine> medicines);

class InventoryViewModel extends ChangeNotifier {
  final InventoryService _inventoryService = FirebaseInventoryService();
  final AuditLogsService _auditLogsService = FirebaseAuditLogsService();
  final String pharmacyId;

  List<Medicine> _medicines = [];
  List<Medicine> get medicines => _medicines;
  String? _error;
  String? get error => _error;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Stream<List<Medicine>>? _medicineStream;

  InventoryViewModel(this.pharmacyId) {
    if (pharmacyId.isNotEmpty) {
      _medicineStream = _inventoryService.getMedicinesStream(pharmacyId);
      _medicineStream!.listen((data) {
        final now = DateTime.now();
        final context = navigatorKey.currentContext;
        List<Medicine> oldMedicines = List.from(_medicines);
        _medicines = data.map((med) {
          if (med.expiryDate.isBefore(now)) {
            return med.copyWith(status: MedicineStatus.expired);
          } else if (med.lowStockThreshold != null &&
              med.quantity < med.lowStockThreshold!) {
            return med.copyWith(status: MedicineStatus.lowStock);
          } else if (med.status == MedicineStatus.critical) {
            return med.copyWith(status: MedicineStatus.critical);
          } else {
            return med.copyWith(status: MedicineStatus.inStock);
          }
        }).toList();
        // Check for status changes and trigger notification
        if (context != null) {
          final notificationVM =
              Provider.of<NotificationViewModel>(context, listen: false);
          for (final med in _medicines) {
            final oldMed = oldMedicines.firstWhere((m) => m.id == med.id,
                orElse: () => med);
            if (oldMed.status != med.status) {
              if (med.status == MedicineStatus.lowStock) {
                notificationVM.addNotification(NotificationItem(
                  title: 'Low Stock Alert',
                  body: '${med.name} is now low on stock.',
                  timestamp: DateTime.now(),
                ));
              } else if (med.status == MedicineStatus.expired) {
                notificationVM.addNotification(NotificationItem(
                  title: 'Expired Medicine',
                  body: '${med.name} has expired.',
                  timestamp: DateTime.now(),
                ));
              }
            }
          }
        }
        notifyListeners();
      });
      loadMedicines();
    }
  }

  Future<void> loadMedicines() async {
    if (pharmacyId.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _medicines = await _inventoryService.getMedicines(pharmacyId);
      final now = DateTime.now();
      _medicines = _medicines.map((med) {
        if (med.expiryDate.isBefore(now)) {
          return med.copyWith(status: MedicineStatus.expired);
        } else if (med.lowStockThreshold != null &&
            med.quantity < med.lowStockThreshold!) {
          return med.copyWith(status: MedicineStatus.lowStock);
        } else if (med.status == MedicineStatus.critical) {
          return med.copyWith(status: MedicineStatus.critical);
        } else {
          return med.copyWith(status: MedicineStatus.inStock);
        }
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedicine(
      Medicine medicine, String userName, String userId) async {
    if (pharmacyId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _inventoryService.addMedicine(pharmacyId, medicine);

      // Create audit log
      final auditLog = AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AuditLogType.medicineAdded,
        medicineName: medicine.name,
        details:
            'Added ${medicine.quantity} units with batch ${medicine.batchNumber}',
        userId: userId,
        userName: userName,
        timestamp: DateTime.now(),
        pharmacyId: pharmacyId,
      );
      await _auditLogsService.addAuditLog(pharmacyId, auditLog);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editMedicine(
      Medicine medicine, String userName, String userId) async {
    if (pharmacyId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _inventoryService.editMedicine(pharmacyId, medicine);

      // Create audit log
      final auditLog = AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AuditLogType.stockUpdated,
        medicineName: medicine.name,
        details: 'Updated quantity to ${medicine.quantity} units',
        userId: userId,
        userName: userName,
        timestamp: DateTime.now(),
        pharmacyId: pharmacyId,
      );
      await _auditLogsService.addAuditLog(pharmacyId, auditLog);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMedicine(String medicineId, String medicineName,
      String userName, String userId) async {
    if (pharmacyId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _inventoryService.deleteMedicine(pharmacyId, medicineId);

      // Create audit log
      final auditLog = AuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: AuditLogType.medicineDeleted,
        medicineName: medicineName,
        details: 'Medicine deleted from inventory',
        userId: userId,
        userName: userName,
        timestamp: DateTime.now(),
        pharmacyId: pharmacyId,
      );
      await _auditLogsService.addAuditLog(pharmacyId, auditLog);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Medicine?> findMedicineByBarcode(String barcode) async {
    if (pharmacyId.isEmpty) return null;
    try {
      return await _inventoryService.findMedicineByBarcode(pharmacyId, barcode);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
