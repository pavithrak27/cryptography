import 'package:crypto_mobile/model/market_stats.dart';
import 'package:crypto_mobile/service/api_service.dart';

class MarketStatsRepository {
  final CoinService _service;

  MarketStatsRepository(this._service);

  Future<MarketStats> getMarketStats() async {
    final response = await _service.get('/api/market-stats');
      print(response);
    
    if (response is Map<String, dynamic> &&
        response['success'] == true &&
        response['data'] is Map<String, dynamic>) {
      return MarketStats.fromJson(
          response['data'] as Map<String, dynamic>);
    }
    throw ApiException('Unexpected response format from /api/market-stats');
  }
}
