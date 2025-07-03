import 'package:flutter/material.dart';
import '../widgets/offline_banner.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/audit_logs_viewmodel.dart';
import '../../models/audit_log.dart';
import '../chat/chat_user_selection_screen.dart';

class AuditLogsScreen extends StatefulWidget {
  @override
  _AuditLogsScreenState createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auditLogsVM =
          Provider.of<AuditLogsViewModel>(context, listen: false);
      auditLogsVM.loadAuditLogs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final auditLogsVM = Provider.of<AuditLogsViewModel>(context);
    final user = authVM.user;

    if (user == null || !user.isPharmacist) {
      return Scaffold(
        appBar: AppBar(title: Text('Audit Logs')),
        body: Center(child: Text('Access Denied: Pharmacist Only')),
      );
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 40.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Audit Logs',
            style: TextStyle(
                color: Colors.teal[800], fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.teal),
            onPressed: () => auditLogsVM.loadAuditLogs(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OfflineBanner(),
              Text('Inventory Change History',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800])),
              SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search changes...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (query) {
                  auditLogsVM.searchAuditLogs(query);
                },
              ),
              SizedBox(height: 16),
              Expanded(
                child: auditLogsVM.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : auditLogsVM.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Error: ${auditLogsVM.error}'),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => auditLogsVM.loadAuditLogs(),
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : auditLogsVM.auditLogs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history,
                                        size: 64, color: Colors.grey[400]),
                                    SizedBox(height: 16),
                                    Text('No audit logs found',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600])),
                                    SizedBox(height: 8),
                                    Text(
                                        'Changes to inventory will appear here',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500])),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: auditLogsVM.auditLogs.length,
                                itemBuilder: (context, i) {
                                  final log = auditLogsVM.auditLogs[i];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    elevation: 2,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    child: ListTile(
                                      leading: Icon(log.icon,
                                          color: log.color, size: 32),
                                      title: Text(log.typeLabel,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: log.color)),
                                      subtitle: Text(
                                          '${log.medicineName}\n${log.details}\nBy: ${log.userName}'),
                                      isThreeLine: true,
                                      trailing: Text(
                                          _formatTimestamp(log.timestamp),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700])),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/dashboard');
          if (index == 1) Navigator.pushNamed(context, '/inventory');
          if (index == 2)
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatUserSelectionScreen()),
            );
          if (index == 3) Navigator.pushNamed(context, '/pharmacy-profile');
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
// TODO: Add navigation to this screen from the Inventory or Dashboard.
