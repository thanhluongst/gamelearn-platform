import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class QuickStatsWidget extends StatelessWidget {
  final int totalAnswered;
  final int correctAnswers;
  final int currentStreak;
  final int rank;

  const QuickStatsWidget({
    super.key,
    required this.totalAnswered,
    required this.correctAnswers,
    required this.currentStreak,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = totalAnswered > 0
        ? (correctAnswers / totalAnswered * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '$accuracy%',
            label: 'Chính xác',
            icon: Icons.gps_fixed,
            color: AppTheme.accentColor,
          ),
          _Divider(),
          _StatItem(
            value: '$totalAnswered',
            label: 'Câu đã làm',
            icon: Icons.quiz_rounded,
            color: AppTheme.primaryColor,
          ),
          _Divider(),
          _StatItem(
            value: '🔥$currentStreak',
            label: 'Streak',
            icon: null,
            color: Colors.orange,
          ),
          _Divider(),
          _StatItem(
            value: '#$rank',
            label: 'Hạng lớp',
            icon: Icons.emoji_events,
            color: AppTheme.warningColor,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
        ],
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }
}
