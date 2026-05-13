import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ATSScoreMeter extends StatefulWidget {
  final int score;
  final bool animate;

  const ATSScoreMeter({super.key, required this.score, this.animate = true});

  @override
  State<ATSScoreMeter> createState() => _ATSScoreMeterState();
}

class _ATSScoreMeterState extends State<ATSScoreMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.animate) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ATSScoreMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(begin: 0, end: widget.score.toDouble()).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'ats_score',
      child: SizedBox(
        width: 120,
        height: 120,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: _ATSPainter(_animation.value),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_animation.value.toInt()}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'ATS Score',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ATSPainter extends CustomPainter {
  final double score;

  _ATSPainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawArc(rect, -3.14159 / 2, 3.14159 * 2, false, backgroundPaint);

    Color arcColor;
    if (score > 75) {
      arcColor = const Color(0xFF4CAF50);
    } else if (score >= 50) {
      arcColor = const Color(0xFFFFC107);
    } else {
      arcColor = const Color(0xFFF44336);
    }

    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 3.14159 * 2;
    canvas.drawArc(rect, -3.14159 / 2, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}