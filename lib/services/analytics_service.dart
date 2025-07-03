abstract class AnalyticsService {
  Future<Map<String, dynamic>> getInventoryStats(String pharmacyId);
  Future<List<Map<String, dynamic>>> getStockLevelsOverTime(String pharmacyId,
      {int days = 7});
  Future<Map<String, double>> getExpiryRateAnalysis(String pharmacyId);
  Future<List<Map<String, dynamic>>> getTopMedicines(String pharmacyId,
      {int limit = 10});
  Future<Map<String, int>> getCategoryDistribution(String pharmacyId);
}
