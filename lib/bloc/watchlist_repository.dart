import 'package:crypto_mobile/model/watchlist_item.dart';
import 'package:crypto_mobile/service/api_service.dart';

class WatchlistRepository {
  final CoinService _service;

  WatchlistRepository(this._service);

  Future<List<WatchlistItem>> getWatchlist() async {
    final response = await _service.get('/api/watchlist');

    if (response is Map<String, dynamic> &&
        response['success'] == true &&
        response['data'] is List) {
      final List data = response['data'] as List;
      return data
          .map((json) =>
              WatchlistItem.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    throw ApiException('Unexpected format from /api/watchlist');
  }

  Future<void> removeFromWatchlist(String coinId) async {
    await _service.delete('/api/watchlist/$coinId');
  }
}
