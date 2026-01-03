import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter()); //  THIS LINE

  await Hive.openBox<UserModel>('users'); //OPEN BOx
  await testHive();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blink App',
      home: const Scaffold(
        body: Center(
          child: Text(
            'App Started Successfully',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

Future<void> testHive() async {
  final box = Hive.box<UserModel>('users');

  // Signup (save user)
  final user = UserModel(email: 'test@gmail.com', password: '123456');

  await box.put(user.email, user);

  // Login (read user)
  final savedUser = box.get('test@gmail.com');

  if (savedUser != null) {
    debugPrint('LOGIN SUCCESS: ${savedUser.email}');
  } else {
    debugPrint('LOGIN FAILED');
  }
}
