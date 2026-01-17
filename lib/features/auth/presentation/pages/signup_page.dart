// import 'package:blink_flutter/features/auth/presentation/pages/login_page.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../providers/auth_provider.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final double inputWidth = size.width * 0.85;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: size.height * 0.05),

//               Text(
//                 "WELCOME\nTO\nBlink",
//                 style: TextStyle(
//                   fontSize: size.width * 0.085,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple.shade700,
//                 ),
//               ),

//               SizedBox(height: size.height * 0.06),

//               /// FULL NAME (UI only)
//               Text(
//                 "Full Name",
//                 style: TextStyle(color: Colors.purple.shade600),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: inputWidth,
//                 child: TextField(
//                   controller: nameController,
//                   decoration: _inputDecoration(),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// EMAIL
//               Text(
//                 "Your Email",
//                 style: TextStyle(color: Colors.purple.shade600),
//               ),
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: inputWidth,
//                 child: TextField(
//                   controller: emailController,
//                   decoration: _inputDecoration(),
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               /// PASSWORD
//               Text("Password", style: TextStyle(color: Colors.purple.shade600)),
//               const SizedBox(height: 8),
//               SizedBox(
//                 width: inputWidth,
//                 child: TextField(
//                   controller: passwordController,
//                   obscureText: true,
//                   decoration: _inputDecoration(),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               /// Helper text for ReqRes test credentials
//               Text(
//                 "Test signup (ReqRes):\nemail: eve.holt@reqres.in\npassword: pistol",
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade600,
//                   height: 1.3,
//                 ),
//               ),

//               const SizedBox(height: 18),

//               /// SIGN UP BUTTON
//               SizedBox(
//                 width: inputWidth,
//                 height: 48,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   onPressed: () async {
//                     final email = emailController.text.trim();
//                     final password = passwordController.text.trim();

//                     if (email.isEmpty || password.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Please fill email and password"),
//                         ),
//                       );
//                       return;
//                     }

//                     try {
//                       await context.read<AuthProvider>().signup(
//                         email,
//                         password,
//                       );

//                       if (!mounted) return;

//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Signup successful! Please login."),
//                         ),
//                       );

//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const LoginScreen()),
//                       );
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text(
//                             "Signup failed.\nUse ReqRes test:\nemail: eve.holt@reqres.in\npassword: pistol",
//                           ),
//                           duration: Duration(seconds: 4),
//                         ),
//                       );
//                     }
//                   },
//                   child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
//                 ),
//               ),

//               const SizedBox(height: 25),

//               /// LOGIN LINK
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already have an account? "),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const LoginScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         "Login",
//                         style: TextStyle(
//                           color: Colors.blueAccent,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: size.height * 0.05),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration() {
//     return InputDecoration(
//       filled: true,
//       fillColor: Colors.grey.shade200,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(6),
//         borderSide: BorderSide.none,
//       ),
//     );
//   }
// }
