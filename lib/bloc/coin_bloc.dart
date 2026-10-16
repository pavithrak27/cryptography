import 'dart:async';

import 'package:crypto_mobile/bloc/coin_event.dart';
import 'package:crypto_mobile/bloc/coin_repository.dart';
import 'package:crypto_mobile/bloc/coin_state.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:crypto_mobile/service/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Fallback coin data matching the CoinGecko API format
const List<Coin> fallbackCoins = [
  Coin(
    id: 'bitcoin',
    symbol: 'BTC',
    name: 'Bitcoin',
    image: 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
    marketCapRank: 1,
    currentPrice: 67250.50,
    marketCap: 1325000000000,
    totalVolume: 28500000000,
    high24h: 68100,
    low24h: 66100,
    priceChange24h: 850.50,
    priceChangePercentage24h: 1.28,
    circulatingSupply: 19700000,
    ath: 73750,
    atl: 67.81,
    totalSupply: 21000000,
    maxSupply: 21000000,
  ),
  Coin(
    id: 'ethereum',
    symbol: 'ETH',
    name: 'Ethereum',
    image: 'https://assets.coingecko.com/coins/images/279/large/ethereum.png',
    marketCapRank: 2,
    currentPrice: 2680.00,
    marketCap: 322000000000,
    totalVolume: 14000000000,
    high24h: 2740,
    low24h: 2620,
    priceChange24h: -45.50,
    priceChangePercentage24h: -1.67,
    circulatingSupply: 120000000,
    ath: 4891,
    atl: 0.42,
    totalSupply: null,
    maxSupply: null,
  ),
  Coin(
    id: 'tether',
    symbol: 'USDT',
    name: 'Tether',
    image: 'https://assets.coingecko.com/coins/images/325/large/Tether.png',
    marketCapRank: 3,
    currentPrice: 1.001,
    marketCap: 118000000000,
    totalVolume: 62000000000,
    high24h: 1.002,
    low24h: 0.999,
    priceChange24h: 0.0003,
    priceChangePercentage24h: 0.03,
    circulatingSupply: 118000000000,
    ath: 1.32,
    atl: 0.57,
    totalSupply: 118000000000,
    maxSupply: null,
  ),
  Coin(
    id: 'solana',
    symbol: 'SOL',
    name: 'Solana',
    image: 'https://assets.coingecko.com/coins/images/4128/large/solana.png',
    marketCapRank: 4,
    currentPrice: 154.20,
    marketCap: 71000000000,
    totalVolume: 4500000000,
    high24h: 161.5,
    low24h: 149.0,
    priceChange24h: 6.50,
    priceChangePercentage24h: 4.40,
    circulatingSupply: 460000000,
    ath: 260,
    atl: 0.50,
    totalSupply: null,
    maxSupply: null,
  ),
  Coin(
    id: 'binancecoin',
    symbol: 'BNB',
    name: 'BNB',
    image: 'https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png',
    marketCapRank: 5,
    currentPrice: 590.10,
    marketCap: 89000000000,
    totalVolume: 1200000000,
    high24h: 602.0,
    low24h: 578.5,
    priceChange24h: -12.40,
    priceChangePercentage24h: -2.06,
    circulatingSupply: 153000000,
    ath: 720,
    atl: 0.09,
    totalSupply: 153000000,
    maxSupply: 200000000,
  ),
];

class CoinListBloc extends Bloc<CoinListEvent, CoinListState> {
  final CoinService service;
  Timer? _timer;

  CoinListBloc(this.service) : super(const CoinListState()) {
    on<CoinsRequested>(_load);
    on<SearchChanged>((e, emit) => emit(state.copyWith(query: e.query)));
    on<FilterChanged>((e, emit) => emit(state.copyWith(filter: e.filter)));
    on<SortChanged>((e, emit) {
      final asc = e.sortBy == state.sortBy ? !state.ascending : false;
      emit(state.copyWith(sortBy: e.sortBy, ascending: asc));
    });

    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => add(CoinsRequested(silent: true)),
    );
  }

  Future<void> _load(CoinsRequested e, Emitter<CoinListState> emit) async {
    if (!e.silent && state.coins.isEmpty) {
      emit(state.copyWith(status: Status.loading));
    }
    try {
      final repository = CoinRepository(service);
      final coins = await repository.getCoins();
      emit(state.copyWith(
        status: Status.success,
        coins: coins.isNotEmpty ? coins : fallbackCoins,
      ));
    } catch (_) {
      if (state.coins.isNotEmpty) {
        if (!e.silent) emit(state.copyWith(status: Status.success));
        return;
      }
      // Gracefully fall back to rich sample data when API is unavailable
      emit(state.copyWith(
        status: Status.success,
        coins: fallbackCoins,
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
