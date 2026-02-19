import 'package:blink_flutter/core/services/hive/hive_service.dart';
import 'package:blink_flutter/core/services/storage/user-session_service.dart';
import 'package:blink_flutter/features/auth/presentation/pages/profile_fullname_page.dart';
import 'package:blink_flutter/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the Hive Service;
  await HiveService().init();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );

  // // Dio instance
  // final dio = Dio();

  // // Remote data source
  // final authRemoteDataSource = AuthRemoteDataSource(dio);

  // // ✅ CORRECT repository
  // final authRepository = AuthRemoteRepository(authRemoteDataSource);

  // // Use cases
  // final loginUseCase = LoginUseCase(authRepository);
  // final signupUseCase = SignupUser(authRepository);

  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(
  //         create: (_) => AuthProvider(
  //           signupUser: signupUseCase,
  //           loginUseCase: loginUseCase,
  //         ),
  //       ),
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blink App',
      home: ProfileFullNamePage(),
    );
  }
}
