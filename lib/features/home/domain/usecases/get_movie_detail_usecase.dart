import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../models/movie.dart';
import '../repositories/movie_repository.dart';

@lazySingleton
class GetMovieDetailUseCase {
  final MovieRepository repository;

  GetMovieDetailUseCase(this.repository);

  Future<Either<Failure, Movie>> call(int movieId) {
    return repository.getMovieDetail(movieId);
  }
}
