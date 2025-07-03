import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class AddEditMedicineScreen extends StatefulWidget {
  final Medicine? medicine;
  final String? initialBarcode;
  AddEditMedicineScreen({this.medicine, this.initialBarcode});
  @override
  _AddEditMedicineScreenState createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends State<AddEditMedicineScreen> {
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController();
  final _batchController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _barcodeController = TextEditingController(); // Barcode controller
  DateTime? _expiryDate;

  bool get isEdit => widget.medicine != null;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _qtyController.text = widget.medicine!.quantity.toString();
      _batchController.text = widget.medicine!.batchNumber;
      _barcodeController.text = widget.medicine!.barcode ?? ''; // Set barcode
      _thresholdController.text =
          widget.medicine!.lowStockThreshold?.toString() ?? '';
      _expiryDate = widget.medicine!.expiryDate;
    } else if (widget.initialBarcode != null) {
      _barcodeController.text = widget.initialBarcode!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventoryVM = Provider.of<InventoryViewModel>(context, listen: false);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Medicine Name'),
            TextField(controller: _nameController),
            const SizedBox(height: 12),
            Text('Quantity'),
            TextField(
                controller: _qtyController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Text('Batch Number'),
            TextField(controller: _batchController),
            const SizedBox(height: 12),
            Text('Barcode'),
            TextField(
                controller: _barcodeController,
                decoration: InputDecoration(hintText: 'Enter or scan barcode')),
            const SizedBox(height: 12),
            Text('Threshold'),
            TextField(
                controller: _thresholdController,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            Text('Expiry Date'),
            Row(
              children: [
                Text(_expiryDate == null
                    ? 'Select date'
                    : _expiryDate!.toLocal().toString().split(' ')[0]),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expiryDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _expiryDate = picked);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final pharmacyId = authVM.user?.pharmacyId;
                final user = authVM.user;
                if (pharmacyId == null || user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: Pharmacy ID or user not found.')));
                  return;
                }

                final medicine = Medicine(
                  id: widget.medicine?.id ?? UniqueKey().toString(),
                  name: _nameController.text,
                  quantity: int.tryParse(_qtyController.text) ?? 0,
                  expiryDate: _expiryDate ?? DateTime.now(),
                  batchNumber: _batchController.text,
                  barcode: _barcodeController.text, // Save barcode
                  status: MedicineStatus.inStock, // Default status
                  pharmacyId: pharmacyId,
                  lowStockThreshold:
                      int.tryParse(_thresholdController.text) ?? 0,
                );

                if (isEdit) {
                  await inventoryVM.editMedicine(medicine, user.name, user.id);
                  Navigator.pop(context);
                } else {
                  await inventoryVM.addMedicine(medicine, user.name, user.id);
                  Navigator.pushNamed(context, '/inventory');
                }
              },
              child: Text(isEdit ? 'Update' : 'Add Medicine'),
            ),
          ],
        ),
      ),
    );
  }
}
