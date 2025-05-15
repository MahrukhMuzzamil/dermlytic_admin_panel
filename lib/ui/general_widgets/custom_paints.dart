import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const DottedLine({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: DottedLinePainter(color),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1 // Adjust the stroke width as needed
      ..style = PaintingStyle.stroke;

    const dashWidth = 3; // Adjust the width of each segment
    const dashSpace = 5; // Adjust the space between segments

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class DottedCircles extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const DottedCircles({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: DottedCirclePainter(color),
    );
  }
}

class DottedCirclePainter extends CustomPainter {
  final Color color;

  DottedCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2 // Adjust the stroke width as needed
      ..style = PaintingStyle.stroke;

    const gap = 4; // Adjust the gap between dots
    const dashWidth = 2.0; // Adjust the width of the dots

    double startX = 0;
    while (startX < size.width) {
      canvas.drawCircle(Offset(startX, size.height / 2), dashWidth, paint);
      startX += gap + dashWidth * 2;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
