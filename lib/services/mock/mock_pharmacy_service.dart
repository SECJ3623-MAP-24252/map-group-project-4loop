import '../pharmacy_service.dart';
import '../../models/pharmacy.dart';
import '../../models/user.dart';

class MockPharmacyService implements PharmacyService {
  Pharmacy _pharmacy = Pharmacy(
    id: 'pharmacy1',
    name: 'Good Health Pharmacy',
    address: '123 Main St',
    phone: '555-1234',
    contactEmail: 'contact@goodhealth.com',
  );

  final List<User> _staff = [
    User(
      id: '2',
      name: 'Michael Chen',
      email: 'stock@app.com',
      role: UserRole.stockManager,
      pharmacyId: 'pharmacy1',
    ),
    User(
      id: '3',
      name: 'Sarah Johnson',
      email: 'staff@app.com',
      role: UserRole.staff,
      pharmacyId: 'pharmacy1',
    ),
  ];

  @override
  Future<Pharmacy?> getPharmacy(String pharmacyId) async {
    return _pharmacy.id == pharmacyId ? _pharmacy : null;
  }

  @override
  Future<void> updatePharmacy(Pharmacy pharmacy) async {
    _pharmacy = pharmacy;
  }

  @override
  Future<List<User>> getStaff(String pharmacyId) async {
    return _staff.where((u) => u.pharmacyId == pharmacyId).toList();
  }

  @override
  Future<void> inviteStaff(String pharmacyId, String staffEmail) async {
    // Simulate inviting staff by adding a new staff user
    _staff.add(User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: staffEmail.split('@')[0],
      email: staffEmail,
      role: UserRole.staff,
      pharmacyId: pharmacyId,
    ));
  }
} 