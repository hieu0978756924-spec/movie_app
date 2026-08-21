abstract class SupabaseConstants {
  static const String _envUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _envKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const String defaultUrl = 'https://njjzlgymaugsjhstjyxo.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5qanpsZ3ltYXVnc2poc3RqeXhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU4Mjg3NjgsImV4cCI6MjEwMTQwNDc2OH0.BWLQ9UxLZj3JgHAxU_tOFwqWsiwM1XfU5Z2AaK0Y8zM';

  static String get supabaseUrl => _envUrl.isNotEmpty ? _envUrl : defaultUrl;
  static String get supabaseAnonKey =>
      _envKey.isNotEmpty ? _envKey : defaultAnonKey;

  static const String profilesTable = 'profiles';
  static const String watchlistTable = 'watchlist';
  static const String reviewsTable = 'reviews';
}
