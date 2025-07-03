import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptracker/models/medicine.dart';
import 'package:apptracker/services/inventory_service.dart';

class FirebaseInventoryService implements InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getMedicinesCollection(String pharmacyId) {
    return _firestore
        .collection('pharmacies')
        .doc(pharmacyId)
        .collection('medicines');
  }

  @override
  Future<List<Medicine>> getMedicines(String pharmacyId) async {
    final snapshot = await _getMedicinesCollection(pharmacyId).get();
    return snapshot.docs
        .map((doc) =>
            Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Stream<List<Medicine>> getMedicinesStream(String pharmacyId) {
    return _getMedicinesCollection(pharmacyId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  @override
  Future<void> addMedicine(String pharmacyId, Medicine medicine) async {
    await _getMedicinesCollection(pharmacyId).add(medicine.toMap());
  }

  @override
  Future<void> editMedicine(String pharmacyId, Medicine medicine) async {
    await _getMedicinesCollection(pharmacyId)
        .doc(medicine.id)
        .update(medicine.toMap());
  }

  @override
  Future<void> deleteMedicine(String pharmacyId, String medicineId) async {
    await _getMedicinesCollection(pharmacyId).doc(medicineId).delete();
  }

  @override
  Future<Medicine?> findMedicineByBarcode(
      String pharmacyId, String barcode) async {
    final snapshot = await _getMedicinesCollection(pharmacyId)
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final doc = snapshot.docs.first;
    return Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // This is the old method from the interface, which is now replaced by getMedicinesStream.
  // We keep it here to satisfy the interface during transition, but it should be removed
  // after refactoring the view models. In our case, we already changed the interface.
  // This is just a note. The interface had simulateStockUpdate()
  // which is now getMedicinesStream(String pharmacyId).
}
