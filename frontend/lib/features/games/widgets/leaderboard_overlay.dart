import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class LeaderboardOverlay extends StatelessWidget {
  final List<dynamic> players;
  final VoidCallback onClose;

  const LeaderboardOverlay({
    super.key,
    required this.players,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent close when tapping inside
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🏆 Bảng Xếp Hạng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        onPressed: onClose,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...players.take(10).toList().asMap().entries.map((e) {
                    final p = e.value as Map<String, dynamic>;
                    final rank = e.key + 1;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? Colors.amber.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: rank <= 3 ? Border.all(
                          color: [Colors.amber, Colors.grey.shade400, const Color(0xFFCD7F32)][rank - 1],
                          width: 1,
                        ) : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '$rank',
                              style: TextStyle(
                                fontSize: rank <= 3 ? 18 : 14,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              p['nickname'] as String? ?? 'Player',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${p['score'] ?? 0}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: (e.key * 50).ms).slideX(begin: 0.3).fadeIn();
                  }),
                ],
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
          ),
        ),
      ),
    );
  }
}
