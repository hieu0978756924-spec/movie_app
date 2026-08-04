import 'package:flutter/material.dart';

import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Góc Phim',
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(
          child: Text('Góc Phim App Initialized'),
        ),
      ),
    );
  }
}