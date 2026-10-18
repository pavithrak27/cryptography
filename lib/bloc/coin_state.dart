import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:equatable/equatable.dart';

class CoinListState extends Equatable {
  final Status status;
  final List<Coin> coins;
  final String query;
  final String error;
  final SortBy sortBy;
  final bool ascending;
  final double? minPrice;
  final double? maxPrice;
  final int page;
  final int perPage;

  const CoinListState({
    this.status = Status.loading,
    this.coins = const [],
    this.query = '',
    this.error = '',
    this.sortBy = SortBy.marketCap,
    this.ascending = false,
    this.minPrice,
    this.maxPrice,
    this.page = 1,
    this.perPage = 20,
  });

  bool get hasActiveFilter =>
      minPrice != null || maxPrice != null;

  bool get hasActiveSort =>
      sortBy != SortBy.marketCap || ascending;

  CoinListState copyWith({
    Status? status,
    List<Coin>? coins,
    String? query,
    String? error,
    SortBy? sortBy,
    bool? ascending,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    int? page,
    int? perPage,
  }) =>
      CoinListState(
        status: status ?? this.status,
        coins: coins ?? this.coins,
        query: query ?? this.query,
        error: error ?? this.error,
        sortBy: sortBy ?? this.sortBy,
        ascending: ascending ?? this.ascending,
        minPrice: minPrice == _sentinel ? this.minPrice : (minPrice as double?),
        maxPrice: maxPrice == _sentinel ? this.maxPrice : (maxPrice as double?),
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
      );

  List<Coin> get visible => coins;

  @override
  List<Object?> get props => [
        status,
        coins,
        query,
        error,
        sortBy,
        ascending,
        minPrice,
        maxPrice,
        page,
        perPage,
      ];
}

/// Sentinel object to distinguish "not provided" from null
const _sentinel = Object();