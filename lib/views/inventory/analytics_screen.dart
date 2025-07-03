import 'package:flutter/material.dart';
import '../widgets/offline_banner.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/analytics_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final analyticsVM =
          Provider.of<AnalyticsViewModel>(context, listen: false);
      analyticsVM.loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final analyticsVM = Provider.of<AnalyticsViewModel>(context);
    final user = authVM.user;

    if (user == null || !(user.isPharmacist || user.isStockManager)) {
      return Scaffold(
        appBar: AppBar(title: Text('Analytics')),
        body:
            Center(child: Text('Access Denied: Pharmacist/Stock Manager Only')),
      );
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final horizontalPadding = isLandscape ? 40.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Analytics',
            style: TextStyle(
                color: Colors.teal[800], fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.teal),
            onPressed: () => analyticsVM.loadAnalytics(),
          ),
        ],
      ),
      body: SafeArea(
        child: analyticsVM.isLoading
            ? Center(child: CircularProgressIndicator())
            : analyticsVM.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${analyticsVM.error}'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => analyticsVM.loadAnalytics(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OfflineBanner(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Analytics',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal[800])),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    _statCard(
                                        'Total Medicines',
                                        '${analyticsVM.inventoryStats['totalMedicines'] ?? 0}',
                                        Colors.teal),
                                    SizedBox(width: 16),
                                    _statCard(
                                        'Low Stock',
                                        '${analyticsVM.inventoryStats['lowStock'] ?? 0}',
                                        Colors.orange),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    _statCard(
                                        'Expired',
                                        '${analyticsVM.inventoryStats['expired'] ?? 0}',
                                        Colors.red),
                                    SizedBox(width: 16),
                                    _statCard(
                                        'Categories',
                                        '${analyticsVM.inventoryStats['categories'] ?? 0}',
                                        Colors.blueGrey),
                                  ],
                                ),
                                SizedBox(height: 24),
                                Text('Stock Levels Over Time',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                SizedBox(height: 10),
                                Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: Colors.teal[50],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: true),
                                        titlesData: FlTitlesData(
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                    value.toInt().toString(),
                                                    style: TextStyle(
                                                        fontSize: 12));
                                              },
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                const days = [
                                                  'Mon',
                                                  'Tue',
                                                  'Wed',
                                                  'Thu',
                                                  'Fri',
                                                  'Sat',
                                                  'Sun'
                                                ];
                                                if (value.toInt() >= 0 &&
                                                    value.toInt() <
                                                        days.length) {
                                                  return Text(
                                                      days[value.toInt()],
                                                      style: TextStyle(
                                                          fontSize: 12));
                                                }
                                                return Text('');
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: false),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: analyticsVM
                                                .getStockLevelSpots(),
                                            isCurved: true,
                                            color: Colors.teal,
                                            barWidth: 4,
                                            dotData: FlDotData(show: true),
                                            belowBarData:
                                                BarAreaData(show: false),
                                          ),
                                        ],
                                        lineTouchData: LineTouchData(
                                          touchTooltipData:
                                              LineTouchTooltipData(
                                            tooltipBgColor: Colors.teal[100] ??
                                                Color(0xFFB2DFDB),
                                            getTooltipItems: (touchedSpots) {
                                              return touchedSpots.map((spot) {
                                                const days = [
                                                  'Mon',
                                                  'Tue',
                                                  'Wed',
                                                  'Thu',
                                                  'Fri',
                                                  'Sat',
                                                  'Sun'
                                                ];
                                                return LineTooltipItem(
                                                  '${days[spot.x.toInt()]}: ${spot.y.toInt()} units',
                                                  TextStyle(
                                                      color: Colors.teal[900],
                                                      fontWeight:
                                                          FontWeight.bold),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text('Expiry Rate Analysis',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                SizedBox(height: 10),
                                Container(
                                  height: 220,
                                  decoration: BoxDecoration(
                                    color: Colors.teal[50],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: PieChart(
                                          PieChartData(
                                            sections: analyticsVM
                                                .getExpiryRateSections(),
                                            sectionsSpace: 4,
                                            centerSpaceRadius: 30,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _legendBubble(
                                              Color(0xFF008080), 'Valid'),
                                          SizedBox(width: 12),
                                          _legendBubble(
                                              Color(0xFFFFA500), 'Expiring'),
                                          SizedBox(width: 12),
                                          _legendBubble(
                                              Color(0xFFFF0000), 'Expired'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (analyticsVM.topMedicines.isNotEmpty) ...[
                                  SizedBox(height: 24),
                                  Text('Top Medicines by Stock Level',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.teal[50],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          analyticsVM.topMedicines.length,
                                      itemBuilder: (context, index) {
                                        final medicine =
                                            analyticsVM.topMedicines[index];
                                        return ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.teal[100],
                                            child: Icon(Icons.medication,
                                                color: Colors.teal[700]),
                                          ),
                                          title: Text(
                                              medicine['name'] ?? 'Unknown'),
                                          subtitle: Text(
                                              'Quantity: ${medicine['quantity']}'),
                                          trailing: Text(
                                            medicine['status']
                                                    ?.toString()
                                                    .split('.')
                                                    .last ??
                                                '',
                                            style: TextStyle(
                                              color: medicine['status']
                                                          ?.toString()
                                                          .contains(
                                                              'critical') ==
                                                      true
                                                  ? Colors.red
                                                  : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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

  Widget _legendBubble(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13)),
      ],
    );
  }
}
// TODO: Add navigation to this screen from the Inventory or Dashboard.
