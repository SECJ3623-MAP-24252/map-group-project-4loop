enum MedicineStatus { inStock, lowStock, critical, expired, expiring }

class Medicine {
  final String id;
  String name;
  int quantity;
  DateTime expiryDate;
  String batchNumber;
  String? barcode;
  MedicineStatus status;
  final String pharmacyId;
  int? lowStockThreshold;
  String? category;

  Medicine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.batchNumber,
    this.barcode,
    required this.status,
    required this.pharmacyId,
    this.lowStockThreshold,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate,
      'batchNumber': batchNumber,
      'barcode': barcode,
      'status': status.toString().split('.').last,
      'pharmacyId': pharmacyId,
      'lowStockThreshold': lowStockThreshold,
      'category': category,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String documentId) {
    return Medicine(
      id: documentId,
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      expiryDate: (map['expiryDate'] as dynamic).toDate(),
      batchNumber: map['batchNumber'] ?? '',
      barcode: map['barcode'],
      status: MedicineStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => MedicineStatus.inStock,
      ),
      pharmacyId: map['pharmacyId'] ?? '',
      lowStockThreshold: map['lowStockThreshold'],
      category: map['category'],
    );
  }

  factory Medicine.templateWithBarcode(String barcode) {
    return Medicine(
      id: '',
      name: '',
      quantity: 0,
      expiryDate: DateTime.now(),
      batchNumber: '',
      status: MedicineStatus.inStock,
      pharmacyId: '',
      barcode: barcode,
      lowStockThreshold: null,
      category: null,
    );
  }

  Medicine copyWith({
    String? name,
    int? quantity,
    DateTime? expiryDate,
    String? batchNumber,
    String? barcode,
    MedicineStatus? status,
    String? pharmacyId,
    int? lowStockThreshold,
    String? category,
  }) {
    return Medicine(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      batchNumber: batchNumber ?? this.batchNumber,
      barcode: barcode ?? this.barcode,
      status: status ?? this.status,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      category: category ?? this.category,
    );
  }
}
