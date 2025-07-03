import 'package:flutter/material.dart';
import 'threshold_management_screen.dart';
import '../widgets/offline_banner.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class StockAlertsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> mockAlerts = [
    {
      'type': 'Critical Low Stock',
      'medicine': 'Insulin Glargine 100IU',
      'current': 2,
      'threshold': 10,
      'status': 'critical',
    },
    {
      'type': 'Low Stock',
      'medicine': 'Metformin 500mg',
      'current': 8,
      'threshold': 15,
      'status': 'low',
    },
    {
      'type': 'Stock Warning',
      'medicine': 'Lisinopril 10mg',
      'current': 12,
      'threshold': 20,
      'status': 'warning',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.user;
    if (user == null || !(user.isPharmacist || user.isStockManager)) {
      return Scaffold(
        appBar: AppBar(title: Text('Stock Alerts')),
        body:
            Center(child: Text('Access Denied: Pharmacist/Stock Manager Only')),
      );
    }
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 40.0 : 20.0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Alerts',
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
                      Text('Stock Alerts',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[800])),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: mockAlerts.length,
                          itemBuilder: (context, i) {
                            final alert = mockAlerts[i];
                            Color color;
                            IconData icon;
                            switch (alert['status']) {
                              case 'critical':
                                color = Colors.red;
                                icon = Icons.error;
                                break;
                              case 'low':
                                color = Colors.orange;
                                icon = Icons.warning;
                                break;
                              default:
                                color = Colors.amber;
                                icon = Icons.info;
                            }
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              child: ListTile(
                                leading: Icon(icon, color: color, size: 32),
                                title: Text(alert['type'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: color)),
                                subtitle: Text(
                                    '${alert['medicine']}\nCurrent: ${alert['current']} units | Threshold: ${alert['threshold']} units'),
                                isThreeLine: true,
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: color,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    // TODO: Implement restock logic and Firestore update
                                  },
                                  child: Text('Restock Now'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ThresholdManagementScreen()),
                          );
                        },
                        icon: Icon(Icons.settings),
                        label: Text('Manage Thresholds'),
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
// TODO: Add navigation to this screen from the dashboard or inventory as needed.
