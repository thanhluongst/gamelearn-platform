import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class TeacherClassScreen extends StatefulWidget {
  final String classId;
  const TeacherClassScreen({super.key, required this.classId});

  @override
  State<TeacherClassScreen> createState() => _TeacherClassScreenState();
}

class _TeacherClassScreenState extends State<TeacherClassScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lớp 6A - Toán học'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Học sinh'),
            Tab(text: 'Trò chơi'),
            Tab(text: 'Bài tập'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentsTab(),
          _buildGamesTab(context),
          _buildAssignmentsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGameDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Tạo game'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildStudentsTab() {
    final students = List.generate(35, (i) => {
      'name': 'Học sinh ${i + 1}',
      'xp': 2500 - i * 60,
      'accuracy': 85 - i,
      'level': 12 - i ~/ 4,
    });

    return Column(
      children: [
        // Search + filter
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm học sinh...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.filter_list),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Thêm'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        // Stats summary
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _MiniStat(value: '35', label: 'Sĩ số', color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              _MiniStat(value: '32', label: 'Đang hoạt động', color: AppTheme.accentColor),
              const SizedBox(width: 8),
              _MiniStat(value: '7.8', label: 'ĐTB', color: Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: students.length,
            itemBuilder: (_, i) {
              final s = students[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                      child: Text('${i + 1}', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w700, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('Lv.${s['level']} • ${s['xp']} XP', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${s['accuracy']}%',
                        style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (i * 30).ms).fadeIn();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGamesTab(BuildContext context) {
    final games = [
      ('Kiểm tra Chương 3', 'Đua Xe', '25/35', '7.5 TB', true),
      ('Ôn tập Phương trình', 'Câu Cá', '30/35', '8.2 TB', true),
      ('Bài kiểm tra tuần', 'Đấu Trường', '0/35', '—', false),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Create game button
        ElevatedButton.icon(
          onPressed: () => _showCreateGameDialog(context),
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Tạo trò chơi mới'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        ...games.asMap().entries.map((e) {
          final g = e.value;
          final isCompleted = g.$5;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompleted ? AppTheme.accentColor.withOpacity(0.3) : const Color(0xFFE0E0FF),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(g.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isCompleted ? AppTheme.accentColor : AppTheme.primaryColor).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isCompleted ? 'Đã xong' : 'Chưa bắt đầu',
                        style: TextStyle(
                          color: isCompleted ? AppTheme.accentColor : AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _GameTag(label: g.$2, icon: Icons.sports_esports),
                    const SizedBox(width: 8),
                    _GameTag(label: g.$3, icon: Icons.people),
                    const SizedBox(width: 8),
                    _GameTag(label: g.$4, icon: Icons.star),
                  ],
                ),
                if (!isCompleted) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/game/lobby/session-123'),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Bắt đầu ngay'),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                    ),
                  ),
                ],
              ],
            ),
          ).animate(delay: (e.key * 100 + 100).ms).fadeIn().slideY(begin: 0.1);
        }),
      ],
    );
  }

  Widget _buildAssignmentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Chức năng đang phát triển', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showCreateGameDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Tạo trò chơi mới',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            const Text('Chọn loại game:',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.2,
              children: [
                '🎣 Câu Cá', '⛏️ Đào Vàng', '🏎️ Đua Xe',
                '🗺️ Kho Báu', '🧩 Ghép Tranh', '⚔️ Đấu Trường',
              ].map((g) => GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.go('/game/lobby/new');
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(g, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _GameTag extends StatelessWidget {
  final String label;
  final IconData icon;

  const _GameTag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
