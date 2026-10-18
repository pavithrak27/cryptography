import 'dart:async';
import 'package:crypto_mobile/bloc/coin_event.dart';
import 'package:crypto_mobile/bloc/coin_repository.dart';
import 'package:crypto_mobile/bloc/coin_state.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/service/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CoinListBloc extends Bloc<CoinListEvent, CoinListState> {
  final CoinService service;
  late final CoinRepository repository;
  Timer? _timer;
  Timer? _debounce;

  CoinListBloc(this.service) : super(const CoinListState()) {
    repository = CoinRepository(service);

    on<CoinsRequested>(_load);

    on<SearchChanged>((event, emit) async {
      _debounce?.cancel();
      final newState = state.copyWith(
        query: event.query,
        page: 1,
        status: Status.loading,
      );
      emit(newState);
      _debounce = Timer(const Duration(milliseconds: 400), () {
        add(CoinsRequested());
      });
    });

    on<FilterApplied>((event, emit) async {
      final newState = state.copyWith(
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        page: 1,
        status: Status.loading,
      );
      emit(newState);
      await _fetchWithState(newState, emit);
    });

    on<FilterReset>((event, emit) async {
      final newState = state.copyWith(
        minPrice: null,
        maxPrice: null,
        page: 1,
        status: Status.loading,
      );
      emit(newState);
      await _fetchWithState(newState, emit);
    });

    on<SortChanged>((event, emit) async {
      final ascending =
          event.sortBy == state.sortBy ? !state.ascending : false;
      final newState = state.copyWith(
        sortBy: event.sortBy,
        ascending: ascending,
        page: 1,
        status: Status.loading,
      );
      emit(newState);
      await _fetchWithState(newState, emit);
    });

    on<SortReset>((event, emit) async {
      final newState = state.copyWith(
        sortBy: SortBy.marketCap,
        ascending: false,
        page: 1,
        status: Status.loading,
      );
      emit(newState);
      await _fetchWithState(newState, emit);
    });

    on<PageChanged>((event, emit) async {
      final newState = state.copyWith(page: event.page);
      emit(newState);
      await _fetchWithState(newState, emit);
    });

    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => add(CoinsRequested(silent: true)),
    );

    add(CoinsRequested());
  }

  Future<void> _fetchWithState(
    CoinListState targetState,
    Emitter<CoinListState> emit,
  ) async {
    try {
      final coins = await repository.getCoins(
        page: targetState.page,
        perPage: targetState.perPage,
        search: targetState.query,
        sortBy: targetState.sortBy,
        ascending: targetState.ascending,
        minPrice: targetState.minPrice,
        maxPrice: targetState.maxPrice,
      );
      emit(targetState.copyWith(status: Status.success, coins: coins));
    } catch (error) {
      if (targetState.coins.isNotEmpty) {
        emit(targetState.copyWith(status: Status.success));
        return;
      }
      emit(targetState.copyWith(
        status: Status.error,
        error: error.toString(),
      ));
    }
  }

  Future<void> _load(
    CoinsRequested event,
    Emitter<CoinListState> emit,
  ) async {
    if (!event.silent && state.coins.isEmpty) {
      emit(state.copyWith(status: Status.loading));
    }
    await _fetchWithState(state, emit);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _debounce?.cancel();
    return super.close();
  }
}