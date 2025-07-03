import '../auth_service.dart';
import '../../models/user.dart';

class MockAuthService implements AuthService {
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'Dr. Smith',
      'email': 'pharmacist@app.com',
      'password': 'hashed3150',
      'role': UserRole.pharmacist,
      'pharmacyId': 'pharmacy1',
    },
    {
      'id': '2',
      'name': 'Michael Chen',
      'email': 'stock@app.com',
      'password': 'hashed3159',
      'role': UserRole.stockManager,
      'pharmacyId': null,
    },
    {
      'id': '3',
      'name': 'Sarah Johnson',
      'email': 'staff@app.com',
      'password': 'hashed3168',
      'role': UserRole.staff,
      'pharmacyId': null,
    },
  ];

  Map<String, dynamic>? _currentUser;

  String _hashPassword(String password) =>
      'hashed${password.length}${password.codeUnits.reduce((a, b) => a + b)}';

  @override
  Future<User?> register(
      String name, String email, String password, UserRole role) async {
    final exists = _users.any((u) => u['email'] == email);
    if (exists) return null;
    final user = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'password': _hashPassword(password),
      'role': role,
      'pharmacyId': null,
    };
    _users.add(user);
    _currentUser = user;
    return _toUser(user);
  }

  @override
  Future<User?> login(String email, String password,
      {bool rememberMe = false}) async {
    final user = _users.firstWhere(
      (u) => u['email'] == email && u['password'] == _hashPassword(password),
      orElse: () => {},
    );
    if (user.isEmpty) return null;
    _currentUser = user;
    return _toUser(user);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<void> resetPassword(String email) async {
    // Simulate sending reset email
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  User? getCurrentUser() {
    if (_currentUser == null) return null;
    return _toUser(_currentUser!);
  }

  User _toUser(Map<String, dynamic> data) {
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      role: data['role'],
      pharmacyId: data['pharmacyId'],
      phone: data['phone'],
    );
  }

  @override
  Future<User?> updateProfile(
      String id, String name, String email, String phone) async {
    final userIndex = _users.indexWhere((u) => u['id'] == id);
    if (userIndex == -1) return null;
    _users[userIndex]['name'] = name;
    _users[userIndex]['email'] = email;
    _users[userIndex]['phone'] = phone;
    if (_currentUser != null && _currentUser!['id'] == id) {
      _currentUser = _users[userIndex];
    }
    return _toUser(_users[userIndex]);
  }

  @override
  Future<List<User>> getAllUsers() async {
    return _users.map((u) => _toUser(u)).toList();
  }

  @override
  Future<List<User>> getUnassignedStaff() async {
    return _users
        .where((u) =>
            u['pharmacyId'] == null &&
            (u['role'] == UserRole.staff || u['role'] == UserRole.stockManager))
        .map((u) => _toUser(u))
        .toList();
  }

  @override
  Future<bool> inviteUserToPharmacy(
      String staffUserId, String pharmacyId) async {
    final userIndex = _users.indexWhere((u) => u['id'] == staffUserId);
    if (userIndex == -1) return false;
    _users[userIndex]['pendingPharmacyId'] = pharmacyId;
    return true;
  }

  @override
  Future<bool> acceptInvitation(String userId, String pharmacyId) async {
    final userIndex = _users.indexWhere((u) => u['id'] == userId);
    if (userIndex == -1) return false;
    _users[userIndex]['pharmacyId'] = pharmacyId;
    _users[userIndex].remove('pendingPharmacyId');
    return true;
  }

  @override
  Future<User?> getUser(String userId) async {
    final user = _users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {},
    );
    if (user.isEmpty) return null;
    return _toUser(user);
  }

  @override
  Future<void> saveFcmToken(String userId, String token) async {
    final userIndex = _users.indexWhere((u) => u['id'] == userId);
    if (userIndex != -1) {
      _users[userIndex]['fcmToken'] = token;
    }
  }
}
