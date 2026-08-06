import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/domain/entities/cast.dart';
import 'package:movie_app/features/home/domain/usecases/get_movie_credits_usecase.dart';
import 'package:movie_app/features/home/domain/usecases/get_movie_detail_usecase.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/home/presentation/bloc/movie_detail_bloc.dart';

class MockGetMovieDetailUseCase extends Mock
    implements GetMovieDetailUseCase {}

class MockGetMovieCreditsUseCase extends Mock
    implements GetMovieCreditsUseCase {}

void main() {
  late MockGetMovieDetailUseCase mockGetMovieDetail;
  late MockGetMovieCreditsUseCase mockGetMovieCredits;
  late MovieDetailBloc movieDetailBloc;

  setUp(() {
    mockGetMovieDetail = MockGetMovieDetailUseCase();
    mockGetMovieCredits = MockGetMovieCreditsUseCase();
    movieDetailBloc = MovieDetailBloc(
      mockGetMovieDetail,
      mockGetMovieCredits,
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

      final expectedStates = [
        MovieDetailLoadingState(initialMovie: tMovie),
        MovieDetailLoadedState(tMovie, castList: const [tCast]),
      ];

      expectLater(movieDetailBloc.stream, emitsInOrder(expectedStates));

      movieDetailBloc.add(FetchMovieDetailEvent(123, initialMovie: tMovie));
    });

    test('toggles favorite on ToggleFavoriteMovieEvent', () async {
      when(() => mockGetMovieDetail(123))
          .thenAnswer((_) async => Right(tMovie));
      when(() => mockGetMovieCredits(123))
          .thenAnswer((_) async => const Right([tCast]));

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
