import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/utils/image_url_helper.dart';

void main() {
  group('ImageUrlHelper', () {
    test('should return null or empty string when path is null or empty', () {
      expect(ImageUrlHelper.getPosterUrl(null), null);
      expect(ImageUrlHelper.getPosterUrl(''), null);
      expect(ImageUrlHelper.getBackdropUrl(null), null);
      expect(ImageUrlHelper.getBackdropUrl(''), null);
    });

    test('should construct full poster URL with default size w500', () {
      const path = '/poster.jpg';
      final result = ImageUrlHelper.getPosterUrl(path);
      expect(result, 'https://image.tmdb.org/t/p/w500/poster.jpg');
    });

    test('should construct full backdrop URL with default size w780', () {
      const path = '/backdrop.jpg';
      final result = ImageUrlHelper.getBackdropUrl(path);
      expect(result, 'https://image.tmdb.org/t/p/w780/backdrop.jpg');
    });

    test('should construct full profile URL with default size w185', () {
      const path = '/profile.jpg';
      final result = ImageUrlHelper.getProfileUrl(path);
      expect(result, 'https://image.tmdb.org/t/p/w185/profile.jpg');
    });

    test('should support custom quality sizes', () {
      const path = '/poster.jpg';
      final result = ImageUrlHelper.getPosterUrl(path, size: 'original');
      expect(result, 'https://image.tmdb.org/t/p/original/poster.jpg');
    });
  });
}
