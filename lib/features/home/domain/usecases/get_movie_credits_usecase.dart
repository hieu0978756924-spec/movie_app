import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/cast.dart';
import '../repositories/movie_repository.dart';

@lazySingleton
class GetMovieCreditsUseCase {
  final MovieRepository repository;

  GetMovieCreditsUseCase(this.repository);

  Future<Either<Failure, List<Cast>>> call(int movieId) {
    return repository.getMovieCredits(movieId);
  }
}
