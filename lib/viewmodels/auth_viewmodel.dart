import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/firebase/firebase_auth_service.dart';
import '../services/notification_service.dart';
// import '../services/mock/mock_auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = FirebaseAuthService();
  final NotificationService _notificationService = NotificationService();
  // final AuthService _authService = MockAuthService();

  User? _user;
  User? get user => _user;
  String? _error;
  String? get error => _error;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> register(
      String name, String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.register(name, email, password, role);
    _isLoading = false;
    if (result != null) {
      _user = result;
      _error = null;
      notifyListeners();
      await _initNotifications();
      return true;
    } else {
      _error = 'Registration failed (email may already exist)';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password,
      {bool rememberMe = false}) async {
    _isLoading = true;
    notifyListeners();
    final result =
        await _authService.login(email, password, rememberMe: rememberMe);
    _isLoading = false;
    if (result != null) {
      _user = result;
      _error = null;
      notifyListeners();
      await _initNotifications();
      return true;
    } else {
      _error = 'Invalid email or password';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    await _authService.resetPassword(email);
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> updateUserProfile(
      String name, String email, String phone) async {
    if (_user == null) return;
    _isLoading = true;
    notifyListeners();
    final updatedUser =
        await _authService.updateProfile(_user!.id, name, email, phone);
    if (updatedUser != null) {
      _user = updatedUser;
      _error = null;
    } else {
      _error = 'Failed to update profile';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<User>> getAllUsers() async {
    return await _authService.getAllUsers();
  }

  Future<List<User>> getUnassignedStaff() async {
    return await _authService.getUnassignedStaff();
  }

  Future<bool> inviteUserToPharmacy(
      String staffUserId, String pharmacyId) async {
    return await _authService.inviteUserToPharmacy(staffUserId, pharmacyId);
  }

  Future<bool> acceptInvitation(String pharmacyId) async {
    if (_user == null) return false;
    final success = await _authService.acceptInvitation(_user!.id, pharmacyId);
    if (success) {
      // Refresh user data to get the new pharmacyId and remove pendingId
      final updatedUser = await _authService.getUser(_user!.id);
      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
      }
    }
    return success;
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> _initNotifications() async {
    if (_user == null) return;
    await _notificationService.init();
    final token = await _notificationService.getFcmToken();
    if (token != null) {
      if (_user!.fcmToken != token) {
        await _authService.saveFcmToken(_user!.id, token);
        _user = _user!.copyWith(fcmToken: token);
        notifyListeners();
      }
    }
  }
}
