import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:apptracker/models/user.dart';
import 'package:apptracker/services/auth_service.dart';
import 'dart:developer';

class FirebaseAuthService implements AuthService {
  final firebase.FirebaseAuth _firebaseAuth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  User? getCurrentUser() {
    // This needs a more sophisticated implementation, perhaps involving a stream
    // to listen to auth state changes and caching the user details from Firestore.
    // For now, AuthViewModel will hold the user state after login.
    return null;
  }

  @override
  Future<User?> login(String email, String password,
      {bool rememberMe = false}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        final docSnapshot = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        if (docSnapshot.exists) {
          return User.fromMap(docSnapshot.data()!, docSnapshot.id);
        }
      }
    } on firebase.FirebaseAuthException catch (e) {
      // Consider logging these errors
      print(e.message);
      return null;
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<User?> register(
      String name, String email, String password, UserRole role) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final newUser = User(
          id: credential.user!.uid,
          name: name,
          email: email,
          role: role,
          pharmacyId: null, // Initially no pharmacy
        );

        await _firestore
            .collection('users')
            .doc(newUser.id)
            .set(newUser.toMap());
        return newUser;
      }
    } on firebase.FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
    return null;
  }

  @override
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => User.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<List<User>> getUnassignedStaff() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('pharmacyId', isNull: true)
          .get();

      return snapshot.docs
          .map((doc) => User.fromMap(doc.data(), doc.id))
          .where((user) =>
              user.role == UserRole.staff || user.role == UserRole.stockManager)
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<bool> inviteUserToPharmacy(
      String staffUserId, String pharmacyId) async {
    try {
      await _firestore.collection('users').doc(staffUserId).update({
        'pendingPharmacyId': pharmacyId,
      });
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<bool> acceptInvitation(String userId, String pharmacyId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'pharmacyId': pharmacyId,
        'pendingPharmacyId': FieldValue.delete(),
      });
      await _firestore
          .collection('pharmacies')
          .doc(pharmacyId)
          .collection('staff')
          .doc(userId)
          .set({'role': 'staff'});
      return true;
    } catch (e) {
      log('Error accepting invitation: $e');
      return false;
    }
  }

  @override
  Future<User?> updateProfile(
      String id, String name, String email, String phone) async {
    try {
      await _firestore
          .collection('users')
          .doc(id)
          .update({'name': name, 'email': email, 'phone': phone});

      // We need to return the updated user. We can refetch it.
      final docSnapshot = await _firestore.collection('users').doc(id).get();
      if (docSnapshot.exists) {
        return User.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }

  @override
  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      log('Error getting user: $e');
    }
    return null;
  }

  @override
  Future<void> saveFcmToken(String userId, String token) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
    } catch (e) {
      log('Error saving FCM token: $e');
    }
  }
}
