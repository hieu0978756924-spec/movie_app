import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../../home/domain/entities/genre.dart';
import '../../../home/domain/repositories/movie_repository.dart';

@lazySingleton
class GetGenresUseCase {
  final MovieRepository repository;

  GetGenresUseCase(this.repository);

  Future<Either<Failure, List<Genre>>> call() {
    return repository.getGenres();
  }
}
