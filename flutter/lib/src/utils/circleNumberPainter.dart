import 'package:flutter/material.dart';
import 'dart:math';

class CircleNumberWidget extends StatelessWidget {
  final int number;
  final Color color;

  CircleNumberWidget({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CircleNumberPainter(number: number, color: color),
      child: Container(),
    );
  }
}

class CircleNumberPainter extends CustomPainter {
  final int number;
  final Color color;

  CircleNumberPainter({required this.number, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = color // 사용자가 지정한 색상으로 변경
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 1, // 숫자의 크기 조절
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
