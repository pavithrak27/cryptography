import 'package:equatable/equatable.dart';

class MarketStats extends Equatable {
  final double totalMarketCap;
  final double totalVolume;
  final double btcDominance;
  final int activeCryptocurrencies;
  final double marketCapChange24h;

  const MarketStats({
    required this.totalMarketCap,
    required this.totalVolume,
    required this.btcDominance,
    required this.activeCryptocurrencies,
    required this.marketCapChange24h,
  });

  
factory MarketStats.fromJson(Map<String, dynamic> json) {
  final marketCap = json['total_market_cap'];
  final volume = json['total_volume'];
  final dominance = json['market_cap_percentage'];

  return MarketStats(
    totalMarketCap: (
      marketCap is Map
          ? marketCap['usd'] as num
          : marketCap as num
    ).toDouble(),

    totalVolume: (
      volume is Map
          ? volume['usd'] as num
          : volume as num
    ).toDouble(),

    btcDominance: (
      dominance is Map
          ? dominance['btc'] as num
          : json['btc_dominance'] as num
    ).toDouble(),

    activeCryptocurrencies:
        (json['active_cryptocurrencies'] as num).toInt(),

    marketCapChange24h:
        ((json['market_cap_change_percentage_24h'] ?? 0) as num)
            .toDouble(),
  );
}


  @override
  List<Object?> get props => [
        totalMarketCap,
        totalVolume,
        btcDominance,
        activeCryptocurrencies,
        marketCapChange24h,
      ];
}
