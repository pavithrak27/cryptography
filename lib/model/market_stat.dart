import 'coin.dart';

class MarketStats {
  final double totalMarketCap, totalVolume, btcDominance, ethDominance, marketCapChange24h;
  final int activeCoins;

  MarketStats({
    required this.totalMarketCap, required this.totalVolume, required this.btcDominance,
    required this.ethDominance, required this.marketCapChange24h, required this.activeCoins,
  });

  factory MarketStats.fromJson(Map<String, dynamic> j) => MarketStats(
        totalMarketCap: toD(j['totalMarketCap']),
        totalVolume: toD(j['totalVolume']),
        btcDominance: toD(j['btcDominance']),
        ethDominance: toD(j['ethDominance']),
        marketCapChange24h: toD(j['marketCapChange24h']),
        activeCoins: (j['activeCoins'] as num?)?.toInt() ?? 0,
      );
}
