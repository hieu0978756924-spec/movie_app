import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/exceptions.dart';
import 'package:movie_app/core/network/error_interceptor.dart';

void main() {
  late ErrorInterceptor interceptor;

  setUp(() {
    interceptor = ErrorInterceptor();
  });

  test('should throw ServerException when DioException response status is 4xx or 5xx', () {
    final response = Response(
      requestOptions: RequestOptions(path: '/movie/1'),
      statusCode: 404,
      statusMessage: 'Not Found',
    );

    final dioError = DioException(
      requestOptions: RequestOptions(path: '/movie/1'),
      response: response,
      type: DioExceptionType.badResponse,
    );

    final handler = ErrorInterceptorHandler();

    expect(
      () => interceptor.onError(dioError, handler),
      throwsA(isA<ServerException>()),
    );
  });
}
