import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class TeacherAnalyticsScreen extends StatelessWidget {
  final String classId;
  const TeacherAnalyticsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích lớp học'),
        actions: [
          IconButton(icon: const Icon(Icons.download), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview metrics
            _buildOverviewMetrics(),
            const SizedBox(height: 24),

            // Subject heatmap
            Text('Năng lực theo môn', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _buildSubjectHeatmap(),
            const SizedBox(height: 24),

            // Top & weak students
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🏆 Top 5', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildStudentList(isTop: true),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📉 Cần hỗ trợ', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      _buildStudentList(isTop: false),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Question difficulty distribution
            Text('Phân bố độ khó câu hỏi', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _buildDifficultyChart(),
            const SizedBox(height: 24),

            // Recent games
            Text('Trò chơi gần đây', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _buildRecentGames(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics() {
    final metrics = [
      ('35', 'Sĩ số', Icons.people, AppTheme.primaryColor),
      ('92%', 'Tham gia', Icons.how_to_reg, AppTheme.accentColor),
      ('7.8', 'Điểm TB', Icons.star, Colors.orange),
      ('+15%', 'Tiến bộ', Icons.trending_up, Colors.green),
    ];

    return Row(
      children: metrics.asMap().entries.map((e) {
        final m = e.value;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [m.$4.withOpacity(0.8), m.$4],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(m.$3, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text(m.$1, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                Text(m.$2, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
              ],
            ),
          ).animate(delay: (e.key * 80).ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectHeatmap() {
    final subjects = [
      ('Toán học', [0.82, 0.75, 0.88, 0.65, 0.92]),
      ('Tin học', [0.90, 0.85, 0.92, 0.78, 0.88]),
      ('Lịch sử', [0.55, 0.48, 0.62, 0.40, 0.70]),
      ('Khoa học', [0.70, 0.65, 0.78, 0.55, 0.82]),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              SizedBox(width: 80),
              Expanded(child: Text('Dễ', style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center)),
              Expanded(child: Text('TB', style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center)),
              Expanded(child: Text('Khó', style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center)),
              Expanded(child: Text('Trắc nghiệm', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center)),
              Expanded(child: Text('Tự luận', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center)),
            ],
          ),
          const SizedBox(height: 8),
          ...subjects.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(width: 80, child: Text(s.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                ...s.$2.map((v) => Expanded(
                  child: Container(
                    height: 28,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: _heatColor(v),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${(v * 100).round()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          )),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Color _heatColor(double value) {
    if (value >= 0.8) return const Color(0xFF2E7D32);
    if (value >= 0.65) return const Color(0xFF4CAF50);
    if (value >= 0.5) return const Color(0xFFFFA000);
    return const Color(0xFFD32F2F);
  }

  Widget _buildStudentList({required bool isTop}) {
    final students = isTop
        ? [('Nguyễn A', '95%'), ('Trần B', '92%'), ('Lê C', '88%'), ('Phạm D', '85%'), ('Hoàng E', '82%')]
        : [('Vũ F', '42%'), ('Đỗ G', '48%'), ('Bùi H', '52%'), ('Đinh I', '55%'), ('Lý J', '58%')];

    final color = isTop ? AppTheme.accentColor : AppTheme.errorColor;

    return Column(
      children: students.asMap().entries.map((e) {
        final s = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Text('${e.key + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(s.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              Text(s.$2, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 40,
                    color: AppTheme.accentColor,
                    title: '40%',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  PieChartSectionData(
                    value: 35,
                    color: AppTheme.warningColor,
                    title: '35%',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  PieChartSectionData(
                    value: 25,
                    color: AppTheme.errorColor,
                    title: '25%',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
                sectionsSpace: 3,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(color: AppTheme.accentColor, label: 'Dễ', value: '40%'),
              const SizedBox(height: 12),
              _LegendItem(color: AppTheme.warningColor, label: 'Trung bình', value: '35%'),
              const SizedBox(height: 12),
              _LegendItem(color: AppTheme.errorColor, label: 'Khó', value: '25%'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildRecentGames() {
    final games = [
      ('Đua Xe - Toán học', '32/35 HS', '7.5 điểm TB', '2 giờ trước'),
      ('Câu Cá - Lịch sử', '28/35 HS', '6.8 điểm TB', 'Hôm qua'),
      ('Đấu Trường - Tin học', '35/35 HS', '8.2 điểm TB', '2 ngày trước'),
    ];

    return Column(
      children: games.asMap().entries.map((e) {
        final g = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
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
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sports_esports, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text('${g.$2} • ${g.$3}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(g.$4, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ).animate(delay: (e.key * 100 + 400).ms).fadeIn().slideX(begin: -0.1);
      }).toList(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ],
    );
  }
}
