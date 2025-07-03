import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptracker/models/pharmacy.dart';
import 'package:apptracker/models/user.dart';
import 'package:apptracker/services/pharmacy_service.dart';

class FirebasePharmacyService implements PharmacyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Pharmacy?> getPharmacy(String pharmacyId) async {
    if (pharmacyId.isEmpty) return null;
    final doc = await _firestore.collection('pharmacies').doc(pharmacyId).get();
    if (doc.exists) {
      return Pharmacy.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> updatePharmacy(Pharmacy pharmacy) async {
    await _firestore
        .collection('pharmacies')
        .doc(pharmacy.id)
        .update(pharmacy.toMap());
  }

  @override
  Future<List<User>> getStaff(String pharmacyId) async {
    if (pharmacyId.isEmpty) return [];
    final snapshot = await _firestore
        .collection('users')
        .where('pharmacyId', isEqualTo: pharmacyId)
        .get();
    return snapshot.docs
        .map((doc) => User.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> inviteStaff(String pharmacyId, String staffEmail) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: staffEmail)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userDoc = snapshot.docs.first;
      await userDoc.reference.update({'pharmacyId': pharmacyId});
    } else {
      // Handle case where user does not exist.
      // For now, we'll just print a message.
      // A more robust solution might create an invitation object
      // or send an email.
      print('User with email $staffEmail not found.');
    }
  }
}
