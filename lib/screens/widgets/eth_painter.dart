import 'package:crypto_mobile/constants/colors.dart';
import 'package:flutter/material.dart';

class EthPainter extends CustomPainter {
  const EthPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ethIcon
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;

    canvas.drawPath(
      Path()
        ..moveTo(cx, 0)
        ..lineTo(w * 0.14, h * 0.54)
        ..lineTo(cx, h * 0.43)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, 0)
        ..lineTo(w * 0.86, h * 0.54)
        ..lineTo(cx, h * 0.43)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, h * 0.50)
        ..lineTo(w * 0.14, h * 0.60)
        ..lineTo(cx, h)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, h * 0.50)
        ..lineTo(w * 0.86, h * 0.60)
        ..lineTo(cx, h)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
