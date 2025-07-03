import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/medicine.dart';
import 'add_edit_medicine_screen.dart';
import '../../services/firebase/firebase_audit_logs_service.dart';
import '../../models/audit_log.dart';

class ScanBarcodeScreen extends StatefulWidget {
  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final TextEditingController _manualBarcodeController =
      TextEditingController();

  String? _detectedBarcode;
  bool _isSearching = false;
  Medicine? _foundMedicine;
  String? _searchError;
  String? _searchedBarcode; // To keep track of what was searched

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode != null && barcode.isNotEmpty) {
      if (mounted) {
        setState(() {
          _detectedBarcode = barcode;
        });
      }
    }
  }

  Future<void> _searchMedicineByBarcode(String barcode) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _searchError = null;
      _foundMedicine = null;
      _searchedBarcode = barcode;
    });

    try {
      final inventoryVM =
          Provider.of<InventoryViewModel>(context, listen: false);
      final medicine = await inventoryVM.findMedicineByBarcode(barcode);

      if (mounted) {
        setState(() {
          _foundMedicine = medicine;
          if (medicine == null) {
            _searchError =
                'No medicine found with this barcode in your inventory.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchError = 'An error occurred: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _resetScreen() {
    setState(() {
      _detectedBarcode = null;
      _isSearching = false;
      _foundMedicine = null;
      _searchError = null;
      _searchedBarcode = null;
      _manualBarcodeController.clear();
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _manualBarcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final isPharmacist = authVM.user?.isPharmacist ?? false;
    final isStockManager = authVM.user?.isStockManager ?? false;

    Widget mainContent;
    if (_isSearching) {
      mainContent = _buildSearchingView();
    } else if (_searchedBarcode != null) {
      mainContent = _buildResultView(isPharmacist, isStockManager);
    } else {
      mainContent = _buildScanningView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Find Medicine'),
        actions: [
          if (_searchedBarcode != null || _detectedBarcode != null)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _resetScreen,
              tooltip: 'Start Over',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: mainContent,
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    return Column(
      key: ValueKey('scanning'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Scan with Camera', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            ),
          ),
        ),
        SizedBox(height: 16),
        if (_detectedBarcode != null)
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text('Detected: $_detectedBarcode',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _searchMedicineByBarcode(_detectedBarcode!),
                    icon: Icon(Icons.search),
                    label: Text('Use Scanned Code'),
                  ),
                ],
              ),
            ),
          )
        else
          Center(child: Text('Point camera at a barcode')),
        SizedBox(height: 32),
        Row(children: [
          Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('OR', style: TextStyle(color: Colors.grey.shade600)),
          ),
          Expanded(child: Divider()),
        ]),
        SizedBox(height: 32),
        Text('Enter Manually', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 16),
        TextField(
          controller: _manualBarcodeController,
          decoration: InputDecoration(
            labelText: 'Barcode Number',
            border: OutlineInputBorder(),
            hintText: 'Enter barcode number',
          ),
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            if (_manualBarcodeController.text.isNotEmpty) {
              _searchMedicineByBarcode(_manualBarcodeController.text);
            }
          },
          icon: Icon(Icons.search),
          label: Text('Search Manually'),
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16)),
        ),
      ],
    );
  }

  Widget _buildSearchingView() {
    return Center(
      key: ValueKey('searching'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Searching for barcode: $_searchedBarcode...'),
        ],
      ),
    );
  }

  Widget _buildResultView(bool isPharmacist, bool isStockManager) {
    return Column(
      key: ValueKey('results'),
      children: [
        Text('Searched for: $_searchedBarcode',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
        SizedBox(height: 24),
        if (_foundMedicine != null)
          _buildMedicineCard(_foundMedicine!, isPharmacist, isStockManager),
        if (_searchError != null) ...[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              SizedBox(width: 12),
              Expanded(
                  child: Text(_searchError!,
                      style: TextStyle(color: Colors.red.shade800))),
            ]),
          ),
          SizedBox(height: 24),
          if (isPharmacist)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditMedicineScreen(
                      medicine: null,
                      initialBarcode: _searchedBarcode!,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.add),
              label: Text('Add as New Medicine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMedicineCard(
      Medicine medicine, bool isPharmacist, bool isStockManager) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final isStaff = authVM.user?.isStaff ?? false;
    final isExpired = medicine.status == MedicineStatus.expired;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(medicine.name.hashCode | 0xFF000000)
                      .withOpacity(1.0),
                  child: Icon(Icons.medical_services, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medicine.name,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Barcode: ${medicine.barcode ?? 'N/A'}',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                _statusChip(medicine.status),
              ],
            ),
            SizedBox(height: 16),
            _buildInfoRow('Quantity', '${medicine.quantity} units'),
            _buildInfoRow('Batch Number', medicine.batchNumber),
            _buildInfoRow('Expiry Date',
                medicine.expiryDate.toLocal().toString().split(' ')[0]),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isStockManager)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showUpdateQuantityDialog(medicine),
                      child: Text('Update Stock'),
                    ),
                  ),
                if (isStockManager && isPharmacist) SizedBox(width: 12),
                if (isPharmacist)
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditMedicineScreen(medicine: medicine),
                          ),
                        );
                      },
                      child: Text('Edit Details'),
                    ),
                  ),
              ],
            ),
            if (isStaff && !isPharmacist && !isStockManager) ...[
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isExpired ? Colors.red : Colors.teal[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    final result =
                        await _showDispenseDialog(medicine, isExpired);
                    if (result == true && mounted) {
                      Navigator.pop(context); // Pops ScanBarcodeScreen
                    }
                  },
                  child: Text(isExpired ? 'Remove' : 'Dispense'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[800])),
        ],
      ),
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
    return Chip(
      label: Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
  }

  void _showUpdateQuantityDialog(Medicine medicine) {
    final controller =
        TextEditingController(text: medicine.quantity.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock for ${medicine.name}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'New Quantity',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = int.tryParse(controller.text);
              if (newQuantity != null && newQuantity >= 0) {
                final inventoryVM =
                    Provider.of<InventoryViewModel>(context, listen: false);
                final authVM =
                    Provider.of<AuthViewModel>(context, listen: false);
                final user = authVM.user;
                if (user != null) {
                  final updatedMedicine =
                      medicine.copyWith(quantity: newQuantity);
                  await inventoryVM.editMedicine(
                      updatedMedicine, user.name, user.id);
                  Navigator.pop(context);
                  _resetScreen();
                }
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDispenseDialog(Medicine medicine, bool isExpired) async {
    final controller = TextEditingController();
    final inventoryVM = Provider.of<InventoryViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isExpired ? 'Remove Expired Stock' : 'Dispense Medicine'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter quantity to ${isExpired ? 'remove' : 'dispense'}:'),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Quantity',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(controller.text.trim());
              if (qty == null || qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid quantity.')),
                );
                return;
              }
              if (!isExpired && qty > medicine.quantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Cannot dispense more than available stock.')),
                );
                return;
              }
              Navigator.pop(context, true); // Close dialog and return true
              try {
                final user = authVM.user;
                if (user == null) {
                  throw Exception('User not found.');
                }
                final newQty = medicine.quantity - qty;
                final updatedMedicine = medicine.copyWith(quantity: newQty);
                await inventoryVM.editMedicine(
                    updatedMedicine, user.name, user.id);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                      content: Text(
                          '${isExpired ? 'Removed' : 'Dispensed'} $qty units.')),
                );
                setState(() {}); // Refresh UI
              } catch (e) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: Text(isExpired ? 'Remove' : 'Dispense'),
          ),
        ],
      ),
    );
  }
}

extension MedicineTemplate on Medicine {
  static Medicine templateWithBarcode(String barcode) {
    return Medicine(
      id: '',
      name: '',
      quantity: 0,
      expiryDate: DateTime.now(),
      batchNumber: '',
      status: MedicineStatus.inStock,
      pharmacyId: '',
      barcode: barcode,
    );
  }
}
