import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../../home/domain/repositories/movie_repository.dart';
import '../../../home/models/movie.dart';
import '../entities/movie_filter.dart';

@lazySingleton
class DiscoverMoviesUseCase {
  final MovieRepository repository;

  DiscoverMoviesUseCase(this.repository);

  Future<Either<Failure, List<Movie>>> call({
    required MovieFilter filter,
    int page = 1,
  }) {
    return repository.discoverMovies(
      withGenres: filter.selectedGenreIds,
      primaryReleaseYearGte: filter.startYear,
      primaryReleaseYearLte: filter.endYear,
      minRating: filter.minRating,
      sortBy: filter.sortBy.value,
      page: page,
    );
  }
}
