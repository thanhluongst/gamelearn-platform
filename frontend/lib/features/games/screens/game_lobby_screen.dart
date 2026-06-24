import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class GameLobbyScreen extends StatelessWidget {
  final String sessionId;

  const GameLobbyScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      '🎮 Phòng chờ',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
                    ).animate().fadeIn().slideY(begin: -0.2),
                    const SizedBox(height: 8),
                    // Join code display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.key, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'ABC123',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(),
                    const SizedBox(height: 8),
                    const Text(
                      'Chia sẻ mã này cho học sinh',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              // Game info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoChip(label: '10 câu', icon: Icons.quiz),
                    _InfoChip(label: '30s/câu', icon: Icons.timer),
                    _InfoChip(label: 'Đua xe', icon: Icons.sports_esports),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(),

              const SizedBox(height: 20),

              // Players list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Người chơi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '8/50',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: 8,
                          itemBuilder: (_, i) => Column(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: _avatarColor(i),
                                child: Text(
                                  'HS',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ).animate(delay: (i * 100).ms).scale(begin: const Offset(0, 0)),
                              const SizedBox(height: 4),
                              Text(
                                'HS ${i + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Start button (Teacher only)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: const Text('Bắt đầu trò chơi', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: Colors.black26,
                    ),
                  ),
                ).animate(delay: 400.ms).slideY(begin: 0.5).fadeIn(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _avatarColor(int i) {
    const colors = [
      Color(0xFFFF6B6B), Color(0xFF4ECDC4), Color(0xFF45B7D1),
      Color(0xFFFFA07A), Color(0xFF98D8C8), Color(0xFFFFB347),
      Color(0xFF87CEEB), Color(0xFFDDA0DD),
    ];
    return colors[i % colors.length];
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
