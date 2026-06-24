import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String _selectedRole = 'student';
  bool _obscure = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.successGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Tạo tài khoản',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role selector
                          Row(
                            children: ['student', 'teacher'].map((role) => Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedRole = role),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: _selectedRole == role ? AppTheme.primaryGradient : null,
                                    color: _selectedRole != role ? const Color(0xFFF5F5FF) : null,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _selectedRole == role ? Colors.transparent : const Color(0xFFE0E0FF),
                                    ),
                                  ),
                                  child: Text(
                                    role == 'student' ? '👦 Học sinh' : '👩‍🏫 Giáo viên',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _selectedRole == role ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            )).toList(),
                          ).animate().fadeIn(delay: 100.ms),
                          const SizedBox(height: 20),

                          _buildField(_fullNameCtrl, 'Họ và tên', Icons.person, delay: 200),
                          const SizedBox(height: 14),
                          _buildField(_usernameCtrl, 'Tên đăng nhập', Icons.alternate_email, delay: 300),
                          const SizedBox(height: 14),
                          _buildField(_emailCtrl, 'Email', Icons.email_outlined, delay: 400,
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 14),
                          _buildField(_passwordCtrl, 'Mật khẩu', Icons.lock_outline, delay: 500,
                              obscure: _obscure, onToggle: () => setState(() => _obscure = !_obscure)),
                          const SizedBox(height: 14),
                          _buildField(_confirmCtrl, 'Xác nhận mật khẩu', Icons.lock_outline, delay: 600,
                              obscure: _obscure),
                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Tạo tài khoản', style: TextStyle(fontSize: 16)),
                          ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2),

                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Đã có tài khoản? '),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ).animate(delay: 800.ms).fadeIn(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int delay = 0,
    TextInputType? keyboardType,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: onToggle != null
            ? IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggle,
              )
            : null,
      ),
      validator: (v) => v?.isEmpty ?? true ? '$label không được để trống' : null,
    ).animate(delay: delay.ms).fadeIn().slideX(begin: -0.1);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(_selectedRole == 'teacher' ? '/teacher' : '/student');
  }
}
