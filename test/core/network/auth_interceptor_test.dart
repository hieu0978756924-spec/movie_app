import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/network/auth_interceptor.dart';

void main() {
  late AuthInterceptor interceptor;

  setUp(() {
    interceptor = AuthInterceptor();
  });

  test('should append api_key and language to queryParameters when onRequest is called', () {
    final options = RequestOptions(path: '/trending/movie/week');
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.queryParameters.containsKey('api_key'), true);
    expect(options.queryParameters['language'], 'vi-VN');
  });
}
