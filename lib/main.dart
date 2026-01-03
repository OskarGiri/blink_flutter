import 'package:blink_flutter/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:blink_flutter/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:blink_flutter/features/auth/domain/usecases/login_user.dart';
import 'package:blink_flutter/features/auth/domain/usecases/signup_user.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/data/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  final box = await Hive.openBox<UserModel>('users');

  final authLocalDataSource = AuthLocalDataSource(box);
  final authRepository = AuthRepositoryImpl(authLocalDataSource);
  final signupUseCase = SignupUser(authRepository);
  final loginUseCase = LoginUser(authRepository);

  runApp(MyApp(signupUseCase: signupUseCase, loginUseCase: loginUseCase));
}

class MyApp extends StatelessWidget {
  final SignupUser signupUseCase;
  final LoginUser loginUseCase;

  const MyApp({
    super.key,
    required this.signupUseCase,
    required this.loginUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blink App',
      home: Scaffold(
        body: Center(child: Text('Clean Architecture + Hive Ready')),
      ),
    );
  }
}
