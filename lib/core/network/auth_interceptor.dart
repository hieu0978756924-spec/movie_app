import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final queryParams = Map<String, dynamic>.from(options.queryParameters);

    if (!queryParams.containsKey('api_key')) {
      queryParams['api_key'] = ApiConstants.tmdbApiKey;
    }

    if (!queryParams.containsKey('language')) {
      queryParams['language'] = ApiConstants.defaultLanguage;
    }

    options.queryParameters = queryParams;
    super.onRequest(options, handler);
  }
}
