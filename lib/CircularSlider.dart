import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  CircularSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  _CircularSliderState createState() => _CircularSliderState();
}

class _CircularSliderState extends State<CircularSlider> {
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _angle =
        (widget.value - widget.min) / (widget.max - widget.min) * 2 * math.pi;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      child: CustomPaint(
        painter: _CircularSliderPainter(angle: _angle),
        size: Size(200, 200), // You can pass the size you want
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset center = renderBox.size.center(Offset.zero);
    final Offset position = renderBox.globalToLocal(details.globalPosition);
    final double angle =
        math.atan2(position.dy - center.dy, position.dx - center.dx);

    if (angle >= 0 && angle <= 2 * math.pi) {
      widget.onChanged(
          (angle / (2 * math.pi)) * (widget.max - widget.min) + widget.min);
      setState(() {
        _angle = angle;
      });
    }
  }
}

class _CircularSliderPainter extends CustomPainter {
  final double angle;

  _CircularSliderPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    final Offset center = size.center(Offset.zero);
    final double radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);

    final Paint progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.blue, Colors.blueAccent],
        startAngle: 0.0,
        endAngle: angle,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi / 2,
        angle, false, progressPaint);

    final Paint thumbPaint = Paint()..color = Colors.blueAccent;

    final double thumbAngle = angle - math.pi / 2;
    final Offset thumbCenter =
        Offset(math.cos(thumbAngle) * radius, math.sin(thumbAngle) * radius) +
            center;
    canvas.drawCircle(thumbCenter, 15, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
