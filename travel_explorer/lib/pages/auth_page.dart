import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    _animCtrl.reverse().then((_) {
      setState(() => _isLogin = !_isLogin);
      _animCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _isLogin
            ? _LoginView(onSignUp: _toggle)
            : _SignUpView(onLogin: _toggle),
      ),
    );
  }
}

// Login

class _LoginView extends StatefulWidget {
  final VoidCallback onSignUp;
  const _LoginView({required this.onSignUp});

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  static const _accent = Color(0xFF2E7D32);
  static const _dark = Color(0xFF1C1C2E);
  static const _mid = Color(0xFF6B7280);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _showForgotPassword(BuildContext context) async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    bool sending = false;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: _accent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Reset Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email and we\'ll send you a reset link.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'user@email.com',
                  hintStyle: const TextStyle(
                    color: Color(0xFFB0B7C3),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    color: _accent,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FF),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: _accent, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: sending
                        ? null
                        : () async {
                            if (emailCtrl.text.trim().isEmpty) return;
                            setInner(() => sending = true);
                            try {
                              await ctx
                                  .read<AppProvider>()
                                  .service
                                  .resetPassword(emailCtrl.text.trim());
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Reset link sent! Check your email.',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              setInner(() => sending = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(
                                  ctx,
                                ).showSnackBar(SnackBar(content: Text('$e')));
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: sending
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Send Link',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    emailCtrl.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AppProvider>().service.signIn(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (mounted) context.read<AppProvider>().notifyAuthChange();
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFB0B7C3), fontSize: 14),
    prefixIcon: Icon(icon, color: _accent, size: 20),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _accent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background blobs
        Positioned(
          top: -80,
          right: -80,
          child: _Blob(color: _accent.withValues(alpha: 0.18), size: 260),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: _Blob(
            color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
            size: 300,
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // App name
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [_accent, Color(0xFF66BB6A)],
                    ).createShader(bounds),
                    child: const Text(
                      'WANDR',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'WELCOME BACK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      color: _mid,
                    ),
                  ),
                  const SizedBox(height: 52),

                  // Email
                  _FieldLabel('EMAIL ADDRESS'),
                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(fontSize: 14, color: _dark),
                    decoration: _dec(
                      'user@email.com',
                      Icons.mail_outline_rounded,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 18),

                  // Password
                  _FieldLabel('PASSWORD'),
                  TextFormField(
                    controller: _passCtrl,
                    style: const TextStyle(fontSize: 14, color: _dark),
                    obscureText: _obscure,
                    decoration: _dec('••••••••', Icons.lock_outline_rounded)
                        .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _mid,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                    validator: (v) =>
                        v!.length >= 6 ? null : 'Min 6 characters',
                  ),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPassword(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 12,
                          color: _mid,
                          decoration: TextDecoration.underline,
                          decorationColor: _mid,
                        ),
                      ),
                    ),
                  ),

                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  // Login button
                  _GradientButton(
                    label: 'LOGIN',
                    loading: _loading,
                    onTap: _submit,
                  ),
                  const SizedBox(height: 40),

                  // Sign up link
                  GestureDetector(
                    onTap: widget.onSignUp,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: _mid),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: _accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//Sign Up

class _SignUpView extends StatefulWidget {
  final VoidCallback onLogin;
  const _SignUpView({required this.onLogin});

  @override
  State<_SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<_SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  static const _accent = Color(0xFF2E7D32);
  static const _dark = Color(0xFF1C1C2E);
  static const _mid = Color(0xFF6B7280);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AppProvider>().service.signUp(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        _nameCtrl.text.trim(),
      );
      if (mounted) context.read<AppProvider>().notifyAuthChange();
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String hint, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B7C3), fontSize: 14),
        prefixIcon: Icon(icon, color: _accent, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: _Blob(color: _accent.withValues(alpha: 0.18), size: 220),
        ),
        Positioned(
          bottom: -80,
          left: -80,
          child: _Blob(
            color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
            size: 260,
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Back
                  GestureDetector(
                    onTap: widget.onLogin,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: _mid,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(fontSize: 13, color: _mid),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title
                  const Text(
                    'Create\nAccount ✈️',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: _dark,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'START YOUR JOURNEY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.5,
                      color: _mid,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full name
                  _FieldLabel('FULL NAME'),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(fontSize: 14, color: _dark),
                    decoration: _dec(
                      'Your full name',
                      Icons.person_outline_rounded,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _FieldLabel('EMAIL ADDRESS'),
                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(fontSize: 14, color: _dark),
                    decoration: _dec(
                      'user@email.com',
                      Icons.mail_outline_rounded,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        v!.contains('@') ? null : 'Enter a valid email',
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _FieldLabel('PASSWORD'),
                  TextFormField(
                    controller: _passCtrl,
                    style: const TextStyle(fontSize: 14, color: _dark),
                    obscureText: _obscurePass,
                    decoration: _dec(
                      'Min. 8 characters',
                      Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _mid,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) =>
                        v!.length >= 6 ? null : 'Min 6 characters',
                  ),
                  const SizedBox(height: 16),

                  // Confirm password
                  _FieldLabel('CONFIRM PASSWORD'),
                  TextFormField(
                    controller: _confirmCtrl,
                    style: const TextStyle(fontSize: 14, color: _dark),
                    obscureText: _obscureConfirm,
                    decoration: _dec(
                      'Repeat password',
                      Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _mid,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) =>
                        v != _passCtrl.text ? 'Passwords do not match' : null,
                  ),
                  const SizedBox(height: 12),

                  // Terms
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, color: _mid),
                      children: [
                        const TextSpan(
                          text: 'By registering you agree to our ',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: _accent,
                          ),
                        ),
                        const TextSpan(text: ' & '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: _accent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Error
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  _GradientButton(
                    label: 'REGISTER',
                    loading: _loading,
                    onTap: _submit,
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: GestureDetector(
                      onTap: widget.onLogin,
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: _mid),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Login',
                              style: TextStyle(
                                color: _accent,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: _accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Shared

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
