import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../models/movie.dart';
import '../repositories/movie_repository.dart';

@lazySingleton
class GetSimilarMoviesUseCase {
  final MovieRepository repository;

  GetSimilarMoviesUseCase(this.repository);

  Future<Either<Failure, List<Movie>>> call(int movieId) {
    return repository.getSimilarMovies(movieId);
  }
}
