import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/domain/usecases/get_now_playing_movies_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_popular_movies_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_top_rated_movies_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_trending_movies_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_upcoming_movies_usecase.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/home/presentation/bloc/home_bloc.dart';

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
  late HomeBloc homeBloc;

  setUp(() {
    mockGetTrending = MockGetTrendingMoviesUseCase();
    mockGetNowPlaying = MockGetNowPlayingMoviesUseCase();
    mockGetPopular = MockGetPopularMoviesUseCase();
    mockGetTopRated = MockGetTopRatedMoviesUseCase();
    mockGetUpcoming = MockGetUpcomingMoviesUseCase();

    homeBloc = HomeBloc(
      mockGetTrending,
      mockGetNowPlaying,
      mockGetPopular,
      mockGetTopRated,
      mockGetUpcoming,
    );
  });

  final tMovie = Movie(
    id: 1,
    tenPhim: 'Test Movie',
    hinhAnh: '/test.jpg',
    diemDanhGia: 8.5,
    moTa: 'Test Overview',
  );

  group('HomeBloc Tests', () {
    test('initial state should be HomeInitialState', () {
      expect(homeBloc.state, equals(HomeInitialState()));
    });

    test('emits [HomeLoadingState, HomeLoadedState] when FetchHomeMoviesEvent succeeds',
        () async {
      when(() => mockGetTrending())
          .thenAnswer((_) async => Right([tMovie]));
      when(() => mockGetNowPlaying())
          .thenAnswer((_) async => Right([tMovie]));
      when(() => mockGetPopular())
          .thenAnswer((_) async => Right([tMovie]));
      when(() => mockGetTopRated())
          .thenAnswer((_) async => Right([tMovie]));
      when(() => mockGetUpcoming())
          .thenAnswer((_) async => Right([tMovie]));

      final expectedStates = [
        HomeLoadingState(),
        HomeLoadedState(
          trendingMovies: [tMovie],
          nowPlayingMovies: [tMovie],
          popularMovies: [tMovie],
          topRatedMovies: [tMovie],
          upcomingMovies: [tMovie],
        ),
      ];

      expectLater(homeBloc.stream, emitsInOrder(expectedStates));

      homeBloc.add(FetchHomeMoviesEvent());
    });
  });
}
