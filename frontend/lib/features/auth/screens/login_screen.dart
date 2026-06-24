import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
              child: Column(
                children: [
                  // Logo/Brand section
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
                          ),
                          child: const Center(
                            child: Text('🎓', style: TextStyle(fontSize: 52)),
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                        const SizedBox(height: 16),
                        const Text(
                          'GameLearn',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3),
                        const Text(
                          'Học vui - Chơi giỏi',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ).animate(delay: 300.ms).fadeIn(),
                      ],
                    ),
                  ),

                  // Login form
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Đăng nhập',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.2),

                            const SizedBox(height: 24),

                            TextFormField(
                              controller: _identifierCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Email hoặc Tên đăng nhập',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên đăng nhập' : null,
                            ).animate(delay: 500.ms).fadeIn().slideX(begin: -0.1),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) => (v?.length ?? 0) < 6 ? 'Mật khẩu ít nhất 6 ký tự' : null,
                            ).animate(delay: 600.ms).fadeIn().slideX(begin: -0.1),

                            const SizedBox(height: 8),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Quên mật khẩu?'),
                              ),
                            ),

                            const SizedBox(height: 16),

                            ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                            ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Chưa có tài khoản? '),
                                TextButton(
                                  onPressed: () => context.go('/register'),
                                  child: const Text(
                                    'Đăng ký ngay',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ).animate(delay: 800.ms).fadeIn(),

                            // Quick demo access
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Demo nhanh:',
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      _DemoChip(label: 'Học sinh', onTap: () {
                                        _identifierCtrl.text = 'student01';
                                        _passwordCtrl.text = 'password';
                                      }),
                                      _DemoChip(label: 'Giáo viên', onTap: () {
                                        _identifierCtrl.text = 'teacher01';
                                        _passwordCtrl.text = 'password';
                                      }),
                                      _DemoChip(label: 'Admin', onTap: () {
                                        _identifierCtrl.text = 'admin';
                                        _passwordCtrl.text = 'password';
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ).animate(delay: 900.ms).fadeIn(),
                          ],
                        ),
                      ),
                    ).animate(delay: 300.ms).slideY(begin: 0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate based on role (demo)
    final identifier = _identifierCtrl.text;
    if (identifier.contains('teacher')) {
      context.go('/teacher');
    } else if (identifier.contains('admin')) {
      context.go('/admin');
    } else {
      context.go('/student');
    }
  }
}

class _DemoChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DemoChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
