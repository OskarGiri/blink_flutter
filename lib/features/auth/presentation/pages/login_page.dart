// lib/features/auth/presentation/pages/login_page.dart
import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/data/models/profile_hive_model.dart';
import 'package:blink_flutter/features/auth/presentation/pages/dashboard_shell.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_fullname_page.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  bool _isProfileComplete(ProfileHiveModel? p) {
    final fullName = (p?.fullName ?? "").trim();
    final dob = (p?.dob ?? "").trim();
    final gender = (p?.gender ?? "").trim();
    final lookingFor = (p?.lookingFor ?? "").trim();
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

    final userId = session.getCurrentUserId() ?? "guest";
    final profile = await hive.getProfileByUserId(userId);
    final complete = _isProfileComplete(profile);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => complete ? const DashboardShell() : const ProfileFullNamePage(),
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

        // ✅ route based on profile completeness (instead of always ProfileFullNamePage)
        Future.microtask(_routeAfterLogin);
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 420.0 : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: contentWidth,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Form(
                key: _loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "WELCOME BACK",
                      style: TextStyle(
                        fontSize: screenWidth > 600 ? 34 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffB43AE6),
                      ),
                    ),
                    const SizedBox(height: 40),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Email", style: TextStyle(color: Color(0xffB43AE6))),
                    ),
                    const SizedBox(height: 6),
                    _inputField(_emailController, false),

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password", style: TextStyle(color: Color(0xffB43AE6))),
                    ),
                    const SizedBox(height: 6),
                    _inputField(_passwordController, true),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: authState.status == AuthStatus.loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Login",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, bool obscure) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}