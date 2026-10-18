import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:flutter/material.dart';

class RankBadge extends StatelessWidget {
  final int rank;

  const RankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.rankBadgeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.rankBadgeBorder, width: 1),
      ),
      child: Text('#$rank', style: AppFonts.rankBadge),
    );
  }
}

