import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/domain/usecases/get_movie_detail_usecase.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/home/presentation/bloc/movie_detail_bloc.dart';

class MockGetMovieDetailUseCase extends Mock
    implements GetMovieDetailUseCase {}

void main() {
  late MockGetMovieDetailUseCase mockGetMovieDetail;
  late MovieDetailBloc movieDetailBloc;

  setUp(() {
    mockGetMovieDetail = MockGetMovieDetailUseCase();
    movieDetailBloc = MovieDetailBloc(mockGetMovieDetail);
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

  group('MovieDetailBloc Tests', () {
    test('initial state should be MovieDetailInitialState', () {
      expect(movieDetailBloc.state, equals(MovieDetailInitialState()));
    });

    test(
        'emits [MovieDetailLoadingState, MovieDetailLoadedState] on FetchMovieDetailEvent',
        () async {
      when(() => mockGetMovieDetail(123))
          .thenAnswer((_) async => Right(tMovie));

      final expectedStates = [
        MovieDetailLoadingState(initialMovie: tMovie),
        MovieDetailLoadedState(tMovie),
      ];

      expectLater(movieDetailBloc.stream, emitsInOrder(expectedStates));

      movieDetailBloc.add(FetchMovieDetailEvent(123, initialMovie: tMovie));
    });

    test('toggles favorite on ToggleFavoriteMovieEvent', () async {
      when(() => mockGetMovieDetail(123))
          .thenAnswer((_) async => Right(tMovie));

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
