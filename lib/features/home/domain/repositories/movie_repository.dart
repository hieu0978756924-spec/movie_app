import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../models/movie.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1});
}
