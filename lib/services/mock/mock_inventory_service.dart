import '../inventory_service.dart';
import '../../models/medicine.dart';
import 'dart:async';

class MockInventoryService implements InventoryService {
  final List<Medicine> _medicines = [
    Medicine(
      id: '1',
      name: 'Amoxicillin 250mg',
      quantity: 120,
      expiryDate: DateTime(2025, 12, 15),
      batchNumber: 'A1',
      status: MedicineStatus.inStock,
      pharmacyId: 'mock_pharmacy',
    ),
    Medicine(
      id: '2',
      name: 'Ibuprofen 400mg',
      quantity: 45,
      expiryDate: DateTime(2025, 8, 22),
      batchNumber: 'B2',
      status: MedicineStatus.lowStock,
      pharmacyId: 'mock_pharmacy',
    ),
    Medicine(
      id: '3',
      name: 'Paracetamol 500mg',
      quantity: 200,
      expiryDate: DateTime(2025, 11, 30),
      batchNumber: 'C3',
      status: MedicineStatus.inStock,
      pharmacyId: 'mock_pharmacy',
    ),
    Medicine(
      id: '4',
      name: 'Aspirin 75mg',
      quantity: 8,
      expiryDate: DateTime(2025, 9, 10),
      batchNumber: 'D4',
      status: MedicineStatus.critical,
      pharmacyId: 'mock_pharmacy',
    ),
  ];

  final StreamController<List<Medicine>> _controller =
      StreamController.broadcast();
  Timer? _timer;

  MockInventoryService() {
    _controller.add(_medicines);
    _timer = Timer.periodic(
        const Duration(seconds: 10), (_) => _simulateStockChange());
  }

  void _simulateStockChange() {
    // Randomly decrease quantity for demo
    for (var med in _medicines) {
      if (med.quantity > 0) {
        med.quantity -= 1;
        if (med.quantity < 10) {
          med.status = MedicineStatus.critical;
        } else if (med.quantity < 50) {
          med.status = MedicineStatus.lowStock;
        } else {
          med.status = MedicineStatus.inStock;
        }
      }
    }
    _controller.add(List<Medicine>.from(_medicines));
  }

  @override
  Future<List<Medicine>> getMedicines(String pharmacyId) async {
    return List<Medicine>.from(_medicines);
  }

  @override
  Future<void> addMedicine(String pharmacyId, Medicine medicine) async {
    _medicines.add(medicine);
    _controller.add(List<Medicine>.from(_medicines));
  }

  @override
  Future<void> editMedicine(String pharmacyId, Medicine medicine) async {
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      _medicines[index] = medicine;
      _controller.add(List<Medicine>.from(_medicines));
    }
  }

  @override
  Future<void> deleteMedicine(String pharmacyId, String medicineId) async {
    _medicines.removeWhere((m) => m.id == medicineId);
    _controller.add(List<Medicine>.from(_medicines));
  }

  @override
  Stream<List<Medicine>> getMedicinesStream(String pharmacyId) {
    return _controller.stream;
  }

  @override
  Future<Medicine?> findMedicineByBarcode(
      String pharmacyId, String barcode) async {
    try {
      return _medicines.firstWhere((med) => med.barcode == barcode);
    } catch (e) {
      return null;
    }
  }
}
