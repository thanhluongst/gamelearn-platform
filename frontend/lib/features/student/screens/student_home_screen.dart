import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/xp_progress_bar.dart';
import '../widgets/daily_mission_card.dart';
import '../widgets/game_mode_card.dart';
import '../widgets/quick_stats_widget.dart';
import '../widgets/streak_card.dart';

class StudentHomeScreen extends StatelessWidget {
  final Widget child;
  const StudentHomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return BottomNavigationBar(
      currentIndex: _navIndex(location),
      onTap: (i) => _onNavTap(context, i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_esports_rounded), label: 'Chơi game'),
        BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: 'Bảng xếp hạng'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Hồ sơ'),
      ],
    );
  }

  int _navIndex(String location) {
    if (location.contains('/student/leaderboard')) return 2;
    if (location.contains('/student/profile')) return 3;
    if (location.contains('/game')) return 1;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/student');
      case 1: context.go('/game/join');
      case 2: context.go('/student/leaderboard');
      case 3: context.go('/student/profile');
    }
  }
}

class StudentDashboardBody extends StatelessWidget {
  const StudentDashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Colorful app bar with XP
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Xin chào! 👋',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                Text(
                                  'Nguyễn Văn A',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            // Avatar with level badge
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white24,
                                  child: Icon(Icons.person, color: Colors.white, size: 32),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warningColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Lv.12',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const XpProgressBar(currentXp: 850, nextLevelXp: 1200, level: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick stats
                const QuickStatsWidget(
                  totalAnswered: 342,
                  correctAnswers: 289,
                  currentStreak: 7,
                  rank: 3,
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 20),

                // Streak card
                const StreakCard(streak: 7, maxStreak: 15)
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 20),

                // Daily missions
                Text(
                  'Nhiệm vụ hôm nay',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 12),
                const DailyMissionCard(
                  title: 'Trả lời đúng 10 câu',
                  progress: 6,
                  target: 10,
                  xpReward: 30,
                  coinReward: 15,
                  icon: Icons.question_answer,
                ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.2),
                const SizedBox(height: 8),
                const DailyMissionCard(
                  title: 'Tham gia 2 trận đấu',
                  progress: 1,
                  target: 2,
                  xpReward: 50,
                  coinReward: 25,
                  icon: Icons.sports_esports,
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                const SizedBox(height: 24),

                // Game modes
                Text(
                  'Chọn trò chơi',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(delay: 450.ms),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    GameModeCard(
                      title: 'Câu Cá',
                      subtitle: 'Câu cá kiến thức',
                      icon: '🎣',
                      gradient: AppTheme.gameGradients['fishing']!,
                      playerCount: '1-30',
                      onTap: () {},
                    ).animate(delay: 500.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    GameModeCard(
                      title: 'Đào Vàng',
                      subtitle: 'Săn kho báu',
                      icon: '⛏️',
                      gradient: AppTheme.gameGradients['gold_mining']!,
                      playerCount: '1-50',
                      onTap: () {},
                    ).animate(delay: 550.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    GameModeCard(
                      title: 'Đua Xe',
                      subtitle: 'Tốc độ tri thức',
                      icon: '🏎️',
                      gradient: AppTheme.gameGradients['car_race']!,
                      playerCount: '2-20',
                      onTap: () {},
                    ).animate(delay: 600.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    GameModeCard(
                      title: 'Đấu Trường',
                      subtitle: 'PvP thời gian thực',
                      icon: '⚔️',
                      gradient: AppTheme.gameGradients['arena']!,
                      playerCount: '2-50',
                      onTap: () {},
                    ).animate(delay: 650.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    GameModeCard(
                      title: 'Ghép Tranh',
                      subtitle: 'Giải đố vui',
                      icon: '🧩',
                      gradient: AppTheme.gameGradients['puzzle']!,
                      playerCount: '1-30',
                      onTap: () {},
                    ).animate(delay: 700.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                    GameModeCard(
                      title: 'Kho Báu',
                      subtitle: 'Khám phá bản đồ',
                      icon: '🗺️',
                      gradient: AppTheme.gameGradients['treasure_hunt']!,
                      playerCount: '1-20',
                      onTap: () {},
                    ).animate(delay: 750.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
                  ],
                ),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
