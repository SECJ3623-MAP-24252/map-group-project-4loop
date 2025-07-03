import '../models/pharmacy.dart';
import '../models/user.dart';

abstract class PharmacyService {
  Future<Pharmacy?> getPharmacy(String pharmacyId);
  Future<void> updatePharmacy(Pharmacy pharmacy);
  Future<List<User>> getStaff(String pharmacyId);
  Future<void> inviteStaff(String pharmacyId, String staffEmail);
} 