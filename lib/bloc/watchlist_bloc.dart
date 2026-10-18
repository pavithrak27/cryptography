import 'dart:async';

import 'package:crypto_mobile/bloc/watchlist_event.dart';
import 'package:crypto_mobile/bloc/watchlist_repository.dart';
import 'package:crypto_mobile/bloc/watchlist_state.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/service/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository _repository;
  Timer? _timer;

  WatchlistBloc(CoinService service)
      : _repository = WatchlistRepository(service),
        super(const WatchlistState()) {
    on<WatchlistRequested>(_load);
    on<WatchlistItemRemoved>(_remove);

    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => add(WatchlistRequested(silent: true)),
    );
  }

  Future<void> _load(
    WatchlistRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    if (!event.silent && state.items.isEmpty) {
      emit(state.copyWith(status: Status.loading));
    }
    try {
      final items = await _repository.getWatchlist();
      emit(state.copyWith(status: Status.success, items: items));
    } catch (e) {
      if (state.items.isNotEmpty) return;
      emit(state.copyWith(status: Status.error, error: e.toString()));
    }
  }

  Future<void> _remove(
    WatchlistItemRemoved event,
    Emitter<WatchlistState> emit,
  ) async {
    final updated =
        state.items.where((i) => i.id != event.coinId).toList();
    emit(state.copyWith(items: updated));
    try {
      await _repository.removeFromWatchlist(event.coinId);
    } catch (_) {
      add(WatchlistRequested());
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
