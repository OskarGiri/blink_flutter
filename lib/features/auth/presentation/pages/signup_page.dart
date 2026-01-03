import 'package:blink_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double inputWidth = size.width * 0.85;

    // Controllers for input fields
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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

              // Full Name
              Text(
                "Full Name",
                style: TextStyle(color: Colors.purple.shade600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: inputWidth,
                child: TextField(controller: nameController),
              ),
              const SizedBox(height: 20),

              // Email
              Text(
                "Your Email",
                style: TextStyle(color: Colors.purple.shade600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: inputWidth,
                child: TextField(controller: emailController),
              ),
              const SizedBox(height: 20),

              // Password
              Text("Password", style: TextStyle(color: Colors.purple.shade600)),
              const SizedBox(height: 8),
              SizedBox(
                width: inputWidth,
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                ),
              ),
              const SizedBox(height: 30),

              // Sign Up Button
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
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();

                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    await authProvider.signup(email, password);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Signup successful!")),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 25),
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
                            builder: (context) => const LoginScreen(),
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
    );
  }
}
