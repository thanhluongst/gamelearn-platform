import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero profile header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                            ),
                            child: const CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.person, size: 56, color: Colors.white),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppTheme.warmGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                              ),
                              child: const Text(
                                'Lv.12',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ).animate().scale(duration: 500.ms),
                      const SizedBox(height: 12),
                      const Text(
                        'Nguyễn Văn A',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const Text(
                        'Học Sinh • Lớp 6A',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      // XP bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('850 XP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                                const Text('1200 XP → Lv.13', style: TextStyle(color: Colors.white60, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: const LinearProgressIndicator(
                                value: 0.71,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(Colors.amber),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Body
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats overview
                _buildStatsGrid(),
                const SizedBox(height: 24),

                // Performance chart
                Text('Tiến độ 7 ngày gần nhất',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                _buildWeeklyChart(),
                const SizedBox(height: 24),

                // Subject performance
                Text('Năng lực theo môn',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                _buildSubjectPerformance(),
                const SizedBox(height: 24),

                // Achievements
                Text('Huy hiệu',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                _buildAchievements(),
                const SizedBox(height: 24),

                // AI Analysis
                _buildAiAnalysis(),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      ('342', 'Câu đã làm', Icons.quiz, AppTheme.primaryColor),
      ('289', 'Câu đúng', Icons.check_circle, AppTheme.accentColor),
      ('85%', 'Chính xác', Icons.gps_fixed, Colors.orange),
      ('#3', 'Hạng lớp', Icons.emoji_events, AppTheme.warningColor),
      ('2,450', 'XP', Icons.bolt, Colors.purple),
      ('7 ngày', 'Streak', Icons.local_fire_department, Colors.deepOrange),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: stats.asMap().entries.map((e) {
        final s = e.value;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(s.$3, color: s.$4, size: 24),
              const SizedBox(height: 6),
              Text(s.$1, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: s.$4)),
              Text(s.$2, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ],
          ),
        ).animate(delay: (e.key * 60).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
      }).toList(),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 50,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                  return Text(days[v.toInt()], style: const TextStyle(fontSize: 11, color: Colors.grey));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: [
            for (var i = 0; i < 7; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: [35, 42, 28, 45, 38, 15, 8][i].toDouble(),
                  gradient: AppTheme.primaryGradient,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ]),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSubjectPerformance() {
    final subjects = [
      ('Toán học', 0.85, const Color(0xFF6C63FF)),
      ('Tin học', 0.92, const Color(0xFF43E97B)),
      ('Khoa học', 0.68, const Color(0xFFFF6584)),
      ('Lịch sử', 0.55, const Color(0xFFFFBE0B)),
      ('Tiếng Anh', 0.78, const Color(0xFF4FACFE)),
    ];

    return Column(
      children: subjects.asMap().entries.map((e) {
        final s = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: s.$3.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    s.$1.substring(0, 2),
                    style: TextStyle(color: s.$3, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('${(s.$2 * 100).round()}%',
                            style: TextStyle(color: s.$3, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: s.$2,
                        backgroundColor: s.$3.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(s.$3),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate(delay: (e.key * 80).ms).fadeIn().slideX(begin: -0.1);
      }).toList(),
    );
  }

  Widget _buildAchievements() {
    final badges = [
      ('🏆', 'Combo 10', 'silver', true),
      ('⭐', '100 Câu Đúng', 'silver', true),
      ('🔥', '7 Ngày Streak', 'gold', true),
      ('⚡', 'Siêu Tốc', 'gold', false),
      ('💎', '1000 Câu Đúng', 'diamond', false),
      ('👑', 'Huyền Thoại', 'legend', false),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final b = badges[i];
          final isEarned = b.$4;
          return Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: isEarned
                      ? _badgeGradient(b.$3)
                      : null,
                  color: isEarned ? null : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isEarned ? [
                    BoxShadow(
                      color: _badgeColor(b.$3).withOpacity(0.4),
                      blurRadius: 8,
                    )
                  ] : null,
                ),
                child: Center(
                  child: Opacity(
                    opacity: isEarned ? 1 : 0.4,
                    child: Text(b.$1, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ).animate(delay: (i * 80).ms).scale(begin: const Offset(0.7, 0.7)),
              const SizedBox(height: 6),
              Text(
                b.$2,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isEarned ? Colors.black87 : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }

  LinearGradient _badgeGradient(String tier) {
    return switch (tier) {
      'bronze' => const LinearGradient(colors: [Color(0xFFCD7F32), Color(0xFFB8860B)]),
      'silver' => const LinearGradient(colors: [Color(0xFFC0C0C0), Color(0xFF808080)]),
      'gold' => const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
      'diamond' => const LinearGradient(colors: [Color(0xFF00BFFF), Color(0xFF1E90FF)]),
      'master' => const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
      'legend' => const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF4500)]),
      _ => AppTheme.primaryGradient,
    };
  }

  Color _badgeColor(String tier) {
    return switch (tier) {
      'bronze' => const Color(0xFFCD7F32),
      'silver' => const Color(0xFFC0C0C0),
      'gold' => const Color(0xFFFFD700),
      'diamond' => const Color(0xFF00BFFF),
      _ => AppTheme.primaryColor,
    };
  }

  Widget _buildAiAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.4), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber),
              const SizedBox(width: 8),
              const Text(
                'Phân tích AI',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _AiPoint(
            icon: '💪',
            title: 'Điểm mạnh',
            points: ['Tin học: 92% - Xuất sắc', 'Toán học: 85% - Rất tốt'],
            color: Color(0xFF43E97B),
          ),
          const SizedBox(height: 12),
          const _AiPoint(
            icon: '📈',
            title: 'Cần cải thiện',
            points: ['Lịch sử: 55% - Cần ôn tập', 'Khoa học: 68% - Khá'],
            color: Color(0xFFFF6584),
          ),
          const SizedBox(height: 12),
          const _AiPoint(
            icon: '🎯',
            title: 'Khuyến nghị',
            points: [
              'Ôn lại chương Thế giới cổ đại',
              'Luyện tập thêm câu hỏi dạng tư duy',
              'Duy trì streak học tập mỗi ngày',
            ],
            color: Color(0xFFFFBE0B),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}

class _AiPoint extends StatelessWidget {
  final String icon;
  final String title;
  final List<String> points;
  final Color color;

  const _AiPoint({
    required this.icon,
    required this.title,
    required this.points,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(p, style: const TextStyle(color: Colors.white70, fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
