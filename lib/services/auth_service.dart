import '../models/user.dart';

abstract class AuthService {
  Future<User?> register(
      String name, String email, String password, UserRole role);
  Future<User?> login(String email, String password, {bool rememberMe = false});
  Future<void> logout();
  Future<void> resetPassword(String email);
  User? getCurrentUser();
  Future<User?> updateProfile(
      String userId, String name, String email, String phone);
  Future<List<User>> getAllUsers();
  Future<List<User>> getUnassignedStaff();
  Future<bool> inviteUserToPharmacy(String staffUserId, String pharmacyId);
  Future<bool> acceptInvitation(String userId, String pharmacyId);
  Future<User?> getUser(String userId);
  Future<void> saveFcmToken(String userId, String token);
}
