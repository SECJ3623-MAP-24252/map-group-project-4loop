enum UserRole { pharmacist, staff, stockManager }

class User {
  final String id;
  String name;
  String email;
  String phone;
  final UserRole role;
  final String? pharmacyId;
  String? pendingPharmacyId;
  String? fcmToken;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.pharmacyId,
    this.pendingPharmacyId,
    this.fcmToken,
  });

  bool get isPharmacist => role == UserRole.pharmacist;
  bool get isStockManager => role == UserRole.stockManager;
  bool get isStaff => role == UserRole.staff;

  User copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? pharmacyId,
    String? pendingPharmacyId,
    String? fcmToken,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      pendingPharmacyId: pendingPharmacyId ?? this.pendingPharmacyId,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'pharmacyId': pharmacyId,
      'pendingPharmacyId': pendingPharmacyId,
      'fcmToken': fcmToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map, String documentId) {
    return User(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == map['role'],
        orElse: () => UserRole.staff,
      ),
      pharmacyId: map['pharmacyId'],
      pendingPharmacyId: map['pendingPharmacyId'],
      fcmToken: map['fcmToken'],
    );
  }
}
