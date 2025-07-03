import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../models/medicine.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';
import 'scan_barcode_screen.dart';
import 'analytics_screen.dart';
import '../widgets/offline_banner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math' as math;
import 'threshold_management_screen.dart';
import '../chat/chat_user_selection_screen.dart';
import 'add_edit_medicine_screen.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _isShakeRefreshing = false;
  StreamSubscription? _accelerometerSub;
  DateTime? _lastShakeTime;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _accelerometerSub = accelerometerEvents.listen(_onAccelerometerEvent);
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    super.dispose();
  }

  void _onAccelerometerEvent(AccelerometerEvent event) async {
    final now = DateTime.now();
    double gX = event.x / 9.8, gY = event.y / 9.8, gZ = event.z / 9.8;
    double gForce = math.sqrt(gX * gX + gY * gY + gZ * gZ);
    if (gForce > 2.7) {
      if (_lastShakeTime == null ||
          now.difference(_lastShakeTime!) > Duration(seconds: 2)) {
        _lastShakeTime = now;
        setState(() => _isShakeRefreshing = true);
        final inventoryVM =
            Provider.of<InventoryViewModel>(context, listen: false);
        await inventoryVM.loadMedicines();
        await Future.delayed(Duration(seconds: 1));
        if (mounted) {
          setState(() {
            _isShakeRefreshing = false;
            _lastUpdated = DateTime.now();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryVM = Provider.of<InventoryViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.user;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 40.0 : 16.0;
    final isStockManager = user != null && user.isStockManager;
    final isPharmacist = user != null && user.isPharmacist;
    final isStaff = user != null && user.isStaff;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Inventory',
                style: TextStyle(
                    color: Colors.teal[800], fontWeight: FontWeight.bold)),
            centerTitle: true,
            elevation: 1,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.teal),
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OfflineBanner(),
                  if (_lastUpdated != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      margin: EdgeInsets.only(bottom: 4),
                      color: Colors.teal[50],
                      child: Text(
                        'Last updated: ' + _formatLastUpdated(_lastUpdated!),
                        style: TextStyle(fontSize: 11, color: Colors.teal[900]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search medicines...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        // TODO: Implement search logic
                      },
                    ),
                  ),
                  if (isPharmacist || isStockManager) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[700],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  foregroundColor: Colors.white,
                                  textStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ScanBarcodeScreen()),
                                  );
                                },
                                icon: Icon(Icons.qr_code_scanner,
                                    color: Colors.white),
                                label: Text('Scan Barcode'),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal[700],
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  foregroundColor: Colors.white,
                                  textStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AnalyticsScreen()),
                                  );
                                },
                                icon:
                                    Icon(Icons.bar_chart, color: Colors.white),
                                label: Text('View Analytics'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (isPharmacist) ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[700],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddEditMedicineScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.add, color: Colors.white),
                            label: Text('Add Medicine'),
                          ),
                          SizedBox(height: 12),
                        ],
                        if (isStockManager) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[700],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    foregroundColor: Colors.white,
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () =>
                                      _showAddStockDialog(context, inventoryVM),
                                  icon: Icon(Icons.add, color: Colors.white),
                                  label: Text('Add Stock'),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[700],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    foregroundColor: Colors.white,
                                    textStyle:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              ThresholdManagementScreen()),
                                    );
                                  },
                                  icon:
                                      Icon(Icons.settings, color: Colors.white),
                                  label: Text('Set Thresholds'),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                        ],
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                  if (isStaff) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[700],
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ScanBarcodeScreen()),
                              );
                            },
                            icon: Icon(Icons.qr_code_scanner,
                                color: Colors.white),
                            label: Text('Scan Barcode'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!(isPharmacist || isStockManager)) SizedBox(height: 16),
                  Expanded(
                    child: inventoryVM.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: () async => inventoryVM.loadMedicines(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: inventoryVM.medicines.length,
                              itemBuilder: (context, i) {
                                final med = inventoryVM.medicines[i];
                                if (isPharmacist) {
                                  return Slidable(
                                    key: ValueKey(med.id),
                                    startActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        AddEditMedicineScreen(
                                                            medicine: med)));
                                          },
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          icon: Icons.edit,
                                          label: 'Edit',
                                        ),
                                      ],
                                    ),
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            final user = authVM.user;
                                            if (user != null) {
                                              inventoryVM.deleteMedicine(
                                                  med.id!,
                                                  med.name,
                                                  user.name,
                                                  user.id);
                                            }
                                          },
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ],
                                    ),
                                    child: Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 4),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              _getColorForMedicine(med.name),
                                          child: Icon(Icons.medical_services,
                                              color: Colors.white),
                                        ),
                                        title: Text(med.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4),
                                            Text(
                                                'Qty: ${med.quantity} | Exp: ${med.expiryDate.toIso8601String().split('T').first}'),
                                            SizedBox(height: 4),
                                            Text(
                                                'Threshold: ${med.lowStockThreshold ?? 'Not set'}'),
                                          ],
                                        ),
                                        trailing: _statusChip(med.status),
                                      ),
                                    ),
                                  );
                                } else if (isStockManager) {
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            _getColorForMedicine(med.name),
                                        child: Icon(Icons.inventory_2,
                                            color: Colors.white),
                                      ),
                                      title: Text(med.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4),
                                          Text(
                                              'Qty: ${med.quantity} | Exp: ${med.expiryDate.toIso8601String().split('T').first}'),
                                          SizedBox(height: 4),
                                          Text(
                                              'Threshold: ${med.lowStockThreshold ?? 'Not set'}'),
                                        ],
                                      ),
                                      trailing: _statusChip(med.status),
                                    ),
                                  );
                                } else {
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            _getColorForMedicine(med.name),
                                        child: Icon(Icons.medical_services,
                                            color: Colors.white),
                                      ),
                                      title: Text(med.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4),
                                          Text(
                                              'Qty: ${med.quantity} | Exp: ${med.expiryDate.toIso8601String().split('T').first}'),
                                          SizedBox(height: 4),
                                          Text(
                                              'Threshold: ${med.lowStockThreshold ?? 'Not set'}'),
                                        ],
                                      ),
                                      trailing: _statusChip(med.status),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_android, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      if (_isShakeRefreshing)
                        Row(children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.teal),
                          ),
                          SizedBox(width: 8),
                          Text('Refreshing...',
                              style: TextStyle(color: Colors.teal[700])),
                        ])
                      else
                        Text('Shake your phone to refresh stock data',
                            style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) Navigator.pushNamed(context, '/dashboard');
              if (index == 2)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatUserSelectionScreen()),
                );
              if (index == 3) Navigator.pushNamed(context, '/profile');
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: 'Dashboard'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.inventory), label: 'Inventory'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusChip(MedicineStatus status) {
    Color color;
    String label;
    switch (status) {
      case MedicineStatus.inStock:
        label = 'In Stock';
        color = Colors.green;
        break;
      case MedicineStatus.lowStock:
        label = 'Low Stock';
        color = Colors.orange;
        break;
      case MedicineStatus.critical:
        label = 'Critical';
        color = Colors.red;
        break;
      case MedicineStatus.expired:
        label = 'Expired';
        color = Colors.black;
        break;
      default:
        label = 'Unknown';
        color = Colors.grey;
    }
    return Chip(label: Text(label), backgroundColor: color.withOpacity(0.2));
  }

  void _showAddStockDialog(
      BuildContext context, InventoryViewModel inventoryVM) {
    final _formKey = GlobalKey<FormState>();
    String? _selectedMedicineId;
    int? _quantity;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Add Stock'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMedicineId,
                  hint: Text('Select Medicine'),
                  items: inventoryVM.medicines
                      .map((med) => DropdownMenuItem(
                            value: med.id,
                            child: Text(med.name),
                          ))
                      .toList(),
                  onChanged: (value) => _selectedMedicineId = value,
                  validator: (value) =>
                      value == null ? 'Please select a medicine' : null,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Quantity to Add'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null ||
                        int.parse(value) <= 0) {
                      return 'Enter a valid quantity';
                    }
                    return null;
                  },
                  onSaved: (value) => _quantity = int.parse(value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final medicineToUpdate = inventoryVM.medicines
                      .firstWhere((med) => med.id == _selectedMedicineId!);
                  final updatedMedicine = medicineToUpdate.copyWith(
                    quantity: medicineToUpdate.quantity + _quantity!,
                  );
                  final user =
                      Provider.of<AuthViewModel>(ctx, listen: false).user;
                  if (user != null) {
                    await inventoryVM.editMedicine(
                        updatedMedicine, user.name, user.id);
                    Navigator.pop(ctx);
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditStockDialog(
      BuildContext context, InventoryViewModel inventoryVM, Medicine medicine) {
    final _formKey = GlobalKey<FormState>();
    int? _newQuantity;
    String? _newBatchNumber;
    DateTime? _newExpiryDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit ${medicine.name}'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: medicine.quantity.toString(),
                  decoration: InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _newQuantity = int.tryParse(value ?? ''),
                ),
                TextFormField(
                  initialValue: medicine.batchNumber,
                  decoration: InputDecoration(labelText: 'Batch Number'),
                  onSaved: (value) => _newBatchNumber = value,
                ),
                // Add date picker for expiry date
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final updatedMedicine = medicine.copyWith(
                    quantity: _newQuantity ?? medicine.quantity,
                    batchNumber: _newBatchNumber ?? medicine.batchNumber,
                    expiryDate: _newExpiryDate ?? medicine.expiryDate,
                  );
                  final user =
                      Provider.of<AuthViewModel>(ctx, listen: false).user;
                  if (user != null) {
                    await inventoryVM.editMedicine(
                        updatedMedicine, user.name, user.id);
                    Navigator.pop(ctx);
                  }
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Color _getColorForMedicine(String name) {
    // Simple hash function to get a color from a string
    return Color(name.hashCode | 0xFF000000).withOpacity(1.0);
  }

  String _formatLastUpdated(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
