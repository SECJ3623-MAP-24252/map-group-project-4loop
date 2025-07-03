import 'package:cloud_firestore/cloud_firestore.dart';
import '../analytics_service.dart';
import '../../models/medicine.dart';

class FirebaseAnalyticsService implements AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getMedicinesCollection(String pharmacyId) {
    return _firestore
        .collection('pharmacies')
        .doc(pharmacyId)
        .collection('medicines');
  }

  @override
  Future<Map<String, dynamic>> getInventoryStats(String pharmacyId) async {
    final snapshot = await _getMedicinesCollection(pharmacyId).get();
    final medicines = snapshot.docs
        .map((doc) =>
            Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(Duration(days: 30));

    int totalMedicines = medicines.length;
    int lowStock = medicines
        .where((med) =>
            med.lowStockThreshold != null &&
            med.quantity < med.lowStockThreshold! &&
            med.expiryDate.isAfter(now))
        .length;
    int expired = medicines.where((med) => med.expiryDate.isBefore(now)).length;
    int expiringSoon = medicines
        .where((med) =>
            med.expiryDate.isAfter(now) &&
            med.expiryDate.isBefore(thirtyDaysFromNow))
        .length;

    // Get unique categories
    Set<String> categories =
        medicines.map((med) => med.category ?? 'Uncategorized').toSet();

    return {
      'totalMedicines': totalMedicines,
      'lowStock': lowStock,
      'expired': expired,
      'expiringSoon': expiringSoon,
      'categories': categories.length,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getStockLevelsOverTime(String pharmacyId,
      {int days = 7}) async {
    // For now, we'll simulate stock levels over time based on current data
    // In a real implementation, you'd store historical data in Firestore
    final snapshot = await _getMedicinesCollection(pharmacyId).get();
    final medicines = snapshot.docs
        .map((doc) =>
            Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    int totalStock = medicines.fold(0, (sum, med) => sum + med.quantity);

    // Simulate daily stock levels (decreasing trend for demo)
    List<Map<String, dynamic>> stockLevels = [];
    for (int i = 0; i < days; i++) {
      // Simulate some daily variation
      double variation = 1.0 - (i * 0.05) + (i % 2 == 0 ? 0.02 : -0.02);
      int dailyStock = (totalStock * variation).round();
      stockLevels.add({
        'day': i,
        'stock': dailyStock,
        'date': DateTime.now().subtract(Duration(days: days - 1 - i)),
      });
    }

    return stockLevels;
  }

  @override
  Future<Map<String, double>> getExpiryRateAnalysis(String pharmacyId) async {
    final snapshot = await _getMedicinesCollection(pharmacyId).get();
    final medicines = snapshot.docs
        .map((doc) =>
            Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    final now = DateTime.now();
    final oneYearFromNow = now.add(Duration(days: 365));

    int total = medicines.length;
    if (total == 0) {
      return {
        'valid': 100.0,
        'expiring': 0.0,
        'expired': 0.0,
      };
    }

    int expired = medicines.where((med) => med.expiryDate.isBefore(now)).length;
    int expiring = medicines
        .where((med) =>
            med.expiryDate.isAfter(now) &&
            med.expiryDate.isBefore(oneYearFromNow))
        .length;
    int valid =
        medicines.where((med) => med.expiryDate.isAfter(oneYearFromNow)).length;

    return {
      'valid': (valid / total * 100).roundToDouble(),
      'expiring': (expiring / total * 100).roundToDouble(),
      'expired': (expired / total * 100).roundToDouble(),
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getTopMedicines(String pharmacyId,
      {int limit = 10}) async {
    final snapshot = await _getMedicinesCollection(pharmacyId).get();
    final medicines = snapshot.docs
        .map((doc) =>
            Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    // Sort by quantity (descending) and take top medicines
    medicines.sort((a, b) => b.quantity.compareTo(a.quantity));

    return medicines
        .take(limit)
        .map((med) => {
              'name': med.name,
              'quantity': med.quantity,
              'status': med.status.toString(),
              'expiryDate': med.expiryDate,
            })
        .toList();
  }

  @override
  Future<Map<String, int>> getCategoryDistribution(String pharmacyId) async {
    final snapshot = await _getMedicinesCollection(pharmacyId).get();
    final medicines = snapshot.docs
        .map((doc) =>
            Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    Map<String, int> categoryCount = {};
    for (var medicine in medicines) {
      String category = medicine.category ?? 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return categoryCount;
  }
}
