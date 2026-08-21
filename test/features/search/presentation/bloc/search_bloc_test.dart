import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/features/home/domain/entities/genre.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/search/domain/entities/movie_filter.dart';
import 'package:movie_app/features/search/domain/usecases/discover_movies_usecase.dart';
import 'package:movie_app/features/search/domain/usecases/get_genres_usecase.dart';
import 'package:movie_app/features/search/domain/usecases/search_movies_usecase.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/features/search/presentation/bloc/search_event.dart';
import 'package:movie_app/features/search/presentation/bloc/search_state.dart';

class MockSearchMoviesUseCase extends Mock implements SearchMoviesUseCase {}

class MockGetGenresUseCase extends Mock implements GetGenresUseCase {}

class MockDiscoverMoviesUseCase extends Mock implements DiscoverMoviesUseCase {}

void main() {
  late SearchBloc searchBloc;
  late MockSearchMoviesUseCase mockSearchMoviesUseCase;
  late MockGetGenresUseCase mockGetGenresUseCase;
  late MockDiscoverMoviesUseCase mockDiscoverMoviesUseCase;

  setUp(() {
    mockSearchMoviesUseCase = MockSearchMoviesUseCase();
    mockGetGenresUseCase = MockGetGenresUseCase();
    mockDiscoverMoviesUseCase = MockDiscoverMoviesUseCase();

    searchBloc = SearchBloc(
      mockSearchMoviesUseCase,
      mockGetGenresUseCase,
      mockDiscoverMoviesUseCase,
    );
  });

  tearDown(() {
    searchBloc.close();
  });

  const tQuery = 'Avatar';
  final List<Genre> tGenres = [
    const Genre(id: 28, name: 'Hành động'),
    const Genre(id: 12, name: 'Phiêu lưu'),
  ];
  final List<Movie> tMovies = [
    Movie(
      id: 202,
      tenPhim: 'Avatar: The Way of Water',
      hinhAnh: '/avatar.jpg',
      moTa: 'Pandora sci-fi epic',
      diemDanhGia: 8.8,
    ),
  ];
  const tFilter = MovieFilter(
    selectedGenreIds: [28],
    minRating: 8.0,
    sortBy: SortOption.ratingDesc,
  );

  test('initial state should be SearchInitialState', () {
    expect(searchBloc.state, equals(const SearchInitialState()));
  });

  blocTest<SearchBloc, SearchState>(
    'emits state with loaded genres when FetchGenresEvent succeeds',
    build: () {
      when(() => mockGetGenresUseCase())
          .thenAnswer((_) async => Right(tGenres));
      return searchBloc;
    },
    act: (bloc) => bloc.add(const FetchGenresEvent()),
    expect: () => [
      SearchInitialState(genres: tGenres),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'emits [SearchInitialState] when query is empty and filter is default',
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
  );

  blocTest<SearchBloc, SearchState>(
    'emits [SearchLoadingState, SearchLoadedState] when ApplyFilterEvent is triggered with discover API',
    build: () {
      when(() => mockDiscoverMoviesUseCase(filter: tFilter))
          .thenAnswer((_) async => Right(tMovies));
      return searchBloc;
    },
    act: (bloc) => bloc.add(const ApplyFilterEvent(tFilter)),
    expect: () => [
      const SearchLoadingState(filter: tFilter),
      SearchLoadedState(movies: tMovies, query: '', filter: tFilter),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'emits [SearchInitialState] when ResetFilterEvent is added and query is empty',
    build: () => searchBloc,
    act: (bloc) => bloc.add(const ResetFilterEvent()),
    expect: () => [
      const SearchInitialState(),
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
