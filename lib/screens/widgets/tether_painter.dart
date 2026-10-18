import 'package:crypto_mobile/constants/colors.dart';
import 'package:flutter/material.dart';

class TetherPainter extends CustomPainter {
  const TetherPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.usdtIcon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final fill = Paint()
      ..color = AppColors.usdtIcon
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.48),
        width: w * 0.86,
        height: h * 0.44,
      ),
      stroke,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.30),
          width: w * 0.6,
          height: 2.5,
        ),
        const Radius.circular(1),
      ),
      fill,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, h * 0.54),
          width: 2.5,
          height: h * 0.5,
        ),
        const Radius.circular(1),
      ),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
