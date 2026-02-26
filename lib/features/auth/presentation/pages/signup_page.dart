import 'package:blink_flutter/core/theme/app_theme.dart';
import 'package:blink_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:blink_flutter/features/auth/presentation/view_moodel/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_page.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _signUpFormKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    await ref
        .read(authViewModelProvider.notifier)
        .signUp(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        _showSnack(
          context,
          next.message ?? 'Sign Up failed. An error occurred',
        );
      } else if (next.status == AuthStatus.created) {
        _showSnack(context, 'Signup successful. Please login.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
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
                key: _signUpFormKey,
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
                      'Create your\naccount',
                      style: TextStyle(
                        fontSize: 44,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Enter your details to continue',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: _fieldDecoration(hint: 'Username'),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty) return 'Username is required';
                        if (text.length < 3) return 'At least 3 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authState.status == AuthStatus.loading
                            ? null
                            : _handleSignup,
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
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryPurple,
                        ),
                        child: const Text(
                          'Already have an account?',
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
