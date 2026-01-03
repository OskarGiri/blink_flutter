import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
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
