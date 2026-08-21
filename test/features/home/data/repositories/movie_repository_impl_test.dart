import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/data/datasources/movie_remote_datasource.dart';
import 'package:movie_app/features/home/data/models/movie_model.dart';
import 'package:movie_app/features/home/data/models/movie_response_model.dart';
import 'package:movie_app/features/home/data/repositories/movie_repository_impl.dart';

class MockMovieRemoteDataSource extends Mock implements MovieRemoteDataSource {}

void main() {
  late MockMovieRemoteDataSource mockRemoteDataSource;
  late MovieRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockMovieRemoteDataSource();
    repository = MovieRepositoryImpl(mockRemoteDataSource);
  });

  final tMovieModel = MovieModel(
    id: 100,
    title: 'Test Movie',
    posterPath: '/poster.jpg',
    backdropPath: '/backdrop.jpg',
    voteAverage: 8.0,
    releaseDate: '2026-05-10',
    overview: 'Overview test',
    genreIds: [12, 28],
    voteCount: 500,
  );

  final tResponseModel = MovieResponseModel(
    page: 1,
    results: [tMovieModel],
    totalPages: 5,
    totalResults: 100,
  );

  group('MovieRepositoryImpl Tests', () {
    test('getTrendingMovies returns Right(List<Movie>) on success', () async {
      when(() => mockRemoteDataSource.getTrendingMovies(page: 1))
          .thenAnswer((_) async => tResponseModel);

      final result = await repository.getTrendingMovies(page: 1);

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should be right'),
        (movies) {
          expect(movies.length, equals(1));
          expect(movies.first.id, equals(100));
          expect(movies.first.tenPhim, equals('Test Movie'));
        },
      );
    });

    test('getPopularMovies returns Right(List<Movie>) on success', () async {
      when(() => mockRemoteDataSource.getPopularMovies(page: 1))
          .thenAnswer((_) async => tResponseModel);

      final result = await repository.getPopularMovies(page: 1);

      expect(result.isRight(), isTrue);
    });
  });
}
