import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/core/theme/app_theme.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/dashboard_shell.dart';
import 'package:blink_flutter/features/auth/presentation/pages/forgot_password_email_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_fullname_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/signup_page.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:blink_flutter/features/auth/presentation/view_moodel/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _routing = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    await ref
        .read(authViewModelProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  bool _isProfileComplete(ProfileHiveModel? p) {
    final fullName = (p?.fullName ?? '').trim();
    final dob = (p?.dob ?? '').trim();
    final gender = (p?.gender ?? '').trim();
    final lookingFor = (p?.lookingFor ?? '').trim();
    final photos = p?.photos ?? const <String>[];

    return fullName.isNotEmpty &&
        dob.isNotEmpty &&
        gender.isNotEmpty &&
        lookingFor.isNotEmpty &&
        photos.isNotEmpty;
  }

  Future<void> _routeAfterLogin() async {
    if (_routing) return;
    _routing = true;

    final session = ref.read(userSessionServiceProvider);
    final hive = ref.read(hiveServiceProvider);

    final userId = session.getCurrentUserId() ?? 'guest';
    final profile = await hive.getProfileByUserId(userId);
    final complete = _isProfileComplete(profile);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            complete ? const DashboardShell() : const ProfileFullNamePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        _showSnack(context, next.message ?? 'Login failed. An error occurred');
      } else if (previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        _showSnack(context, 'Login successful.');
        Future.microtask(_routeAfterLogin);
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.98),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Form(
                key: _loginFormKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/icon/icon.png',
                        width: 34,
                        height: 34,
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Text(
                      'Sign in to continue to\nyour account',
                      style: TextStyle(
                        fontSize: 44,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter your email & password to continue',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(hint: 'Email'),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return 'Email is required';
                        if (!text.contains('@') || !text.contains('.')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _fieldDecoration(
                        hint: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.primaryPurple,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return 'Password is required';
                        if (text.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordEmailPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authState.status == AuthStatus.loading
                            ? null
                            : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppTheme.primaryPurple
                              .withOpacity(0.5),
                          disabledForegroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: authState.status == AuthStatus.loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 20,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                        ),
                        child: const Text(
                          "Don't have an account?",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppTheme.darkGrey,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppTheme.lightGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.error),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
