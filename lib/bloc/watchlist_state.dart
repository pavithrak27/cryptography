import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/watchlist_item.dart';
import 'package:equatable/equatable.dart';

class WatchlistState extends Equatable {
  final Status status;
  final List<WatchlistItem> items;
  final String error;

  const WatchlistState({
    this.status = Status.loading,
    this.items = const [],
    this.error = '',
  });

  WatchlistState copyWith({
    Status? status,
    List<WatchlistItem>? items,
    String? error,
  }) =>
      WatchlistState(
        status: status ?? this.status,
        items: items ?? this.items,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [status, items, error];
}
