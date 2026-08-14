import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/domain/usecases/get_now_playing_movies_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_popular_movies_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_top_rated_movies_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_trending_movies_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_upcoming_movies_usecase.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/home/presentation/bloc/category_bloc.dart';

class MockGetTrendingMoviesUseCase extends Mock
    implements GetTrendingMoviesUseCase {}

class MockGetNowPlayingMoviesUseCase extends Mock
    implements GetNowPlayingMoviesUseCase {}

class MockGetPopularMoviesUseCase extends Mock
    implements GetPopularMoviesUseCase {}

class MockGetTopRatedMoviesUseCase extends Mock
    implements GetTopRatedMoviesUseCase {}

class MockGetUpcomingMoviesUseCase extends Mock
    implements GetUpcomingMoviesUseCase {}

void main() {
  late MockGetTrendingMoviesUseCase mockGetTrending;
  late MockGetNowPlayingMoviesUseCase mockGetNowPlaying;
  late MockGetPopularMoviesUseCase mockGetPopular;
  late MockGetTopRatedMoviesUseCase mockGetTopRated;
  late MockGetUpcomingMoviesUseCase mockGetUpcoming;
  late CategoryBloc categoryBloc;

  setUp(() {
    mockGetTrending = MockGetTrendingMoviesUseCase();
    mockGetNowPlaying = MockGetNowPlayingMoviesUseCase();
    mockGetPopular = MockGetPopularMoviesUseCase();
    mockGetTopRated = MockGetTopRatedMoviesUseCase();
    mockGetUpcoming = MockGetUpcomingMoviesUseCase();

    categoryBloc = CategoryBloc(
      mockGetTrending,
      mockGetNowPlaying,
      mockGetPopular,
      mockGetTopRated,
      mockGetUpcoming,
    );
  });

  final tMovie = Movie(
    id: 1,
    tenPhim: 'Test Category Movie',
    hinhAnh: '/poster.jpg',
    diemDanhGia: 8.2,
    moTa: 'Overview',
  );

  group('CategoryBloc Tests', () {
    test('initial state should be CategoryInitialState', () {
      expect(categoryBloc.state, equals(CategoryInitialState()));
    });

    test(
        'emits [CategoryLoadingState, CategoryLoadedState] on FetchCategoryMoviesEvent',
        () async {
      when(() => mockGetPopular(page: 1))
          .thenAnswer((_) async => Right([tMovie]));

      final expectedStates = [
        CategoryLoadingState(),
        CategoryLoadedState(
          movies: [tMovie],
          categoryType: 'popular',
          currentPage: 1,
          hasReachedMax: false,
        ),
      ];

      expectLater(categoryBloc.stream, emitsInOrder(expectedStates));

      categoryBloc.add(const FetchCategoryMoviesEvent('popular'));
    });
  });
}
