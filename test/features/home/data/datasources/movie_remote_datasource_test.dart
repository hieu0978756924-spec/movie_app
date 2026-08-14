import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/data/datasources/movie_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late MovieRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = MovieRemoteDataSourceImpl(mockDio);
  });

  final tResponseJson = {
    'page': 1,
    'results': [
      {
        'id': 100,
        'title': 'Test Movie',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'vote_average': 7.5,
        'release_date': '2026-01-01',
        'overview': 'Test Overview',
        'genre_ids': [28],
        'vote_count': 150,
      }
    ],
    'total_pages': 10,
    'total_results': 100,
  };

  group('MovieRemoteDataSource Tests', () {
    test('getTrendingMovies calls GET /trending/movie/day', () async {
      when(() => mockDio.get(
            '/trending/movie/day',
            queryParameters: {'page': 1},
          )).thenAnswer((_) async => Response(
            data: tResponseJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/trending/movie/day'),
          ));

      final result = await dataSource.getTrendingMovies(page: 1);

      expect(result.results.length, equals(1));
      expect(result.results.first.title, equals('Test Movie'));
    });

    test('getNowPlayingMovies calls GET /movie/now_playing', () async {
      when(() => mockDio.get(
            '/movie/now_playing',
            queryParameters: {'page': 1},
          )).thenAnswer((_) async => Response(
            data: tResponseJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/movie/now_playing'),
          ));

      final result = await dataSource.getNowPlayingMovies(page: 1);

      expect(result.results.length, equals(1));
    });

    test('getPopularMovies calls GET /movie/popular', () async {
      when(() => mockDio.get(
            '/movie/popular',
            queryParameters: {'page': 1},
          )).thenAnswer((_) async => Response(
            data: tResponseJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/movie/popular'),
          ));

      final result = await dataSource.getPopularMovies(page: 1);

      expect(result.results.length, equals(1));
    });

    test('getTopRatedMovies calls GET /movie/top_rated', () async {
      when(() => mockDio.get(
            '/movie/top_rated',
            queryParameters: {'page': 1},
          )).thenAnswer((_) async => Response(
            data: tResponseJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/movie/top_rated'),
          ));

      final result = await dataSource.getTopRatedMovies(page: 1);

      expect(result.results.length, equals(1));
    });

    test('getUpcomingMovies calls GET /movie/upcoming', () async {
      when(() => mockDio.get(
            '/movie/upcoming',
            queryParameters: {'page': 1},
          )).thenAnswer((_) async => Response(
            data: tResponseJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/movie/upcoming'),
          ));

      final result = await dataSource.getUpcomingMovies(page: 1);

      expect(result.results.length, equals(1));
    });
  });
}
