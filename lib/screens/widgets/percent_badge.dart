import 'package:flutter/material.dart';

class PercentBadge extends StatelessWidget {
  final double value;
  final Color bgColor;
  final TextStyle textStyle;
  final IconData icon;
  final Color iconColor;

  const PercentBadge({super.key, 
    required this.value,
    required this.bgColor,
    required this.textStyle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final sign = value > 0 ? '+' : '';
    final label = '$sign${value.toStringAsFixed(2)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}

