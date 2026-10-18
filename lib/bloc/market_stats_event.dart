abstract class MarketStatsEvent {}

class MarketStatsRequested extends MarketStatsEvent {
  final bool silent;
  MarketStatsRequested({this.silent = false});
}
