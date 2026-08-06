import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../models/movie_response_model.dart';

abstract class MovieRemoteDataSource {
  Future<MovieResponseModel> getTrendingMovies({int page = 1});
  Future<MovieResponseModel> getNowPlayingMovies({int page = 1});
  Future<MovieResponseModel> getPopularMovies({int page = 1});
  Future<MovieResponseModel> getTopRatedMovies({int page = 1});
  Future<MovieResponseModel> getUpcomingMovies({int page = 1});
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
}
