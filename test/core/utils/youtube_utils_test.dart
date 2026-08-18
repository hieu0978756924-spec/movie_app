import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/utils/youtube_utils.dart';

void main() {
  group('YoutubeUtils', () {
    test('extractYoutubeKey correctly extracts key from standard YouTube URLs', () {
      expect(
        YoutubeUtils.extractYoutubeKey('https://www.youtube.com/watch?v=uYPbbksJxIg'),
        'uYPbbksJxIg',
      );
      expect(
        YoutubeUtils.extractYoutubeKey('https://www.youtube.com/watch?v=73_1biulkYk&feature=shared'),
        '73_1biulkYk',
      );
      expect(
        YoutubeUtils.extractYoutubeKey('https://youtu.be/d9MyW72ELq0?t=10'),
        'd9MyW72ELq0',
      );
      expect(
        YoutubeUtils.extractYoutubeKey('https://www.youtube.com/embed/TcMBFSGVi1c'),
        'TcMBFSGVi1c',
      );
    });

    test('extractYoutubeKey returns raw key if passed directly', () {
      expect(YoutubeUtils.extractYoutubeKey('Way9Dexny3w'), 'Way9Dexny3w');
    });

    test('extractYoutubeKey returns empty string for empty input', () {
      expect(YoutubeUtils.extractYoutubeKey(''), '');
      expect(YoutubeUtils.extractYoutubeKey(null), '');
    });

    test('getFallbackTrailerKeyForMovieId returns correct trailer key for local/TMDB movies', () {
      expect(YoutubeUtils.getFallbackTrailerKeyForMovieId(1), 'Way9Dexny3w'); // Dune 2
      expect(YoutubeUtils.getFallbackTrailerKeyForMovieId(2), 'uYPbbksJxIg'); // Oppenheimer
      expect(YoutubeUtils.getFallbackTrailerKeyForMovieId(3), '73_1biulkYk'); // Deadpool
      expect(YoutubeUtils.getFallbackTrailerKeyForMovieId(4), 'd9MyW72ELq0'); // Avatar 2
      expect(YoutubeUtils.getFallbackTrailerKeyForMovieId(872585), 'uYPbbksJxIg'); // Oppenheimer TMDB
    });

    test('getFallbackTrailerKeyForMovieId returns empty string for unknown movie ID', () {
      expect(YoutubeUtils.getFallbackTrailerKeyForMovieId(99999999), '');
    });
  });
}
