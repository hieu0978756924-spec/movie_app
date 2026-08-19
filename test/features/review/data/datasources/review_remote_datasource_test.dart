import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:movie_app/features/review/data/datasources/review_remote_datasource.dart';

class MockDio extends Mock implements Dio {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late MockDio mockDio;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late ReviewRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(null);

    dataSource = ReviewRemoteDataSourceImpl(mockDio, mockSupabaseClient);
  });

  group('ReviewRemoteDataSourceImpl Tests', () {
    test('getMovieReviews returns ReviewResponseModel on 200 OK', () async {
      final mockData = {
        'page': 1,
        'results': [
          {
            'id': 'r1',
            'author': 'Reviewer 1',
            'author_details': {
              'name': 'Reviewer 1',
              'username': 'rev1',
              'avatar_path': '/avatar1.jpg',
              'rating': 9.0,
            },
            'content': 'Awesome movie!',
            'created_at': '2026-08-07T10:00:00.000Z',
          }
        ],
        'total_pages': 1,
        'total_results': 1,
      };

      when(() => mockDio.get('/movie/123/reviews', queryParameters: {'page': 1}))
          .thenAnswer(
        (_) async => Response(
          data: mockData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/movie/123/reviews'),
        ),
      );

      final result = await dataSource.getMovieReviews(123, page: 1);

      expect(result.page, equals(1));
      expect(result.results.isNotEmpty, isTrue);
    });

    test('submitReview completes successfully', () async {
      await expectLater(
        dataSource.submitReview(
          movieId: 123,
          rating: 9.0,
          content: 'Great movie!',
        ),
        completes,
      );
    });
  });
}
