import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/market_stats.dart';
import 'package:equatable/equatable.dart';

class MarketStatsState extends Equatable {
  final Status status;
  final MarketStats? data;
  final String error;

  const MarketStatsState({
    this.status = Status.loading,
    this.data,
    this.error = '',
  });

  MarketStatsState copyWith({
    Status? status,
    MarketStats? data,
    String? error,
  }) =>
      MarketStatsState(
        status: status ?? this.status,
        data: data ?? this.data,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [status, data, error];
}
