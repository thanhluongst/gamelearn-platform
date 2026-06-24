import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimerWidget extends StatefulWidget {
  final int duration; // seconds
  final VoidCallback onTimeUp;
  final bool isActive;

  const TimerWidget({
    super.key,
    required this.duration,
    required this.onTimeUp,
    required this.isActive,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.isActive) _startTimer();
  }

  @override
  void didUpdateWidget(TimerWidget old) {
    super.didUpdateWidget(old);
    if (old.isActive && !widget.isActive) _timer?.cancel();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _remaining--);

      if (_remaining <= 5) _pulseController.repeat(reverse: true);
      if (_remaining <= 0) {
        timer.cancel();
        widget.onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Color get _timerColor {
    final ratio = _remaining / widget.duration;
    if (ratio > 0.5) return const Color(0xFF43E97B);
    if (ratio > 0.25) return const Color(0xFFFFBE0B);
    return const Color(0xFFFF4D6D);
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _remaining / widget.duration;

    return ScaleTransition(
      scale: _remaining <= 5
          ? Tween(begin: 1.0, end: 1.1).animate(_pulseController)
          : const AlwaysStoppedAnimation(1.0),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular progress
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                value: ratio,
                strokeWidth: 6,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(_timerColor),
              ),
            ),
            // Number
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$_remaining',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  's',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
