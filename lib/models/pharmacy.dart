class Pharmacy {
  final String id;
  String name;
  String address;
  String phone;
  String contactEmail;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.contactEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'contactEmail': contactEmail,
    };
  }

  factory Pharmacy.fromMap(Map<String, dynamic> map, String documentId) {
    return Pharmacy(
      id: documentId,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      contactEmail: map['contactEmail'] ?? '',
    );
  }

  Pharmacy copyWith({
    String? name,
    String? address,
    String? phone,
    String? contactEmail,
  }) {
    return Pharmacy(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }
}
