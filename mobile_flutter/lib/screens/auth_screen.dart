import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/theme.dart';

// ── Login Screen ─────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login gagal'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, Color(0xFF1D4ED8), Color(0xFF1E3A5F)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, _, __) => const Icon(
                          Icons.menu_book_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Perpustakaan Digital',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('Masuk untuk mengelola perpustakaan',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                  const SizedBox(height: 40),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Masuk',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('Selamat datang kembali!',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(height: 24),

                        // Email
                        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'nama@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        const Text('Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Button
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) => ElevatedButton(
                            onPressed: auth.status == AuthStatus.loading ? null : _login,
                            child: auth.status == AuthStatus.loading
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('Masuk'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Belum punya akun?',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: const Text('Daftar',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Register Screen ──────────────────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _register() async {
    if (_passCtrl.text != _passConfCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password tidak cocok'),
        backgroundColor: AppTheme.danger,
      ));
      return;
    }
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
        _nameCtrl.text.trim(), _emailCtrl.text.trim(),
        _passCtrl.text, _passConfCtrl.text);
    setState(() => _loading = false);
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppTheme.success,
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(auth.error ?? 'Registrasi gagal'),
          backgroundColor: AppTheme.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, Color(0xFF1D4ED8), Color(0xFF1E3A5F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Icon(Icons.person_add_outlined, size: 56, color: Colors.white),
                const SizedBox(height: 16),
                const Text('Buat Akun Baru',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field('Nama Lengkap', _nameCtrl, Icons.person_outline_rounded, 'Nama kamu'),
                      const SizedBox(height: 14),
                      _field('Email', _emailCtrl, Icons.email_outlined, 'nama@email.com',
                          type: TextInputType.emailAddress),
                      const SizedBox(height: 14),
                      _field('Password', _passCtrl, Icons.lock_outline_rounded, '••••••••',
                          obscure: true),
                      const SizedBox(height: 14),
                      _field('Konfirmasi Password', _passConfCtrl,
                          Icons.lock_outline_rounded, '••••••••', obscure: true),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _register,
                        child: _loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Daftar Sekarang'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, String hint,
      {bool obscure = false, TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obscure ? _obscure : false,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: obscure
                ? IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
