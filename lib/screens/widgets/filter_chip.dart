import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:flutter/material.dart';

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterChip({super.key, 
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.activeChipBg : AppColors.inactiveChipBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.activeChipBg : AppColors.chipBorder,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.cardShadowPrimary,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: selected ? AppFonts.activeChipLabel : AppFonts.chipLabel,
        ),
      ),
    );
  }
}
