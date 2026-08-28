import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/auth_interceptor.dart';
import '../../core/network/error_interceptor.dart';

/// Tạo Dio client với cấu hình TMDB API.
/// Base URL, timeout, và các interceptors được cài đặt tự động.
Dio createTmdbDioClient() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.tmdbBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(),   // Tự động thêm api_key và language
    ErrorInterceptor(),  // Chuyển đổi lỗi HTTP thành exceptions
  ]);

  return dio;
}

@module
abstract class TmdbApiModule {
  @singleton
  Dio get dio => createTmdbDioClient();
}
