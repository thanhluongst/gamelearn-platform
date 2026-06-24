import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class TeacherHomeScreen extends StatelessWidget {
  final Widget child;
  const TeacherHomeScreen({super.key, required this.child});

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
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Tổng quan'),
        BottomNavigationBarItem(icon: Icon(Icons.class_rounded), label: 'Lớp học'),
        BottomNavigationBarItem(icon: Icon(Icons.quiz_rounded), label: 'Câu hỏi'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Thống kê'),
      ],
    );
  }

  int _navIndex(String location) {
    if (location.contains('/teacher/class')) return 1;
    if (location.contains('/teacher/questions')) return 2;
    if (location.contains('/teacher/analytics')) return 3;
    return 0;
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/teacher');
      case 1: context.go('/teacher/class/all');
      case 2: context.go('/teacher/questions');
      case 3: context.go('/teacher/analytics/overview');
    }
  }
}

class TeacherDashboardBody extends StatelessWidget {
  const TeacherDashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 18,
            child: Text('GV', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick actions
            _buildQuickActions(context),
            const SizedBox(height: 24),

            // Overview stats
            Text('Tổng quan', style: Theme.of(context).textTheme.headlineMedium)
                .animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            _buildOverviewStats(),
            const SizedBox(height: 24),

            // Classes list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lớp học của tôi', style: Theme.of(context).textTheme.headlineMedium),
                TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
              ],
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            _buildClassCards(context),
            const SizedBox(height: 24),

            // Participation chart
            Text('Tham gia học tập', style: Theme.of(context).textTheme.headlineMedium)
                .animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            _buildParticipationChart(),
            const SizedBox(height: 24),

            // Weak students
            Text('Học sinh cần hỗ trợ', style: Theme.of(context).textTheme.headlineMedium)
                .animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            _buildWeakStudentsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/teacher/import'),
        icon: const Icon(Icons.upload_file),
        label: const Text('Nhập câu hỏi'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      ('Tạo lớp', Icons.add_circle_outline, AppTheme.primaryColor, '/teacher/class/create'),
      ('Upload Excel', Icons.upload_file, AppTheme.accentColor, '/teacher/import'),
      ('Tạo game', Icons.sports_esports, Colors.orange, '/teacher/game/create'),
      ('Báo cáo', Icons.download, AppTheme.secondaryColor, '/teacher/report'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) => GestureDetector(
        onTap: () => context.go(a.$4),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: a.$3.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(a.$2, color: a.$3, size: 28),
            ),
            const SizedBox(height: 6),
            Text(
              a.$1,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      )).toList(),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildOverviewStats() {
    final stats = [
      ('Tổng học sinh', '156', Icons.people, AppTheme.primaryColor),
      ('Đã tham gia', '89%', Icons.how_to_reg, AppTheme.accentColor),
      ('Điểm TB', '7.8', Icons.trending_up, Colors.orange),
      ('Câu hỏi', '342', Icons.quiz, AppTheme.secondaryColor),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: stats.map((s) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: s.$4.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(s.$3, color: s.$4, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s.$2,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: s.$4)),
                Text(s.$1, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ).animate(delay: 100.ms).fadeIn()).toList(),
    );
  }

  Widget _buildClassCards(BuildContext context) {
    final classes = [
      ('6A - Toán học', 35, 92, AppTheme.coolGradient),
      ('7B - Tin học', 28, 78, AppTheme.primaryGradient),
      ('8C - Lịch sử', 32, 65, AppTheme.warmGradient),
    ];

    return Column(
      children: classes.asMap().entries.map((e) {
        final c = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: c.$4,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: c.$4.colors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.$1, style: const TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text('${c.$2} học sinh • ${c.$3}% tham gia',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => context.go('/teacher/analytics/${c.$1}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: c.$4.colors.first,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Chi tiết'),
              ),
            ],
          ),
        ).animate(delay: (e.key * 100 + 250).ms).fadeIn().slideX(begin: -0.1);
      }).toList(),
    );
  }

  Widget _buildParticipationChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                  if (value.toInt() < days.length) {
                    return Text(days[value.toInt()],
                        style: const TextStyle(fontSize: 12, color: Colors.grey));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 78), FlSpot(1, 85), FlSpot(2, 80),
                FlSpot(3, 92), FlSpot(4, 88), FlSpot(5, 60), FlSpot(6, 45),
              ],
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
              dotData: FlDotData(
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildWeakStudentsList() {
    final students = [
      ('Trần Văn B', '45%', 'Toán học', Colors.red),
      ('Lê Thị C', '52%', 'Lịch sử', Colors.orange),
      ('Phạm Văn D', '58%', 'Khoa học', Colors.amber),
    ];

    return Column(
      children: students.asMap().entries.map((e) {
        final s = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: s.$4.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: s.$4.withOpacity(0.2),
                radius: 20,
                child: Text(s.$1[0], style: TextStyle(color: s.$4, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('Yếu: ${s.$3}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: s.$4.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(s.$2, style: TextStyle(color: s.$4, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        ).animate(delay: (e.key * 100 + 400).ms).fadeIn().slideX(begin: -0.1);
      }).toList(),
    );
  }
}
