import 'dart:async';

import 'package:crypto_mobile/bloc/market_stats_event.dart';
import 'package:crypto_mobile/bloc/market_stats_repository.dart';
import 'package:crypto_mobile/bloc/market_stats_state.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/service/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MarketStatsBloc extends Bloc<MarketStatsEvent, MarketStatsState> {
  final MarketStatsRepository _repository;
  Timer? _timer;

  MarketStatsBloc(CoinService service)
      : _repository = MarketStatsRepository(service),
        super(const MarketStatsState()) {
    on<MarketStatsRequested>(_load);

    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => add(MarketStatsRequested(silent: true)),
    );
  }

  Future<void> _load(
    MarketStatsRequested event,
    Emitter<MarketStatsState> emit,
  ) async {
    if (!event.silent && state.data == null) {
      emit(state.copyWith(status: Status.loading));
    }

    try {
      final stats = await _repository.getMarketStats();
      emit(state.copyWith(status: Status.success, data: stats));
    } catch (e) {
      if (state.data != null) return; // keep showing old data silently
      emit(state.copyWith(
        status: Status.error,
        error: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
