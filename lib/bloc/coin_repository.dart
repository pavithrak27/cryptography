import 'package:crypto_mobile/core/api_endpoints.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/chart_point.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:crypto_mobile/model/market_stat.dart';
import 'package:crypto_mobile/service/api_service.dart';

class CoinRepository {
  final CoinService service;

  CoinRepository(this.service);

  Future<List<Coin>> getCoins({
    int page = 1,
    int perPage = 20,
    String search = '',
    SortBy sortBy = SortBy.marketCap,
    bool ascending = false,
    double? minPrice,
    double? maxPrice,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'sort_by': sortBy.apiKey,
      'order': ascending ? 'asc' : 'desc',
    };

    if (search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    if (minPrice != null) {
      query['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      query['max_price'] = maxPrice;
    }

    

    final response = await service.get(
      '$baseUrl/api/coins',
      query: query,
    );

    final List data = response['data'];
    return data.map((json) => Coin.fromJson(json)).toList();
  }

  Future<Coin> getCoinDetails(String id) async {
    final response = await service.get('$baseUrl/api/coins/$id');
    return Coin.fromJson(response['data']);
  }

  Future<List<ChartPoint>> getChart(String id, {int days = 7}) async {
    final response = await service.get(
      '$baseUrl/api/coins/$id/chart',
      query: {'days': days},
    );
    final List prices = response['data']['prices'];
    return prices.map((point) {
      return ChartPoint.fromJson({'timestamp': point[0], 'price': point[1]});
    }).toList();
  }

  Future<MarketStats> getStats() async {
    final response = await service.get('$baseUrl/api/global');
    return MarketStats.fromJson(response['data']);
  }

  Future<List<Coin>> getWatchlist() async {
    final response = await service.get('$baseUrl/api/watchlist');
    final List data = response['data'];
    return data.map((json) => Coin.fromJson(json)).toList();
  }

  Future<void> addToWatchlist(String coinId) async {
    await service.post('$baseUrl/api/watchlist', body: {'coin_id': coinId});
  }

  Future<void> removeFromWatchlist(String coinId) async {
    await service.delete('$baseUrl/api/watchlist/$coinId');
  }
}
