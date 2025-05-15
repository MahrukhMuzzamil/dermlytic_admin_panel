import 'package:flutter/material.dart';

class LinearGradientSlider extends StatelessWidget {
  final double progress;

  const LinearGradientSlider({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10, // Set the height of the slider (you can adjust as needed)
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5), // Rounded corners
        gradient: const LinearGradient(
          colors: [
            Colors.red,
            Colors.yellow,
            Colors.green,
          ], // Gradient from green to red
        ),
      ),
      child: CustomPaint(
        painter: _SliderPainter(progress),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double progress;

  _SliderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double progressWidth = size.width * progress;
    const double lineHeight = 20; // Height of the vertical line
    const double lineWidth = 2; // Width of the vertical line
    final double lineX = progressWidth - (lineWidth / 2);
    final double lineY = (size.height - lineHeight) / 2;

    // Draw the vertical line at the position of the progress
    final Paint linePaint = Paint()
      ..color = Colors.black // Set the color of the line
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(lineX, lineY, lineWidth, lineHeight), linePaint);
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
