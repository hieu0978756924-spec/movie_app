abstract class ApiConstants {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/';
  static const String tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');

  static const String defaultLanguage = 'vi-VN';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
