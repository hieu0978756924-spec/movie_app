import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/errors/failure.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/search/domain/usecases/search_movies_usecase.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/features/search/presentation/bloc/search_event.dart';
import 'package:movie_app/features/search/presentation/bloc/search_state.dart';

class MockSearchMoviesUseCase extends Mock implements SearchMoviesUseCase {}

void main() {
  late SearchBloc searchBloc;
  late MockSearchMoviesUseCase mockSearchMoviesUseCase;

  setUp(() {
    mockSearchMoviesUseCase = MockSearchMoviesUseCase();
    searchBloc = SearchBloc(mockSearchMoviesUseCase);
  });

  tearDown(() {
    searchBloc.close();
  });

  const tQuery = 'Avatar';
  final List<Movie> tMovies = [
    Movie(
      id: 202,
      tenPhim: 'Avatar: The Way of Water',
      hinhAnh: '/avatar.jpg',
      moTa: 'Pandora sci-fi epic',
      diemDanhGia: 8.8,
    ),
  ];

  test('initial state should be SearchInitialState', () {
    expect(searchBloc.state, equals(const SearchInitialState()));
  });

  blocTest<SearchBloc, SearchState>(
    'emits [SearchInitialState] when query is empty',
    build: () => searchBloc,
    act: (bloc) => bloc.add(const SearchQueryChangedEvent('   ')),
    wait: const Duration(milliseconds: 600),
    expect: () => [
      const SearchInitialState(),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'emits [SearchLoadingState, SearchLoadedState] when search query succeeds',
    build: () {
      when(() => mockSearchMoviesUseCase(query: tQuery))
          .thenAnswer((_) async => Right(tMovies));
      return searchBloc;
    },
    act: (bloc) => bloc.add(const SearchQueryChangedEvent(tQuery)),
    wait: const Duration(milliseconds: 600),
    expect: () => [
      const SearchLoadingState(),
      SearchLoadedState(movies: tMovies, query: tQuery),
    ],
    verify: (_) {
      verify(() => mockSearchMoviesUseCase(query: tQuery)).called(1);
    },
  );

  blocTest<SearchBloc, SearchState>(
    'emits [SearchLoadingState, SearchEmptyState] when no movies match query',
    build: () {
      when(() => mockSearchMoviesUseCase(query: tQuery))
          .thenAnswer((_) async => const Right([]));
      return searchBloc;
    },
    act: (bloc) => bloc.add(const SearchQueryChangedEvent(tQuery)),
    wait: const Duration(milliseconds: 600),
    expect: () => [
      const SearchLoadingState(),
      const SearchEmptyState(tQuery),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'emits [SearchLoadingState, SearchErrorState] when search fails',
    build: () {
      when(() => mockSearchMoviesUseCase(query: tQuery))
          .thenAnswer((_) async => const Left(ServerFailure('Connection timeout')));
      return searchBloc;
    },
    act: (bloc) => bloc.add(const SearchQueryChangedEvent(tQuery)),
    wait: const Duration(milliseconds: 600),
    expect: () => [
      const SearchLoadingState(),
      const SearchErrorState('Connection timeout'),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'emits [SearchInitialState] when ClearSearchEvent is added',
    build: () => searchBloc,
    act: (bloc) => bloc.add(const ClearSearchEvent()),
    expect: () => [
      const SearchInitialState(),
    ],
  );
}
