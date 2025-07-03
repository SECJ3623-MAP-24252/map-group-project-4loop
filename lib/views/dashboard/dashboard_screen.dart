import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../inventory/scan_barcode_screen.dart';
import '../inventory/stock_alerts_screen.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';
import '../inventory/audit_logs_screen.dart';
import '../widgets/offline_banner.dart';
import '../notifications/notifications_screen.dart';
import '../inventory/analytics_screen.dart';
import '../inventory/inventory_screen.dart';
import '../chat/chat_user_selection_screen.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../inventory/add_edit_medicine_screen.dart';
import '../../models/medicine.dart';
import '../../viewmodels/notification_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Medicine>? _lastMedicines;
  String? _lastPharmacyId;

  @override
  Widget build(BuildContext context) {
    final dashboardVM = Provider.of<DashboardViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final inventoryVM = Provider.of<InventoryViewModel>(context);
    final notificationVM = Provider.of<NotificationViewModel>(context);
    final user = authVM.user;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Only call loadDashboard if medicines or pharmacyId have changed
    if (_lastMedicines != inventoryVM.medicines ||
        _lastPharmacyId != authVM.user?.pharmacyId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dashboardVM.loadDashboard(
          inventoryVM.medicines,
          authVM.user?.pharmacyId ?? '',
        );
      });
      _lastMedicines = inventoryVM.medicines;
      _lastPharmacyId = authVM.user?.pharmacyId;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (user != null)
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.teal[700]),
                  tooltip: 'Notifications',
                  onPressed: () {
                    notificationVM.markAllRead();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationsScreen()),
                    );
                  },
                ),
                if (notificationVM.hasUnread)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: isLandscape
            ? Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OfflineBanner(),
                          Text('Dashboard',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[800])),
                          SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statCard(
                                  Icons.inventory_2,
                                  'Total Items',
                                  dashboardVM.totalItems.toString(),
                                  Colors.teal),
                              _statCard(
                                  Icons.warning_amber_rounded,
                                  'Low Stock',
                                  dashboardVM.lowStock.toString(),
                                  Colors.orange),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _statCard(Icons.delete_forever, 'Expired',
                                  dashboardVM.expired.toString(), Colors.red),
                              _statCard(
                                  Icons.category,
                                  'Categories',
                                  dashboardVM.categories.toString(),
                                  Colors.blueGrey),
                            ],
                          ),
                          SizedBox(height: 24),
                          if (user != null &&
                              (user.isPharmacist || user.isStockManager)) ...[
                            Text('Quick Actions',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal[700],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      foregroundColor: Colors.white,
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                ScanBarcodeScreen()),
                                      );
                                    },
                                    icon: Icon(Icons.qr_code_scanner,
                                        color: Colors.white),
                                    label: Text('Scan Barcode'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (user != null && user.isStockManager)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal[700],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 14),
                                        foregroundColor: Colors.white,
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () => Navigator.pushNamed(
                                          context, '/inventory'),
                                      icon:
                                          Icon(Icons.add, color: Colors.white),
                                      label: Text('Add Stock'),
                                    ),
                                  ),
                                if (user != null && user.isPharmacist)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal[700],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                        padding:
                                            EdgeInsets.symmetric(vertical: 14),
                                        foregroundColor: Colors.white,
                                        textStyle: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AddEditMedicineScreen()),
                                        );
                                      },
                                      icon:
                                          Icon(Icons.add, color: Colors.white),
                                      label: Text('Add Medicine'),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 24),
                          ],
                          if (user != null && user.isPharmacist) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal[700],
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      foregroundColor: Colors.white,
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AuditLogsScreen()),
                                      );
                                    },
                                    icon: Icon(Icons.history,
                                        color: Colors.white),
                                    label: Text('View Audit Logs'),
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
                                      padding:
                                          EdgeInsets.symmetric(vertical: 14),
                                      foregroundColor: Colors.white,
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AnalyticsScreen()),
                                      );
                                    },
                                    icon: Icon(Icons.bar_chart,
                                        color: Colors.white),
                                    label: Text('View Analytics'),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                          ],
                          // Staff: no quick actions, audit logs, or analytics
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.teal[50],
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recent Activity',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18)),
                            SizedBox(height: 8),
                            if (dashboardVM.isLoading)
                              Center(child: CircularProgressIndicator())
                            else if (dashboardVM.error != null)
                              Center(
                                  child: Text('Error: ${dashboardVM.error}',
                                      style: TextStyle(color: Colors.red)))
                            else if (dashboardVM.recentAuditLogs.isEmpty)
                              Center(
                                  child: Text('No recent activity',
                                      style:
                                          TextStyle(color: Colors.grey[600])))
                            else
                              ...dashboardVM.recentAuditLogs.map((log) => Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    elevation: 1,
                                    child: ListTile(
                                      leading: Icon(log.icon, color: log.color),
                                      title: Text(log.typeLabel,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: log.color)),
                                      subtitle: Text(log.medicineName),
                                      trailing: Text(
                                          _formatTimestamp(log.timestamp),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700])),
                                    ),
                                  )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OfflineBanner(),
                    Text('Dashboard',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800])),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statCard(Icons.inventory_2, 'Total Items',
                            dashboardVM.totalItems.toString(), Colors.teal),
                        _statCard(Icons.warning_amber_rounded, 'Low Stock',
                            dashboardVM.lowStock.toString(), Colors.orange),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statCard(Icons.delete_forever, 'Expired',
                            dashboardVM.expired.toString(), Colors.red),
                        _statCard(Icons.category, 'Categories',
                            dashboardVM.categories.toString(), Colors.blueGrey),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text('Quick Actions',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 10),
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
                        const SizedBox(width: 16),
                        if (user != null && user.isStockManager)
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
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/inventory'),
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text('Add Stock'),
                            ),
                          ),
                        if (user != null && user.isPharmacist)
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
                                      builder: (_) => AddEditMedicineScreen()),
                                );
                              },
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text('Add Medicine'),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 24),
                    if (user != null && user.isPharmacist) ...[
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
                                      builder: (_) => AuditLogsScreen()),
                                );
                              },
                              icon: Icon(Icons.history, color: Colors.white),
                              label: Text('View Audit Logs'),
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
                              icon: Icon(Icons.bar_chart, color: Colors.white),
                              label: Text('View Analytics'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                    ],
                    Text('Recent Activity',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 8),
                    if (dashboardVM.isLoading)
                      Center(child: CircularProgressIndicator())
                    else if (dashboardVM.error != null)
                      Center(
                          child: Text('Error: ${dashboardVM.error}',
                              style: TextStyle(color: Colors.red)))
                    else if (dashboardVM.recentAuditLogs.isEmpty)
                      Center(
                          child: Text('No recent activity',
                              style: TextStyle(color: Colors.grey[600])))
                    else
                      ...dashboardVM.recentAuditLogs.map((log) => Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 1,
                            child: ListTile(
                              leading: Icon(log.icon, color: log.color),
                              title: Text(log.typeLabel,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: log.color)),
                              subtitle: Text(log.medicineName),
                              trailing: Text(_formatTimestamp(log.timestamp),
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[700])),
                            ),
                          )),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/inventory');
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20, color: color)),
              SizedBox(height: 4),
              Text(label,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
