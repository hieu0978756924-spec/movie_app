import '../constants/api_constants.dart';

abstract class ImageUrlHelper {
  static String? getPosterUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.trim().isEmpty) return null;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ApiConstants.tmdbImageBaseUrl}$size$cleanPath';
  }

  static String? getBackdropUrl(String? path, {String size = 'w780'}) {
    if (path == null || path.trim().isEmpty) return null;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ApiConstants.tmdbImageBaseUrl}$size$cleanPath';
  }

  static String? getProfileUrl(String? path, {String size = 'w185'}) {
    if (path == null || path.trim().isEmpty) return null;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ApiConstants.tmdbImageBaseUrl}$size$cleanPath';
  }
}
