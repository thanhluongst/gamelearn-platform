import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScorePopup extends StatelessWidget {
  final int score;
  final bool isBonus;

  const ScorePopup({super.key, required this.score, this.isBonus = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      isBonus ? '+$score 🔥 Combo!' : '+$score',
      style: TextStyle(
        color: isBonus ? Colors.orange : Colors.amber,
        fontSize: isBonus ? 24 : 20,
        fontWeight: FontWeight.w900,
        shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
      ),
    )
        .animate()
        .slideY(begin: 0, end: -1.5, duration: 1000.ms)
        .fadeOut(delay: 500.ms, duration: 500.ms);
  }
}
