import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/home/data/models/movie_model.dart';
import 'package:movie_app/features/home/data/models/movie_response_model.dart';

void main() {
  group('MovieModel & MovieResponseModel Tests', () {
    final tJson = {
      'id': 550,
      'title': 'Fight Club',
      'poster_path': '/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'backdrop_path': '/hZkgoQY85KGDiEac58Ww8jxcZsu.jpg',
      'vote_average': 8.4,
      'release_date': '1999-10-15',
      'overview': 'An insomniac office worker...',
      'genre_ids': [18, 53],
      'vote_count': 25000,
    };

    test('should parse JSON correctly into MovieModel', () {
      final model = MovieModel.fromJson(tJson);

      expect(model.id, equals(550));
      expect(model.title, equals('Fight Club'));
      expect(model.posterPath, equals('/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
      expect(model.voteAverage, equals(8.4));
      expect(model.releaseDate, equals('1999-10-15'));
      expect(model.genreIds, equals([18, 53]));
    });

    test('should convert MovieModel to Movie domain entity', () {
      final model = MovieModel.fromJson(tJson);
      final entity = model.toEntity();

      expect(entity.id, equals(550));
      expect(entity.tenPhim, equals('Fight Club'));
      expect(entity.hinhAnh, equals('/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg'));
      expect(entity.diemDanhGia, equals(8.4));
      expect(entity.namPhatHanh, equals(1999));
    });

    test('should parse MovieResponseModel correctly', () {
      final responseJson = {
        'page': 1,
        'results': [tJson],
        'total_pages': 100,
        'total_results': 2000,
      };

      final responseModel = MovieResponseModel.fromJson(responseJson);

      expect(responseModel.page, equals(1));
      expect(responseModel.results.length, equals(1));
      expect(responseModel.results.first.title, equals('Fight Club'));
      expect(responseModel.totalPages, equals(100));
      expect(responseModel.totalResults, equals(2000));
    });
  });
}
