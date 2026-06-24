import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị hệ thống'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const CircleAvatar(radius: 18, child: Text('A', style: TextStyle(fontSize: 14))),
          const SizedBox(width: 12),
        ],
      ),
      drawer: _buildAdminDrawer(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System overview
            _buildSystemStats(),
            const SizedBox(height: 24),

            Text('Hoạt động hệ thống', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _buildActivityChart(),
            const SizedBox(height: 24),

            Text('Quản lý nhanh', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _buildManagementGrid(context),
            const SizedBox(height: 24),

            Text('Trường học mới đăng ký', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            _buildSchoolsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context) {
    final menuItems = [
      ('Dashboard', Icons.dashboard_rounded),
      ('Trường học', Icons.school_rounded),
      ('Giáo viên', Icons.person_rounded),
      ('Học sinh', Icons.people_rounded),
      ('Lớp học', Icons.class_rounded),
      ('Ngân hàng câu hỏi', Icons.quiz_rounded),
      ('Trò chơi', Icons.sports_esports_rounded),
      ('Báo cáo', Icons.bar_chart_rounded),
      ('Cài đặt', Icons.settings_rounded),
    ];

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text('Quản trị viên', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                const Text('GameLearn Platform', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menuItems.length,
              itemBuilder: (_, i) => ListTile(
                leading: Icon(menuItems[i].$2, color: AppTheme.primaryColor),
                title: Text(menuItems[i].$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => Navigator.pop(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                horizontalTitleGap: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStats() {
    final stats = [
      ('1,248', 'Học sinh', Icons.people, const Color(0xFF6C63FF)),
      ('84', 'Giáo viên', Icons.person_outline, const Color(0xFF43E97B)),
      ('12', 'Trường học', Icons.school_outlined, const Color(0xFFFFBE0B)),
      ('8,942', 'Câu hỏi', Icons.quiz_outlined, const Color(0xFFFF6584)),
      ('342', 'Game đã chơi', Icons.sports_esports, const Color(0xFF4FACFE)),
      ('87%', 'Tham gia', Icons.trending_up, const Color(0xFFFF9A9E)),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: s.$4.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s.$3, color: s.$4, size: 20),
              ),
              const SizedBox(height: 6),
              Text(s.$1, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: s.$4)),
              Text(s.$2, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center),
            ],
          ),
        ).animate(delay: (e.key * 60).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
      }).toList(),
    );
  }

  Widget _buildActivityChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 200,
            getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  const weeks = ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                  return Text(weeks[v.toInt() % 7], style: const TextStyle(fontSize: 11, color: Colors.grey));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 580), FlSpot(1, 720), FlSpot(2, 650),
                FlSpot(3, 890), FlSpot(4, 820), FlSpot(5, 950), FlSpot(6, 1100),
              ],
              isCurved: true,
              color: AppTheme.primaryColor,
              barWidth: 3,
              belowBarData: BarAreaData(show: true, color: AppTheme.primaryColor.withOpacity(0.1)),
              dotData: FlDotData(
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4, color: AppTheme.primaryColor, strokeWidth: 2, strokeColor: Colors.white,
                ),
              ),
            ),
            LineChartBarData(
              spots: const [
                FlSpot(0, 200), FlSpot(1, 350), FlSpot(2, 280),
                FlSpot(3, 420), FlSpot(4, 380), FlSpot(5, 480), FlSpot(6, 520),
              ],
              isCurved: true,
              color: AppTheme.accentColor,
              barWidth: 3,
              belowBarData: BarAreaData(show: true, color: AppTheme.accentColor.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildManagementGrid(BuildContext context) {
    final items = [
      ('Thêm trường', Icons.add_business, AppTheme.primaryColor),
      ('Thêm GV', Icons.person_add, AppTheme.accentColor),
      ('Import HS', Icons.upload_file, Colors.orange),
      ('Tạo câu hỏi', Icons.add_circle, AppTheme.secondaryColor),
      ('Xuất báo cáo', Icons.download, Colors.blue),
      ('Phân quyền', Icons.security, Colors.purple),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: items.asMap().entries.map((e) {
        final item = e.value;
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: item.$3.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.$3.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: item.$3, size: 28),
                const SizedBox(height: 8),
                Text(
                  item.$1,
                  style: TextStyle(color: item.$3, fontWeight: FontWeight.w700, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ).animate(delay: (e.key * 60).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
      }).toList(),
    );
  }

  Widget _buildSchoolsList() {
    final schools = [
      ('THCS Nguyễn Du', 'Hà Nội', 256, true),
      ('Tiểu học Lê Lợi', 'HCM', 180, false),
      ('THCS Trần Hưng Đạo', 'Đà Nẵng', 142, false),
    ];

    return Column(
      children: schools.asMap().entries.map((e) {
        final s = e.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text('${s.$2} • ${s.$3} học sinh',
                        style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (s.$4 ? AppTheme.accentColor : AppTheme.warningColor).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  s.$4 ? 'Đang dùng' : 'Mới',
                  style: TextStyle(
                    color: s.$4 ? AppTheme.accentColor : AppTheme.warningColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ).animate(delay: (e.key * 100 + 300).ms).fadeIn().slideX(begin: -0.1);
      }).toList(),
    );
  }
}
