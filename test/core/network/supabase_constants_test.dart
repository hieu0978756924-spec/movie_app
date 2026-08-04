import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/constants/supabase_constants.dart';

void main() {
  group('SupabaseConstants', () {
    test('should define table names correctly', () {
      expect(SupabaseConstants.profilesTable, 'profiles');
      expect(SupabaseConstants.watchlistTable, 'watchlist');
      expect(SupabaseConstants.reviewsTable, 'reviews');
    });

    test('should load URL and AnonKey from environment', () {
      expect(SupabaseConstants.supabaseUrl, isA<String>());
      expect(SupabaseConstants.supabaseAnonKey, isA<String>());
    });
  });
}
