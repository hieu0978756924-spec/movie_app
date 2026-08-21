import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../../home/domain/repositories/movie_repository.dart';
import '../../../home/models/movie.dart';

@lazySingleton
class SearchMoviesUseCase {
  final MovieRepository repository;

  SearchMoviesUseCase(this.repository);

  Future<Either<Failure, List<Movie>>> call(
      {required String query, int page = 1}) {
    return repository.searchMovies(query: query, page: page);
  }
}
