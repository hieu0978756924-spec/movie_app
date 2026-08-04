import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      throw NetworkException(err.message ?? 'Lỗi kết nối mạng');
    }

    final statusCode = err.response?.statusCode;
    final message = err.response?.statusMessage ?? err.message ?? 'Server error';

    if (statusCode != null && statusCode >= 400) {
      throw ServerException(message: message, statusCode: statusCode);
    }

    super.onError(err, handler);
  }
}
