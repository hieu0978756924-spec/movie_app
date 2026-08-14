import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/movie_repository.dart';
import '../../models/movie.dart';

@lazySingleton
class GetTopRatedMoviesUseCase {
  final MovieRepository repository;

  GetTopRatedMoviesUseCase(this.repository);

  Future<Either<Failure, List<Movie>>> call({int page = 1}) async {
    return await repository.getTopRatedMovies(page: page);
  }
}
