import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakCard extends StatelessWidget {
  final int streak;
  final int maxStreak;

  const StreakCard({super.key, required this.streak, required this.maxStreak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '🔥',
            style: const TextStyle(fontSize: 48),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak ngày liên tiếp!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Kỷ lục cá nhân: $maxStreak ngày',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          // Week dots
          Column(
            children: List.generate(7, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: i < streak % 7 ? Colors.white : Colors.white38,
                  shape: BoxShape.circle,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
