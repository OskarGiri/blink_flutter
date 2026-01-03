import 'package:blink_flutter/features/auth/presentation/pages/dashboard_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/signup_page.dart';
import 'package:blink_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Controllers for input fields
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // Access AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Set responsive width
    final contentWidth = screenWidth > 600 ? 450.0 : screenWidth * 0.9;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: contentWidth,
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    "WELCOME BACK\nTO\nBlink",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth > 600 ? 36 : 30,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffB43AE6),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Email label + field
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Your Email",
                      style: TextStyle(color: Color(0xffB43AE6)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 48,
                    child: TextField(
                      controller: emailController,
                      decoration: BoxDecorationInput(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Password label + field
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(color: Color(0xffB43AE6)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 48,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: BoxDecorationInput(),
                    ),
                  ),

                  // Forget Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forget Password?",
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // Use AuthProvider for Clean Architecture login
                        final success = await authProvider.login(
                          emailController.text,
                          passwordController.text,
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login Successful')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid Email/Password')),
                          );
                        }
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 22 : 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Divider with text
                  Row(
                    children: const [
                      Expanded(child: Divider(thickness: 0.8)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text("instant login"),
                      ),
                      Expanded(child: Divider(thickness: 0.8)),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.g_mobiledata, size: 30),
                        label: const Text("Google"),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.facebook, color: Colors.blue),
                        label: const Text("Facebook"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don’t have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign up",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper function to keep consistent decoration for TextFields
InputDecoration BoxDecorationInput() {
  return InputDecoration(
    fillColor: Colors.grey.shade300,
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide.none,
    ),
  );
}
