import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/credits_response_model.dart';
import '../models/genre_model.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_response_model.dart';
import '../models/video_response_model.dart';

abstract class MovieRemoteDataSource {
  Future<MovieResponseModel> getTrendingMovies({int page = 1});
  Future<MovieResponseModel> getNowPlayingMovies({int page = 1});
  Future<MovieResponseModel> getPopularMovies({int page = 1});
  Future<MovieResponseModel> getTopRatedMovies({int page = 1});
  Future<MovieResponseModel> getUpcomingMovies({int page = 1});
  Future<MovieDetailModel> getMovieDetail(int movieId);
  Future<CreditsResponseModel> getMovieCredits(int movieId);
  Future<VideoResponseModel> getMovieTrailers(int movieId);
  Future<MovieResponseModel> getSimilarMovies(int movieId);
  Future<MovieResponseModel> searchMovies(
      {required String query, int page = 1});
  Future<GenreResponseModel> getGenres();
  Future<MovieResponseModel> discoverMovies({
    List<int>? withGenres,
    int? primaryReleaseYearGte,
    int? primaryReleaseYearLte,
    double? minRating,
    String? sortBy,
    int page = 1,
  });
}

@LazySingleton(as: MovieRemoteDataSource)
class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final Dio dio;

  MovieRemoteDataSourceImpl(this.dio);

  @override
  Future<MovieResponseModel> getTrendingMovies({int page = 1}) async {
    final response = await dio.get(
      '/trending/movie/day',
      queryParameters: {'page': page},
    );
    return MovieResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MovieResponseModel> getNowPlayingMovies({int page = 1}) async {
    final response = await dio.get(
      '/movie/now_playing',
      queryParameters: {'page': page},
    );
    return MovieResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MovieResponseModel> getPopularMovies({int page = 1}) async {
    final response = await dio.get(
      '/movie/popular',
      queryParameters: {'page': page},
    );
    return MovieResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MovieResponseModel> getTopRatedMovies({int page = 1}) async {
    final response = await dio.get(
      '/movie/top_rated',
      queryParameters: {'page': page},
    );
    return MovieResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MovieResponseModel> getUpcomingMovies({int page = 1}) async {
    final response = await dio.get(
      '/movie/upcoming',
      queryParameters: {'page': page},
    );
    return MovieResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MovieDetailModel> getMovieDetail(int movieId) async {
    final response = await dio.get('/movie/$movieId');
    return MovieDetailModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CreditsResponseModel> getMovieCredits(int movieId) async {
    final response = await dio.get('/movie/$movieId/credits');
    return CreditsResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<VideoResponseModel> getMovieTrailers(int movieId) async {
    final response = await dio.get(
      '/movie/$movieId/videos',
      queryParameters: {
        'language': 'en-US',
        'include_video_language': 'en,vi,null',
      },
    );
    return VideoResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MovieResponseModel> getSimilarMovies(int movieId) async {
    final response = await dio.get('/movie/$movieId/similar');
    return MovieResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MovieResponseModel> searchMovies(
      {required String query, int page = 1}) async {
    final response = await dio.get(
      '/search/movie',
      queryParameters: {
        'query': query,
        'page': page,
      },
    );
    return MovieResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<GenreResponseModel> getGenres() async {
    final response = await dio.get('/genre/movie/list');
    return GenreResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<MovieResponseModel> discoverMovies({
    List<int>? withGenres,
    int? primaryReleaseYearGte,
    int? primaryReleaseYearLte,
    double? minRating,
    String? sortBy,
    int page = 1,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
    };
    if (withGenres != null && withGenres.isNotEmpty) {
      queryParameters['with_genres'] = withGenres.join(',');
    }
    if (primaryReleaseYearGte != null) {
      queryParameters['primary_release_date.gte'] =
          '$primaryReleaseYearGte-01-01';
    }
    if (primaryReleaseYearLte != null) {
      queryParameters['primary_release_date.lte'] =
          '$primaryReleaseYearLte-12-31';
    }
    if (minRating != null && minRating > 0) {
      queryParameters['vote_average.gte'] = minRating;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      queryParameters['sort_by'] = sortBy;
    }

    final response = await dio.get(
      '/discover/movie',
      queryParameters: queryParameters,
    );
    return MovieResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
