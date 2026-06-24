import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 30)],
                ),
                child: const Center(
                  child: Text('🎓', style: TextStyle(fontSize: 64)),
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 1, end: 1.05, duration: 1500.ms),

              const SizedBox(height: 24),
              const Text(
                'GameLearn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3),
              const Text(
                'Học vui - Chơi giỏi',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ).animate(delay: 500.ms).fadeIn(),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ).animate(delay: 700.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}
