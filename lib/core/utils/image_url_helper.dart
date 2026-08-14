import '../constants/api_constants.dart';

abstract class ImageUrlHelper {
  static const List<String> localFallbackPosters = [
    'assets/images/dune2.jpg',
    'assets/images/oppenheimer.jpg',
    'assets/images/deadpool.jpg',
    'assets/images/spiderman.jpg',
    'assets/images/joker.jpg',
    'assets/images/endgame.jpg',
    'assets/images/panda4.jpg',
    'assets/images/banner.jpg',
    'assets/images/gladiator2.jpg',
    'assets/images/furiosa.jpg',
    'assets/images/aquaman2.jpg',
    'assets/images/avatar_movie.jpg',
    'assets/images/insideout2.jpg',
    'assets/images/batman.jpg',
    'assets/images/interstellar.jpg',
  ];

  static final Map<int, String> _idToLocalPoster = {
    693134: 'assets/images/dune2.jpg',
    872585: 'assets/images/oppenheimer.jpg',
    533535: 'assets/images/deadpool.jpg',
    299534: 'assets/images/endgame.jpg',
    634649: 'assets/images/spiderman.jpg',
    76600: 'assets/images/avatar_movie.jpg',
    475557: 'assets/images/joker.jpg',
    1011985: 'assets/images/panda4.jpg',
    1022789: 'assets/images/insideout2.jpg',
    414906: 'assets/images/batman.jpg',
    361743: 'assets/images/banner.jpg',
    157336: 'assets/images/interstellar.jpg',
    558449: 'assets/images/gladiator2.jpg',
    786892: 'assets/images/furiosa.jpg',
    572802: 'assets/images/aquaman2.jpg',
    575264: 'assets/images/mission_impossible.jpg',
    385687: 'assets/images/fastx.jpg',
    698687: 'assets/images/transformers.jpg',
  };

  static String getLocalFallbackImage([int? id]) {
    if (id != null && _idToLocalPoster.containsKey(id)) {
      return _idToLocalPoster[id]!;
    }
    if (id == null || id == 0) return localFallbackPosters[0];
    return localFallbackPosters[id.abs() % localFallbackPosters.length];
  }

  static String? getPosterUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('assets/')) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ApiConstants.tmdbImageBaseUrl}$size$cleanPath';
  }

  static String? getBackdropUrl(String? path, {String size = 'w780'}) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('assets/')) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ApiConstants.tmdbImageBaseUrl}$size$cleanPath';
  }

  static String? getProfileUrl(String? path, {String size = 'w185'}) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('assets/')) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '${ApiConstants.tmdbImageBaseUrl}$size$cleanPath';
  }

  static final Map<String, String> _directorAvatars = {
    'denis villeneuve': 'https://image.tmdb.org/t/p/w185/v301jJ51F5F7a1i94f83.jpg',
    'christopher nolan': 'https://image.tmdb.org/t/p/w185/xuAIuF31nFWi4TBD3DqYnmUjVzB.jpg',
    'shawn levy': 'https://image.tmdb.org/t/p/w185/j3b0iS6WvWk4R4H.jpg',
    'anthony russo': 'https://image.tmdb.org/t/p/w185/no1G9gMUp1e6n95v31.jpg',
    'jon watts': 'https://image.tmdb.org/t/p/w185/1p8p0i3j1f.jpg',
    'james cameron': 'https://image.tmdb.org/t/p/w185/9naYi2jR9N2j6e10.jpg',
    'todd phillips': 'https://image.tmdb.org/t/p/w185/hA6pM387N5rM3.jpg',
    'matt reeves': 'https://image.tmdb.org/t/p/w185/x7r1fF9N37F02.jpg',
  };

  static String? getDirectorAvatar(String? directorName) {
    if (directorName == null || directorName.trim().isEmpty) return null;
    final nameClean = directorName.trim().toLowerCase();
    for (final entry in _directorAvatars.entries) {
      if (nameClean.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }
}

