import 'package:crypto_mobile/model/chart_point.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:crypto_mobile/model/market_stat.dart';
import 'package:crypto_mobile/service/api_service.dart';

class CoinRepository {
  final CoinService service;

  CoinRepository(this.service);

  // GET coin list
  Future<List<Coin>> getCoins({
    int page = 1,
    int perPage = 10,
    String search = '',
  }) async {
    final response = await service.get(
      '/api/coins',
      query: {
        'page': page,
        'per_page': perPage,
        if (search.isNotEmpty) 'search': search,
      },
    );

    final List data = response['data'];

    return data.map((json) => Coin.fromJson(json)).toList();
  }

  // GET coin details
  Future<Coin> getCoinDetails(String id) async {
    final response = await service.get('/api/coins/$id');

    return Coin.fromJson(response['data']);
  }

  Future<List<ChartPoint>> getChart(String id, {int days = 7}) async {
    final response = await service.get(
      '/api/coins/$id/chart',
      query: {'days': days},
    );

    final List prices = response['data']['prices'];

    return prices.map((point) {
      return ChartPoint.fromJson({'timestamp': point[0], 'price': point[1]});
    }).toList();
  }

  // GET market statistics
  Future<MarketStats> getStats() async {
    final response = await service.get('/api/global');

    return MarketStats.fromJson(response['data']);
  }

  // GET watchlist
  Future<List<Coin>> getWatchlist() async {
    final response = await service.get('/api/watchlist');

    final List data = response['data'];

    return data.map((json) => Coin.fromJson(json)).toList();
  }

  Future<void> addToWatchlist(String coinId) async {
    await service.post('/api/watchlist', body: {'coin_id': coinId});
  }

  Future<void> removeFromWatchlist(String coinId) async {
    await service.delete('/api/watchlist/$coinId');
  }
}
