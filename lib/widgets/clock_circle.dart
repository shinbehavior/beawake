// lib/widgets/Clock_circle.dart
import 'package:flutter/material.dart';
import 'dart:math';

class ClockCircle extends StatefulWidget {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const ClockCircle({Key? key, required this.startTime, required this.endTime}) : super(key: key);

  @override
  _ClockCircleState createState() => _ClockCircleState();
}

class _ClockCircleState extends State<ClockCircle> with SingleTickerProviderStateMixin {
  late double _startAngle;
  late double _endAngle;
  bool _isDraggingStart = false;
  bool _isDraggingEnd = false;

  @override
  void initState() {
    super.initState();
    _startAngle = _calculateAngle(widget.startTime);
    _endAngle = _calculateAngle(widget.endTime);
  }

  double _calculateAngle(TimeOfDay time) {
    double hourAngle = (time.hour % 12) * 30.0;
    double minuteAngle = (time.minute / 60) * 30.0;
    return (hourAngle + minuteAngle) * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset center = box.size.center(Offset.zero);
        Offset position = details.localPosition - center;

        double angle = atan2(position.dy, position.dx);
        if (angle < 0) angle += 2 * pi;

        setState(() {
          if (_isDraggingStart) {
            _startAngle = angle;
          } else if (_isDraggingEnd) {
            _endAngle = angle;
          }
        });
      },
      onPanStart: (details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset center = box.size.center(Offset.zero);
        Offset position = details.localPosition - center;

        double angle = atan2(position.dy, position.dx);
        if (angle < 0) angle += 2 * pi;

        double distanceFromStart = (angle - _startAngle).abs();
        double distanceFromEnd = (angle - _endAngle).abs();

        setState(() {
          _isDraggingStart = distanceFromStart < distanceFromEnd;
          _isDraggingEnd = distanceFromEnd <= distanceFromStart;
        });
      },
      onPanEnd: (_) {
        setState(() {
          _isDraggingStart = false;
          _isDraggingEnd = false;
        });
      },
      child: CustomPaint(
        painter: ClockCirclePainter(_startAngle, _endAngle),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Action for the button
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Start sleep'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClockCirclePainter extends CustomPainter {
  final double startAngle;
  final double endAngle;

  ClockCirclePainter(this.startAngle, this.endAngle);

  @override
  void paint(Canvas canvas, Size size) {
    Paint circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    Paint progressPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    Offset center = size.center(Offset.zero);
    double radius = size.width / 2;

    canvas.drawCircle(center, radius, circlePaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, endAngle - startAngle, false, progressPaint);

    _drawHandle(canvas, center, radius, startAngle);
    _drawHandle(canvas, center, radius, endAngle);
  }

  void _drawHandle(Canvas canvas, Offset center, double radius, double angle) {
    Offset handleCenter = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );
    canvas.drawCircle(handleCenter, 10, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}