import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/genre.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../models/movie.dart';
import '../datasources/movie_remote_datasource.dart';

@LazySingleton(as: MovieRepository)
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;

  MovieRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies(
      {int page = 1}) async {
    try {
      final response = await remoteDataSource.getTrendingMovies(page: page);
      final movies = response.results.map((model) => model.toEntity()).toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies(
      {int page = 1}) async {
    try {
      final response = await remoteDataSource.getNowPlayingMovies(page: page);
      final movies = response.results.map((model) => model.toEntity()).toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies(
      {int page = 1}) async {
    try {
      final response = await remoteDataSource.getPopularMovies(page: page);
      final movies = response.results.map((model) => model.toEntity()).toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies(
      {int page = 1}) async {
    try {
      final response = await remoteDataSource.getTopRatedMovies(page: page);
      final movies = response.results.map((model) => model.toEntity()).toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getUpcomingMovies(
      {int page = 1}) async {
    try {
      final response = await remoteDataSource.getUpcomingMovies(page: page);
      final movies = response.results.map((model) => model.toEntity()).toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetail(int movieId) async {
    try {
      final detailModel = await remoteDataSource.getMovieDetail(movieId);
      return Right(detailModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int movieId) async {
    try {
      final response = await remoteDataSource.getMovieCredits(movieId);
      final castList = response.cast.map((model) => model.toEntity()).toList();
      return Right(castList);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Video>>> getMovieTrailers(int movieId) async {
    try {
      final response = await remoteDataSource.getMovieTrailers(movieId);
      final trailers = response.results.map((model) => model.toEntity()).toList();
      return Right(trailers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int movieId) async {
    try {
      final response = await remoteDataSource.getSimilarMovies(movieId);
      final movies = response.results.map((model) => model.toEntity()).toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(
      {required String query, int page = 1}) async {
    try {
      final response = await remoteDataSource.searchMovies(query: query, page: page);
      final movies = response.results.map((model) => model.toEntity()).toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Genre>>> getGenres() async {
    try {
      final response = await remoteDataSource.getGenres();
      final genres = response.genres.map((model) => model.toEntity()).toList();
      return Right(genres);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> discoverMovies({
    List<int>? withGenres,
    int? primaryReleaseYearGte,
    int? primaryReleaseYearLte,
    double? minRating,
    String? sortBy,
    int page = 1,
  }) async {
    try {
      final response = await remoteDataSource.discoverMovies(
        withGenres: withGenres,
        primaryReleaseYearGte: primaryReleaseYearGte,
        primaryReleaseYearLte: primaryReleaseYearLte,
        minRating: minRating,
        sortBy: sortBy,
        page: page,
      );
      final movies = response.results.map((model) => model.toEntity()).toList();
      return Right(movies);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
