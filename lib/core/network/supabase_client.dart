import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class SupabaseModule {
  @singleton
  SupabaseClient get supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return SupabaseClient(
        'https://placeholder.supabase.co',
        'placeholder-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
    }
  }
}
