import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final int seconds;
  final VoidCallback onExpired;

  const CountdownTimer({super.key, required this.seconds, required this.onExpired});

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.seconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );
    _controller.addListener(() {
      setState(() {
        _remainingSeconds = (_controller.duration!.inSeconds - _controller.value * _controller.duration!.inSeconds).toInt();
      });
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onExpired();
      }
    });
    _controller.reverse(from: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _remainingSeconds < 30 ? Colors.red : Colors.blue;
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: _controller.value,
            color: color,
          ),
          Text(
            '$_remainingSeconds',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}