import 'package:crypto_mobile/model/coin.dart';
import 'package:crypto_mobile/screens/widgets/stat_chip.dart';
import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final Coin coin;

  const StatRow({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatChip(
          label: '24H HIGH',
          value: _compact(coin.high24h, prefix: '\$'),
        ),
        const SizedBox(width: 6),
        StatChip(
          label: '24H LOW',
          value: _compact(coin.low24h, prefix: '\$'),
        ),
        const SizedBox(width: 6),
        StatChip(
          label: 'VOLUME',
          value: _compact(coin.totalVolume, prefix: '\$'),
        ),
      ],
    );
  }

  String _compact(double v, {String prefix = ''}) {
    if (v >= 1e12) return '$prefix${(v / 1e12).toStringAsFixed(2)}T';
    if (v >= 1e9) return '$prefix${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '$prefix${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '$prefix${(v / 1e3).toStringAsFixed(1)}K';
    return '$prefix${v.toStringAsFixed(2)}';
  }
}
