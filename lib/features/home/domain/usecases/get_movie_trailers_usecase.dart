import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/video.dart';
import '../repositories/movie_repository.dart';

@lazySingleton
class GetMovieTrailersUseCase {
  final MovieRepository repository;

  GetMovieTrailersUseCase(this.repository);

  Future<Either<Failure, List<Video>>> call(int movieId) {
    return repository.getMovieTrailers(movieId);
  }
}
