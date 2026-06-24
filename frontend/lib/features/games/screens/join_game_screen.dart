import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => context.go('/student'),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Game illustration
                      const Text('🎮', style: TextStyle(fontSize: 80))
                          .animate()
                          .scale(duration: 600.ms, curve: Curves.elasticOut)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: -10, duration: 2000.ms),

                      const SizedBox(height: 16),

                      const Text(
                        'Tham gia Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),

                      const SizedBox(height: 8),
                      const Text(
                        'Nhập mã phòng từ giáo viên để tham gia',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ).animate(delay: 300.ms).fadeIn(),

                      const SizedBox(height: 48),

                      // Code input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8,
                              ),
                              maxLength: 6,
                              decoration: InputDecoration(
                                hintText: 'ABC123',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 32,
                                  letterSpacing: 8,
                                ),
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF5F5FF),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isJoining ? null : _joinGame,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: _isJoining
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Text(
                                        'Tham gia ngay!',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 400.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),

                      const SizedBox(height: 32),

                      // Game types preview
                      const Text(
                        'Các trò chơi có sẵn',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          '🎣 Câu Cá',
                          '⛏️ Đào Vàng',
                          '🏎️ Đua Xe',
                          '🗺️ Kho Báu',
                          '🧩 Ghép Tranh',
                          '⚔️ Đấu Trường',
                        ].asMap().entries.map((e) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            e.value,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ).animate(delay: (e.key * 80 + 600).ms).fadeIn().scale()).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinGame() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã phòng phải có 6 ký tự'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isJoining = true);

    // API call to join
    await Future.delayed(const Duration(seconds: 1)); // Simulate

    if (!mounted) return;
    setState(() => _isJoining = false);
    context.go('/game/lobby/session-id-here');
  }
}
