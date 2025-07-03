import 'package:flutter/material.dart';
import '../models/pharmacy.dart';
import '../models/user.dart';
import '../services/pharmacy_service.dart';
import '../services/firebase/firebase_pharmacy_service.dart';

class PharmacyViewModel extends ChangeNotifier {
  final PharmacyService _pharmacyService = FirebasePharmacyService();
  final String pharmacyId;

  Pharmacy? _pharmacy;
  Pharmacy? get pharmacy => _pharmacy;
  List<User> _staff = [];
  List<User> get staff => _staff;
  String? _error;
  String? get error => _error;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  PharmacyViewModel(this.pharmacyId) {
    if (pharmacyId.isNotEmpty) {
      loadPharmacy(pharmacyId);
      loadStaff(pharmacyId);
    }
  }

  Future<void> loadPharmacy(String pharmacyId) async {
    _isLoading = true;
    notifyListeners();
    _pharmacy = await _pharmacyService.getPharmacy(pharmacyId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePharmacy(Pharmacy pharmacy) async {
    _isLoading = true;
    notifyListeners();
    await _pharmacyService.updatePharmacy(pharmacy);
    _pharmacy = pharmacy;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStaff(String pharmacyId) async {
    _isLoading = true;
    notifyListeners();
    _staff = await _pharmacyService.getStaff(pharmacyId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> inviteStaff(String pharmacyId, String staffEmail) async {
    _isLoading = true;
    notifyListeners();
    await _pharmacyService.inviteStaff(pharmacyId, staffEmail);
    await loadStaff(pharmacyId);
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
