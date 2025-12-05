import 'package:blink_flutter/screens/dashboard.dart';
import 'package:blink_flutter/screens/sign_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Set responsive width (max width for tablet center alignment)
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
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
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
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
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
                      onPressed: () {
                        // Navigate to Dashboard on login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
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
