import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medicine.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../widgets/offline_banner.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ThresholdManagementScreen extends StatefulWidget {
  @override
  _ThresholdManagementScreenState createState() =>
      _ThresholdManagementScreenState();
}

class _ThresholdManagementScreenState extends State<ThresholdManagementScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _updateThreshold(
      InventoryViewModel inventoryVM, Medicine medicine, String newThreshold) {
    final threshold = int.tryParse(newThreshold);
    if (threshold != null) {
      final updatedMedicine = medicine.copyWith(lowStockThreshold: threshold);
      final user = Provider.of<AuthViewModel>(context, listen: false).user;
      if (user != null) {
        inventoryVM.editMedicine(updatedMedicine, user.name, user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medicine.name} threshold updated to $threshold'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid threshold value for ${medicine.name}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final inventoryVM = Provider.of<InventoryViewModel>(context, listen: true);
    final user = authVM.user;

    if (user == null || !(user.isPharmacist || user.isStockManager)) {
      return Scaffold(
        appBar: AppBar(title: Text('Stock Thresholds')),
        body:
            Center(child: Text('Access Denied: Pharmacist/Stock Manager Only')),
      );
    }
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 40.0 : 20.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Thresholds',
            style: TextStyle(
                color: Colors.teal[800], fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OfflineBanner(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Set Low Stock Thresholds',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800])),
                      SizedBox(height: 16),
                      if (inventoryVM.isLoading)
                        Center(child: CircularProgressIndicator())
                      else if (inventoryVM.medicines.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'No medicines found in inventory.',
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: inventoryVM.medicines.length,
                          itemBuilder: (context, i) {
                            final med = inventoryVM.medicines[i];
                            final controller = _controllers.putIfAbsent(
                              med.id!,
                              () => TextEditingController(
                                text: med.lowStockThreshold?.toString() ?? '',
                              ),
                            );

                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              child: ListTile(
                                leading: Icon(Icons.medication,
                                    color: Colors.teal[700]),
                                title: Text(med.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Threshold: '),
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: TextField(
                                              controller: controller,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                              ),
                                              onSubmitted: (value) =>
                                                  _updateThreshold(
                                                      inventoryVM, med, value),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => _updateThreshold(
                                            inventoryVM, med, controller.text),
                                        child: Text('Save'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// TODO: Add navigation to this screen from StockAlertsScreen.
