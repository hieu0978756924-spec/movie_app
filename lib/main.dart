import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConstants.supabaseUrl.isNotEmpty &&
      SupabaseConstants.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      publishableKey: SupabaseConstants.supabaseAnonKey,
    );
  }

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