import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      throw const NetworkException(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.',
      );
    }

    final statusCode = err.response?.statusCode;
    final message =
        err.response?.statusMessage ?? err.message ?? 'Server error';

    if (statusCode != null && statusCode >= 400) {
      throw ServerException(message: message, statusCode: statusCode);
    }

    handler.next(err);
  }
}
