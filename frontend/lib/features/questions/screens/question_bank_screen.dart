import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  String _filterType = 'all';
  String _filterDifficulty = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ngân hàng câu hỏi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => context.go('/teacher/import'),
            tooltip: 'Import Excel',
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddQuestionDialog(context),
            tooltip: 'Thêm câu hỏi',
          ),
        ],
      ),
      body: Column(
        children: [
          // Bank selector
          _buildBankSelector(),
          // Filters
          _buildFilters(),
          // Stats
          _buildQuestionStats(),
          // Questions list
          Expanded(child: _buildQuestionsList()),
        ],
      ),
    );
  }

  Widget _buildBankSelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _BankCard(name: 'Toán lớp 6', count: 342, isSelected: true, onTap: () {}),
          const SizedBox(width: 10),
          _BankCard(name: 'Tin học 7', count: 128, isSelected: false, onTap: () {}),
          const SizedBox(width: 10),
          _BankCard(name: 'Lịch sử 8', count: 95, isSelected: false, onTap: () {}),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppTheme.primaryColor),
                  Text('Tạo mới', style: TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Type filter
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'Tất cả', value: 'all', selected: _filterType, onTap: (v) => setState(() => _filterType = v)),
                  const SizedBox(width: 6),
                  _FilterChip(label: 'Trắc nghiệm', value: 'mc', selected: _filterType, onTap: (v) => setState(() => _filterType = v)),
                  const SizedBox(width: 6),
                  _FilterChip(label: 'Đúng/Sai', value: 'tf', selected: _filterType, onTap: (v) => setState(() => _filterType = v)),
                  const SizedBox(width: 6),
                  _FilterChip(label: 'Tự luận', value: 'num', selected: _filterType, onTap: (v) => setState(() => _filterType = v)),
                  const SizedBox(width: 6),
                  _FilterChip(label: 'Dễ', value: 'easy', selected: _filterDifficulty, onTap: (v) => setState(() => _filterDifficulty = v), color: AppTheme.accentColor),
                  const SizedBox(width: 6),
                  _FilterChip(label: 'TB', value: 'medium', selected: _filterDifficulty, onTap: (v) => setState(() => _filterDifficulty = v), color: AppTheme.warningColor),
                  const SizedBox(width: 6),
                  _FilterChip(label: 'Khó', value: 'hard', selected: _filterDifficulty, onTap: (v) => setState(() => _filterDifficulty = v), color: AppTheme.errorColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickCount(label: 'Tổng', value: '342', color: AppTheme.primaryColor),
          _QuickCount(label: 'Dễ', value: '140', color: AppTheme.accentColor),
          _QuickCount(label: 'TB', value: '120', color: AppTheme.warningColor),
          _QuickCount(label: 'Khó', value: '82', color: AppTheme.errorColor),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    final questions = List.generate(20, (i) => {
      'content': i % 3 == 0
          ? 'Tìm x biết: 3x + 5 = 20'
          : i % 3 == 1
              ? 'Số nguyên tố là gì?'
              : '1/2 + 1/3 bằng bao nhiêu?',
      'type': i % 3 == 0 ? 'numeric' : i % 3 == 1 ? 'true_false' : 'multiple_choice',
      'difficulty': i % 3 == 0 ? 'easy' : i % 3 == 1 ? 'medium' : 'hard',
      'accuracy': 75 + (i * 3 % 25),
      'attempts': 150 + i * 10,
      'topic': 'Đại số',
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: questions.length,
      itemBuilder: (_, i) {
        final q = questions[i];
        final type = q['type'] as String;
        final difficulty = q['difficulty'] as String;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type == 'multiple_choice' ? 'Trắc nghiệm'
                          : type == 'true_false' ? 'Đúng/Sai'
                          : 'Tự luận',
                      style: const TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Difficulty badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.difficultyColor(difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppTheme.difficultyLabel(difficulty),
                      style: TextStyle(color: AppTheme.difficultyColor(difficulty), fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  Text('${q['accuracy']}% đúng', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(width: 8),
                  PopupMenuButton(
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                      const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                      const PopupMenuItem(value: 'similar', child: Text('Tạo câu tương tự (AI)')),
                    ],
                    onSelected: (v) {},
                    child: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                q['content'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.topic_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(q['topic'] as String, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(width: 12),
                  const Icon(Icons.quiz_outlined, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${q['attempts']} lần làm', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
        ).animate(delay: (i * 40).ms).fadeIn();
      },
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm câu hỏi mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.radio_button_checked, color: AppTheme.primaryColor),
              title: const Text('Trắc nghiệm 4 đáp án'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.check_box, color: AppTheme.accentColor),
              title: const Text('Đúng / Sai'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.orange),
              title: const Text('Điền số'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class _BankCard extends StatelessWidget {
  final String name;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _BankCard({required this.name, required this.count, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? null : Border.all(color: const Color(0xFFE0E0FF)),
          boxShadow: [
            if (isSelected) BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 2,
            ),
            Text(
              '$count câu',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final void Function(String) onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    final c = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? c : c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : c,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _QuickCount extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickCount({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
