import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../models/movie.dart';
import '../entities/cast.dart';
import '../entities/genre.dart';
import '../entities/video.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1});
  Future<Either<Failure, Movie>> getMovieDetail(int movieId);
  Future<Either<Failure, List<Cast>>> getMovieCredits(int movieId);
  Future<Either<Failure, List<Video>>> getMovieTrailers(int movieId);
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int movieId);
  Future<Either<Failure, List<Movie>>> searchMovies(
      {required String query, int page = 1});
  Future<Either<Failure, List<Genre>>> getGenres();
  Future<Either<Failure, List<Movie>>> discoverMovies({
    List<int>? withGenres,
    int? primaryReleaseYearGte,
    int? primaryReleaseYearLte,
    double? minRating,
    String? sortBy,
    int page = 1,
  });
}
