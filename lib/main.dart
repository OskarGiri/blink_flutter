import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'features/auth/data/datasources/remote_data_source/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_remote_repository.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/signup_user.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/splash_page.dart';

void main() {
  // Dio instance
  final dio = Dio();

  // Remote data source
  final authRemoteDataSource = AuthRemoteDataSource(dio);

  // ✅ CORRECT repository
  final authRepository = AuthRemoteRepository(authRemoteDataSource);

  // Use cases
  final loginUseCase = LoginUseCase(authRepository);
  final signupUseCase = SignupUser(authRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            signupUser: signupUseCase,
            loginUseCase: loginUseCase,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blink App',
      home: SplashScreen(),
    );
  }
}
