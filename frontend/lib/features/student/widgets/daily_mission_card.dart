import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_theme.dart';

class DailyMissionCard extends StatelessWidget {
  final String title;
  final int progress;
  final int target;
  final int xpReward;
  final int coinReward;
  final IconData icon;

  const DailyMissionCard({
    super.key,
    required this.title,
    required this.progress,
    required this.target,
    required this.xpReward,
    required this.coinReward,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (progress / target).clamp(0.0, 1.0);
    final isDone = progress >= target;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? AppTheme.accentColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? AppTheme.accentColor : const Color(0xFFE0E0FF),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isDone ? AppTheme.successGradient : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isDone ? Icons.check : icon, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                LinearPercentIndicator(
                  percent: ratio,
                  lineHeight: 8,
                  backgroundColor: const Color(0xFFE0E0FF),
                  progressColor: isDone ? AppTheme.accentColor : AppTheme.primaryColor,
                  barRadius: const Radius.circular(4),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 4),
                Text(
                  '$progress/$target',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Rewards
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _RewardChip(value: '$xpReward XP', color: AppTheme.primaryColor),
              const SizedBox(height: 4),
              _RewardChip(
                value: '$coinReward 🪙',
                color: AppTheme.warningColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final String value;
  final Color color;

  const _RewardChip({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
