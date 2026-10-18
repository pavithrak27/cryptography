import 'package:equatable/equatable.dart';

class WatchlistItem extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final double currentPrice;
  final double priceChangePercentage24h;

  const WatchlistItem({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.priceChangePercentage24h,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> j) => WatchlistItem(
        id: j['id'] ?? '',
        symbol: ((j['symbol'] ?? '') as String).toUpperCase(),
        name: j['name'] ?? '',
        currentPrice: (j['current_price'] as num?)?.toDouble() ?? 0,
        priceChangePercentage24h:
            (j['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      );

  bool get isGain => priceChangePercentage24h >= 0;

  @override
  List<Object?> get props =>
      [id, currentPrice, priceChangePercentage24h];
}
