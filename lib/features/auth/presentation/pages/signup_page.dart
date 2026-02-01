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
  final _signUpFromKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_signUpFromKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .signUp(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }

    // if (_isSubmitting) return;

    // final username = _usernameController.text.trim();
    // final email = _emailController.text.trim();
    // final password = _passwordController.text.trim();

    // if (username.isEmpty || email.isEmpty || password.isEmpty) {
    //   _showSnack(context, "Please fill all fields");
    //   return;
    // }

    // setState(() => _isSubmitting = true);

    // bool success;
    // try {
    //   success = await context.read<AuthProvider>().signup(
    //     username,
    //     email,
    //     password,
    //   );
    // } finally {
    //   if (mounted) {
    //     setState(() => _isSubmitting = false);
    //   }
    // }

    // if (!mounted) return;

    // if (success) {
    //   _showSnack(context, "Signup successful. Please login.");
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (_) => const LoginPage()),
    //   );
    // } else {
    //   _showSnack(context, "Signup failed. Please try again.");
    // }
  }

  @override
  Widget build(BuildContext context) {
    // Auth State
    final authState = ref.watch(authViewModelProvider);

    // listen for state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        _showSnack(
          context,
          next.message ?? 'Sign Up failed. An error occurred',
        );
      } else if (next.status == AuthStatus.created) {
        _showSnack(context, 'Signup successful. Please login.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });

    final size = MediaQuery.of(context).size;
    final inputWidth = size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _signUpFromKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.05),

                Text(
                  "WELCOME\nTO\nBlink",
                  style: TextStyle(
                    fontSize: size.width * 0.085,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),

                SizedBox(height: size.height * 0.06),

                /// USERNAME
                Text(
                  "Username",
                  style: TextStyle(color: Colors.purple.shade600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: inputWidth,
                  child: TextField(
                    controller: _usernameController,
                    decoration: _inputDecoration(),
                  ),
                ),

                const SizedBox(height: 20),

                /// EMAIL
                Text("Email", style: TextStyle(color: Colors.purple.shade600)),
                const SizedBox(height: 8),
                SizedBox(
                  width: inputWidth,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                Text(
                  "Password",
                  style: TextStyle(color: Colors.purple.shade600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: inputWidth,
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputDecoration(),
                  ),
                ),

                const SizedBox(height: 30),

                /// SIGN UP BUTTON
                SizedBox(
                  width: inputWidth,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _handleSignup,
                    child: authState.status == AuthStatus.loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up", style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 25),

                /// LOGIN LINK
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
