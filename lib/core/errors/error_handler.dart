import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failure.dart';

Failure parseFailure(dynamic e) {
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure(
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.',
      );
    }
    if (e.error is NetworkException) {
      return NetworkFailure((e.error as NetworkException).message);
    }
    if (e.error is ServerException) {
      return ServerFailure((e.error as ServerException).message);
    }
    final statusCode = e.response?.statusCode;
    return ServerFailure(
      statusCode != null
          ? 'Lỗi kết nối máy chủ ($statusCode)'
          : 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',
    );
  }
  if (e is NetworkException) {
    return NetworkFailure(e.message);
  }
  if (e is ServerException) {
    return ServerFailure(e.message);
  }
  return ServerFailure(
    e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
  );
}
