import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:equatable/equatable.dart';

class CoinListState extends Equatable {
  final Status status;
  final List<Coin> coins;
  final String query, error;
  final SortBy sortBy;
  final bool ascending;
  final FilterBy filter;

  const CoinListState({
    this.status = Status.loading,
    this.coins = const [],
    this.query = '',
    this.error = '',
    this.sortBy = SortBy.marketCap,
    this.ascending = false,
    this.filter = FilterBy.all,
  });

  CoinListState copyWith({
    Status? status,
    List<Coin>? coins,
    String? query,
    String? error,
    SortBy? sortBy,
    bool? ascending,
    FilterBy? filter,
  }) =>
      CoinListState(
        status: status ?? this.status,
        coins: coins ?? this.coins,
        query: query ?? this.query,
        error: error ?? this.error,
        sortBy: sortBy ?? this.sortBy,
        ascending: ascending ?? this.ascending,
        filter: filter ?? this.filter,
      );

  List<Coin> get visible {
    final q = query.toLowerCase();
    final list = coins.where((c) {
      final matchSearch = c.name.toLowerCase().contains(q) ||
          c.symbol.toLowerCase().contains(q);
      final matchFilter = filter == FilterBy.all ||
          (filter == FilterBy.gainers && c.priceChangePercentage24h > 0) ||
          (filter == FilterBy.losers && c.priceChangePercentage24h < 0);
      return matchSearch && matchFilter;
    }).toList();

    int compare(Coin a, Coin b) {
      switch (sortBy) {
        case SortBy.marketCap:
          return a.marketCap.compareTo(b.marketCap);
        case SortBy.price:
          return a.currentPrice.compareTo(b.currentPrice);
        case SortBy.volume:
          return a.totalVolume.compareTo(b.totalVolume);
        case SortBy.change:
          return a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h);
      }
    }

    list.sort((a, b) => ascending ? compare(a, b) : compare(b, a));
    return list;
  }

  @override
  List<Object?> get props =>
      [status, coins, query, error, sortBy, ascending, filter];
}