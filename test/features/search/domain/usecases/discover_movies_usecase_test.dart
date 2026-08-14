import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/errors/failure.dart';
import 'package:movie_app/features/home/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/home/models/movie.dart';
import 'package:movie_app/features/search/domain/entities/movie_filter.dart';
import 'package:movie_app/features/search/domain/usecases/discover_movies_usecase.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late DiscoverMoviesUseCase useCase;
  late MockMovieRepository mockRepository;

  setUp(() {
    mockRepository = MockMovieRepository();
    useCase = DiscoverMoviesUseCase(mockRepository);
  });

  const tFilter = MovieFilter(
    selectedGenreIds: [28],
    startYear: 2020,
    endYear: 2024,
    minRating: 7.0,
    sortBy: SortOption.ratingDesc,
  );

  final List<Movie> tMovies = [
    Movie(
      id: 505,
      tenPhim: 'Action Hit',
      hinhAnh: '/action.jpg',
      moTa: 'Exciting action',
      diemDanhGia: 8.2,
    ),
  ];

  test('should call discoverMovies on repository with filter params', () async {
    when(() => mockRepository.discoverMovies(
          withGenres: tFilter.selectedGenreIds,
          primaryReleaseYearGte: tFilter.startYear,
          primaryReleaseYearLte: tFilter.endYear,
          minRating: tFilter.minRating,
          sortBy: tFilter.sortBy.value,
          page: 1,
        )).thenAnswer((_) async => Right(tMovies));

    final result = await useCase(filter: tFilter);

    expect(result, Right(tMovies));
    verify(() => mockRepository.discoverMovies(
          withGenres: tFilter.selectedGenreIds,
          primaryReleaseYearGte: tFilter.startYear,
          primaryReleaseYearLte: tFilter.endYear,
          minRating: tFilter.minRating,
          sortBy: tFilter.sortBy.value,
          page: 1,
        ));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ServerFailure when discoverMovies fails', () async {
    when(() => mockRepository.discoverMovies(
          withGenres: tFilter.selectedGenreIds,
          primaryReleaseYearGte: tFilter.startYear,
          primaryReleaseYearLte: tFilter.endYear,
          minRating: tFilter.minRating,
          sortBy: tFilter.sortBy.value,
          page: 1,
        )).thenAnswer((_) async => const Left(ServerFailure('Network error')));

    final result = await useCase(filter: tFilter);

    expect(result, const Left(ServerFailure('Network error')));
    verify(() => mockRepository.discoverMovies(
          withGenres: tFilter.selectedGenreIds,
          primaryReleaseYearGte: tFilter.startYear,
          primaryReleaseYearLte: tFilter.endYear,
          minRating: tFilter.minRating,
          sortBy: tFilter.sortBy.value,
          page: 1,
        ));
    verifyNoMoreInteractions(mockRepository);
  });
}
