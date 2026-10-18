import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:flutter/material.dart';

class StatChip extends StatelessWidget {
  final String label;
  final String value;

  const StatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.statLabelBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.statLabelBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppFonts.statLabel),
            const SizedBox(height: 2),
            Text(value, style: AppFonts.statValue),
          ],
        ),
      ),
    );
  }
}

