abstract class WatchlistEvent {}

class WatchlistRequested extends WatchlistEvent {
  final bool silent;
  WatchlistRequested({this.silent = false});
}

class WatchlistItemRemoved extends WatchlistEvent {
  final String coinId;
  WatchlistItemRemoved(this.coinId);
}
