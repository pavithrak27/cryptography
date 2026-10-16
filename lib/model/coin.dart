import 'package:equatable/equatable.dart';

double toD(dynamic v) => (v as num?)?.toDouble() ?? 0;

class Coin extends Equatable {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final int marketCapRank;
  final double currentPrice;
  final double marketCap;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double circulatingSupply;
  final double ath;
  final double atl;
  final double? totalSupply;
  final double? maxSupply;
  final String? lastUpdated;

  const Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.marketCapRank,
    required this.currentPrice,
    required this.marketCap,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.circulatingSupply,
    required this.ath,
    required this.atl,
    this.totalSupply,
    this.maxSupply,
    this.lastUpdated,
  });

  /// Parses CoinGecko API JSON format:
  /// { "current_price": ..., "price_change_percentage_24h": ..., ... }
  factory Coin.fromJson(Map<String, dynamic> j) => Coin(
        id: j['id'] ?? '',
        symbol: (j['symbol'] ?? '').toString().toUpperCase(),
        name: j['name'] ?? '',
        image: j['image'] ?? '',
        marketCapRank: (j['market_cap_rank'] as num?)?.toInt() ?? 0,
        currentPrice: toD(j['current_price']),
        marketCap: toD(j['market_cap']),
        totalVolume: toD(j['total_volume']),
        high24h: toD(j['high_24h']),
        low24h: toD(j['low_24h']),
        priceChange24h: toD(j['price_change_24h']),
        priceChangePercentage24h: toD(j['price_change_percentage_24h']),
        circulatingSupply: toD(j['circulating_supply']),
        ath: toD(j['ath']),
        atl: toD(j['atl']),
        totalSupply: (j['total_supply'] as num?)?.toDouble(),
        maxSupply: (j['max_supply'] as num?)?.toDouble(),
        lastUpdated: j['last_updated'] as String?,
      );

  @override
  List<Object?> get props => [
        id,
        currentPrice,
        priceChangePercentage24h,
        marketCap,
        totalVolume,
      ];
}
