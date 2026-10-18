import 'package:crypto_mobile/core/enum.dart';

abstract class CoinListEvent {}

class CoinsRequested extends CoinListEvent {
  final bool silent;
  CoinsRequested({this.silent = false});
}

class SearchChanged extends CoinListEvent {
  final String query;
  SearchChanged(this.query);
}

class SortChanged extends CoinListEvent {
  final SortBy sortBy;
  SortChanged(this.sortBy);
}

class SortReset extends CoinListEvent {}

class FilterApplied extends CoinListEvent {
  final double? minPrice;
  final double? maxPrice;

  FilterApplied({
    this.minPrice,
    this.maxPrice,
  });
}

class FilterReset extends CoinListEvent {}

class PageChanged extends CoinListEvent {
  final int page;
  PageChanged(this.page);
}
