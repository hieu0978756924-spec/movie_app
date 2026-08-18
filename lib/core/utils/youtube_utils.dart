class YoutubeUtils {
  YoutubeUtils._();

  /// Extracts YouTube 11-character video ID from a URL or raw key string.
  static String extractYoutubeKey(String? input) {
    if (input == null) return '';
    final clean = input.trim();
    if (clean.isEmpty) return '';

    if (clean.contains('v=')) {
      return clean.split('v=').last.split('&').first.split('?').first;
    }
    if (clean.contains('youtu.be/')) {
      return clean.split('youtu.be/').last.split('&').first.split('?').first;
    }
    if (clean.contains('embed/')) {
      return clean.split('embed/').last.split('&').first.split('?').first;
    }
    if (!clean.contains('/') && !clean.contains('.') && clean.length >= 8) {
      return clean;
    }
    return '';
  }

  /// Maps internal local movie IDs (1-10) to their exact TMDB API IDs.
  static int getRealTmdbId(int movieId) {
    switch (movieId) {
      case 1:
        return 693134; // Dune: Part Two
      case 2:
        return 872585; // Oppenheimer
      case 3:
        return 533535; // Deadpool & Wolverine
      case 4:
        return 76600; // Avatar: The Way of Water
      case 5:
        return 299534; // Avengers: Endgame
      case 6:
        return 157336; // Interstellar
      case 7:
        return 1011985; // Kung Fu Panda 4
      case 8:
        return 1022789; // Inside Out 2
      case 9:
        return 558449; // Gladiator II
      case 10:
        return 786892; // Furiosa: A Mad Max Saga
      default:
        return movieId;
    }
  }

  /// Maps specific movie IDs (local 1-10 or TMDB IDs) to their exact official trailer YouTube keys.
  static String getFallbackTrailerKeyForMovieId(int movieId) {
    switch (movieId) {
      case 1:
      case 693134:
        return 'Way9Dexny3w'; // Dune: Part Two
      case 2:
      case 872585:
        return 'uYPbbksJxIg'; // Oppenheimer
      case 3:
      case 533535:
        return '73_1biulkYk'; // Deadpool & Wolverine
      case 4:
      case 76600:
        return 'd9MyW72ELq0'; // Avatar: The Way of Water
      case 5:
      case 299534:
        return 'TcMBFSGVi1c'; // Avengers: Endgame
      case 6:
      case 157336:
        return 'zSWdZVtXT7E'; // Interstellar
      case 7:
      case 1011985:
        return '_inKs4eeHiI'; // Kung Fu Panda 4
      case 8:
      case 1022789:
        return 'LEjhY15eCx0'; // Inside Out 2
      case 9:
      case 558449:
        return '4mgUU-f4n_w'; // Gladiator II
      case 10:
      case 786892:
        return 'XJMuhwVwcaU'; // Furiosa
      case 634649:
        return 'JfVOs4VSpmA'; // Spider-Man: No Way Home
      case 475557:
        return 'zAGVQLHvwOY'; // Joker
      case 414906:
        return 'mqqft2x_Aa4'; // The Batman
      case 361743:
        return 'qSqVVswa420'; // Top Gun Maverick
      case 572802:
        return 'UGc5Tzaiac0'; // Aquaman 2
      case 575264:
        return '2m1drlOZSDw'; // Mission Impossible 7
      case 385687:
        return 'eoOaKN4qCKw'; // Fast X
      case 698687:
        return 'u2NuUW3W1e0'; // Transformers One
      case 823464:
        return 'lV1OOlGwExM'; // Godzilla x Kong
      case 569094:
        return 'cqGjhVJWtEg'; // Spider-Man Spider-Verse
      case 27205:
        return 'YoHD9XEInc0'; // Inception
      default:
        return '';
    }
  }
}
