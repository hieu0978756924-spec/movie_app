import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/domain/entities/cast.dart';
import 'package:movie_app/features/home/domain/entities/video.dart';
import 'package:movie_app/features/home/domain/usecases/get_movie_credits_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_movie_detail_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_movie_trailers_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_similar_movies_usecase.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/home/presentation/bloc/movie_detail_bloc.dart';

import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';

class MockGetMovieDetailUseCase extends Mock implements GetMovieDetailUseCase {}

class MockGetMovieCreditsUseCase extends Mock
    implements GetMovieCreditsUseCase {}

class MockGetMovieTrailersUseCase extends Mock
    implements GetMovieTrailersUseCase {}

class MockGetSimilarMoviesUseCase extends Mock
    implements GetSimilarMoviesUseCase {}

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late MockGetMovieDetailUseCase mockGetMovieDetail;
  late MockGetMovieCreditsUseCase mockGetMovieCredits;
  late MockGetMovieTrailersUseCase mockGetMovieTrailers;
  late MockGetSimilarMoviesUseCase mockGetSimilarMovies;
  late MockWatchlistRepository mockWatchlistRepository;
  late MovieDetailBloc movieDetailBloc;

  setUp(() {
    mockGetMovieDetail = MockGetMovieDetailUseCase();
    mockGetMovieCredits = MockGetMovieCreditsUseCase();
    mockGetMovieTrailers = MockGetMovieTrailersUseCase();
    mockGetSimilarMovies = MockGetSimilarMoviesUseCase();
    mockWatchlistRepository = MockWatchlistRepository();
    when(() => mockWatchlistRepository.isWatchlisted(any()))
        .thenAnswer((_) async => const Right(false));
    movieDetailBloc = MovieDetailBloc(
      mockGetMovieDetail,
      mockGetMovieCredits,
      mockGetMovieTrailers,
      mockGetSimilarMovies,
      mockWatchlistRepository,
    );
  });

  final tMovie = Movie(
    id: 123,
    tenPhim: 'Detail Movie Test',
    hinhAnh: '/poster.jpg',
    backdropPath: '/backdrop.jpg',
    diemDanhGia: 9.0,
    theLoai: 'Action, Sci-Fi',
    thoiLuong: '148 min',
    moTa: 'Movie Detail Overview Text',
    namPhatHanh: 2026,
    daoDien: 'Inception',
    voteCount: 1500,
  );

  const tCast = Cast(
    id: 1,
    name: 'Leonardo DiCaprio',
    character: 'Cobb',
    profilePath: '/profile.jpg',
  );

  const tVideo = Video(
    id: 'vid123',
    name: 'Official Trailer',
    key: 'dQw4w9WgXcQ',
    site: 'YouTube',
    type: 'Trailer',
    official: true,
  );

  final tSimilarMovie = Movie(
    id: 456,
    tenPhim: 'Similar Movie',
    hinhAnh: '/similar.jpg',
    moTa: 'Overview',
    diemDanhGia: 8.0,
  );

  group('MovieDetailBloc Tests', () {
    test('initial state should be MovieDetailInitialState', () {
      expect(movieDetailBloc.state, equals(MovieDetailInitialState()));
    });

    test(
        'emits [MovieDetailLoadingState, MovieDetailLoadedState] on FetchMovieDetailEvent',
        () async {
      when(() => mockGetMovieDetail(123))
          .thenAnswer((_) async => Right(tMovie));
      when(() => mockGetMovieCredits(123))
          .thenAnswer((_) async => const Right([tCast]));
      when(() => mockGetMovieTrailers(123))
          .thenAnswer((_) async => const Right([tVideo]));
      when(() => mockGetSimilarMovies(123))
          .thenAnswer((_) async => Right([tSimilarMovie]));

      final expectedStates = [
        MovieDetailLoadingState(initialMovie: tMovie),
        MovieDetailLoadedState(
          tMovie.copyWith(
              trailerUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
          castList: const [tCast],
          trailers: const [tVideo],
          similarMovies: [tSimilarMovie],
        ),
      ];

      expectLater(movieDetailBloc.stream, emitsInOrder(expectedStates));

      movieDetailBloc.add(FetchMovieDetailEvent(123, initialMovie: tMovie));
    });

    test('toggles favorite on ToggleFavoriteMovieEvent', () async {
      when(() => mockGetMovieDetail(123))
          .thenAnswer((_) async => Right(tMovie));
      when(() => mockGetMovieCredits(123))
          .thenAnswer((_) async => const Right([tCast]));
      when(() => mockGetMovieTrailers(123))
          .thenAnswer((_) async => const Right([tVideo]));
      when(() => mockGetSimilarMovies(123))
          .thenAnswer((_) async => Right([tSimilarMovie]));

      movieDetailBloc.add(FetchMovieDetailEvent(123, initialMovie: tMovie));
      await untilCalled(() => mockGetMovieDetail(123));
      await Future.delayed(Duration.zero);

      expect(movieDetailBloc.state, isA<MovieDetailLoadedState>());

      final expectation = expectLater(
        movieDetailBloc.stream,
        emits(isA<MovieDetailLoadedState>().having(
          (s) => s.movie.yeuThich,
          'yeuThich',
          isTrue,
        )),
      );

      movieDetailBloc.add(ToggleFavoriteMovieEvent());
      await expectation;
    });
  });
}
