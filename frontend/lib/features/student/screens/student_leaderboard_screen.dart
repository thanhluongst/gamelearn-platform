import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class StudentLeaderboardScreen extends StatefulWidget {
  const StudentLeaderboardScreen({super.key});

  @override
  State<StudentLeaderboardScreen> createState() => _StudentLeaderboardScreenState();
}

class _StudentLeaderboardScreenState extends State<StudentLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _scope = 'class'; // class, school, global
  String _period = 'weekly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                ),
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 48)),
                      Text(
                        'Bảng Xếp Hạng',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: false,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: 'Lớp'),
                Tab(text: 'Khối'),
                Tab(text: 'Trường'),
                Tab(text: 'Toàn Hệ Thống'),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            // Period filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  const Text('Thời gian:', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  ...[
                    ('Hôm nay', 'daily'),
                    ('Tuần', 'weekly'),
                    ('Tháng', 'monthly'),
                  ].map((p) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.$1),
                      selected: _period == p.$2,
                      onSelected: (_) => setState(() => _period = p.$2),
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: _period == p.$2 ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(4, (i) => _buildLeaderboard(i)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(int tabIndex) {
    // Mock data
    final players = List.generate(20, (i) => {
      'rank': i + 1,
      'name': 'Học sinh ${i + 1}',
      'score': 5000 - i * 150,
      'xp': 2500 - i * 80,
      'avatar': null,
      'isMe': i == 2, // Rank 3 is current user
    });

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Top 3 podium
        SliverToBoxAdapter(
          child: _buildPodium(players.take(3).toList()),
        ),

        // Rest of rankings
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final player = players[i + 3];
                return _buildRankItem(player, i + 3)
                    .animate(delay: (i * 40).ms)
                    .fadeIn()
                    .slideX(begin: 0.1);
              },
              childCount: players.length - 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> top3) {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2
          _PodiumItem(
            player: top3[1],
            height: 120,
            color: const Color(0xFFC0C0C0),
            rank: 2,
          ).animate(delay: 200.ms).slideY(begin: 0.5),
          const SizedBox(width: 8),
          // Rank 1
          _PodiumItem(
            player: top3[0],
            height: 160,
            color: const Color(0xFFFFD700),
            rank: 1,
          ).animate(delay: 100.ms).slideY(begin: 0.5),
          const SizedBox(width: 8),
          // Rank 3
          _PodiumItem(
            player: top3[2],
            height: 90,
            color: const Color(0xFFCD7F32),
            rank: 3,
          ).animate(delay: 300.ms).slideY(begin: 0.5),
        ],
      ),
    );
  }

  Widget _buildRankItem(Map<String, dynamic> player, int index) {
    final isMe = player['isMe'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 32,
            child: Text(
              '#${player['rank']}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isMe ? AppTheme.primaryColor : Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: isMe
                ? AppTheme.primaryColor.withOpacity(0.2)
                : Colors.grey.shade200,
            child: Text(
              (player['name'] as String)[0],
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isMe ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isMe ? AppTheme.primaryColor : Colors.black87,
                  ),
                ),
                Text(
                  '${player['xp']} XP',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '${player['score']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isMe ? AppTheme.primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final Map<String, dynamic> player;
  final double height;
  final Color color;
  final int rank;

  const _PodiumItem({
    required this.player,
    required this.height,
    required this.color,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown for rank 1
          if (rank == 1) const Text('👑', style: TextStyle(fontSize: 24)),
          // Avatar
          CircleAvatar(
            radius: rank == 1 ? 32 : 26,
            backgroundColor: color.withOpacity(0.2),
            child: Text(
              (player['name'] as String)[0],
              style: TextStyle(
                fontSize: rank == 1 ? 24 : 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            player['name'] as String,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${player['score']}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(height: 4),
          // Podium block
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
