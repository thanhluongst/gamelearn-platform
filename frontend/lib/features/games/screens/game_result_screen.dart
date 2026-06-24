import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class GameResultScreen extends StatefulWidget {
  final String sessionId;
  const GameResultScreen({super.key, required this.sessionId});

  @override
  State<GameResultScreen> createState() => _GameResultScreenState();
}

class _GameResultScreenState extends State<GameResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Stars background
          ...List.generate(20, (i) => Positioned(
            top: (i * 37.5) % MediaQuery.of(context).size.height,
            left: (i * 53.3) % MediaQuery.of(context).size.width,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.1 + (i % 3) * 0.05),
              size: 8 + (i % 4) * 4,
            ),
          )),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Title
                  const Text(
                    '🏁 KẾT QUẢ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.5, 0.5), duration: 600.ms),

                  const SizedBox(height: 24),

                  // Player rank card
                  _buildMyRankCard(),

                  const SizedBox(height: 24),

                  // Top 3 leaderboard
                  _buildTopLeaderboard(),

                  const SizedBox(height: 24),

                  // XP & Rewards gained
                  _buildRewardsSection(),

                  const SizedBox(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/student'),
                          icon: const Icon(Icons.home, color: Colors.white),
                          label: const Text('Về trang chủ', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.replay),
                          label: const Text('Chơi lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ).animate(delay: 800.ms).slideY(begin: 0.3).fadeIn(),
                ],
              ),
            ),
          ),

          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 40,
            shouldLoop: false,
            colors: const [
              Color(0xFFFFD700), Color(0xFF6C63FF),
              Color(0xFFFF6584), Color(0xFF43E97B),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyRankCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🥇',
            style: TextStyle(fontSize: 64),
          ).animate(delay: 200.ms).scale(begin: const Offset(0, 0), curve: Curves.elasticOut),

          const SizedBox(height: 8),
          const Text(
            'Hạng 1!',
            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
          ).animate(delay: 300.ms).fadeIn(),

          const Text(
            'Xuất sắc! Bạn đứng đầu lớp!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ).animate(delay: 400.ms).fadeIn(),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatBadge(value: '950', label: 'Điểm', icon: '⭐'),
              _StatBadge(value: '9/10', label: 'Đúng', icon: '✅'),
              _StatBadge(value: 'x8', label: 'Combo', icon: '🔥'),
            ],
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    ).animate(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)).fadeIn();
  }

  Widget _buildTopLeaderboard() {
    final players = [
      ('Bạn', 950, '🥇'),
      ('Trần B', 820, '🥈'),
      ('Lê C', 780, '🥉'),
      ('Phạm D', 650, '4'),
      ('Hoàng E', 600, '5'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Bảng xếp hạng',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          ...players.asMap().entries.map((e) {
            final p = e.value;
            final isMe = e.key == 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withOpacity(0.15) : Colors.transparent,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(p.$3,
                        style: TextStyle(fontSize: e.key < 3 ? 22 : 16),
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      p.$1,
                      style: TextStyle(
                        color: isMe ? Colors.amber : Colors.white,
                        fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${p.$2}',
                    style: TextStyle(
                      color: isMe ? Colors.amber : Colors.white70,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ).animate(delay: (e.key * 100 + 400).ms).slideX(begin: -0.2).fadeIn();
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎁 Phần thưởng',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _RewardItem(value: '+250', label: 'XP', emoji: '⚡'),
              _RewardItem(value: '+150', label: 'Xu', emoji: '🪙'),
              _RewardItem(value: '+1', label: 'Huy hiệu', emoji: '🏅'),
            ],
          ),
        ],
      ),
    ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2);
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final String icon;

  const _StatBadge({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _RewardItem extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;

  const _RewardItem({required this.value, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }
}
