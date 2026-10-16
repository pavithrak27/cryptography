

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

class FilterChanged extends CoinListEvent {
  final FilterBy filter;
  FilterChanged(this.filter);
}
