import '../models/medicine.dart';

abstract class InventoryService {
  Future<List<Medicine>> getMedicines(String pharmacyId);
  Future<void> addMedicine(String pharmacyId, Medicine medicine);
  Future<void> editMedicine(String pharmacyId, Medicine medicine);
  Future<void> deleteMedicine(String pharmacyId, String medicineId);
  Stream<List<Medicine>> getMedicinesStream(String pharmacyId);
  Future<Medicine?> findMedicineByBarcode(String pharmacyId, String barcode);
}
