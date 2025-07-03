import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/analytics_service.dart';
import '../services/firebase/firebase_analytics_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService = FirebaseAnalyticsService();
  final String pharmacyId;

  Map<String, dynamic> _inventoryStats = {};
  Map<String, dynamic> get inventoryStats => _inventoryStats;

  List<Map<String, dynamic>> _stockLevels = [];
  List<Map<String, dynamic>> get stockLevels => _stockLevels;

  Map<String, double> _expiryRates = {};
  Map<String, double> get expiryRates => _expiryRates;

  List<Map<String, dynamic>> _topMedicines = [];
  List<Map<String, dynamic>> get topMedicines => _topMedicines;

  Map<String, int> _categoryDistribution = {};
  Map<String, int> get categoryDistribution => _categoryDistribution;

  String? _error;
  String? get error => _error;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AnalyticsViewModel(this.pharmacyId) {
    if (pharmacyId.isNotEmpty) {
      loadAnalytics();
    }
  }

  Future<void> loadAnalytics() async {
    if (pharmacyId.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all analytics data in parallel
      await Future.wait([
        _loadInventoryStats(),
        _loadStockLevels(),
        _loadExpiryRates(),
        _loadTopMedicines(),
        _loadCategoryDistribution(),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadInventoryStats() async {
    _inventoryStats = await _analyticsService.getInventoryStats(pharmacyId);
  }

  Future<void> _loadStockLevels() async {
    _stockLevels = await _analyticsService.getStockLevelsOverTime(pharmacyId);
  }

  Future<void> _loadExpiryRates() async {
    _expiryRates = await _analyticsService.getExpiryRateAnalysis(pharmacyId);
  }

  Future<void> _loadTopMedicines() async {
    _topMedicines = await _analyticsService.getTopMedicines(pharmacyId);
  }

  Future<void> _loadCategoryDistribution() async {
    _categoryDistribution =
        await _analyticsService.getCategoryDistribution(pharmacyId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper methods for the UI
  List<FlSpot> getStockLevelSpots() {
    return _stockLevels.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['stock'].toDouble());
    }).toList();
  }

  List<PieChartSectionData> getExpiryRateSections() {
    if (_expiryRates.isEmpty) return [];

    return [
      PieChartSectionData(
        value: _expiryRates['valid'] ?? 0,
        color: Colors.teal,
        title: '${(_expiryRates['valid'] ?? 0).round()}%',
        radius: 50,
        titleStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      PieChartSectionData(
        value: _expiryRates['expiring'] ?? 0,
        color: Colors.orange,
        title: '${(_expiryRates['expiring'] ?? 0).round()}%',
        radius: 50,
        titleStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      PieChartSectionData(
        value: _expiryRates['expired'] ?? 0,
        color: Colors.red,
        title: '${(_expiryRates['expired'] ?? 0).round()}%',
        radius: 50,
        titleStyle: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ];
  }
}
