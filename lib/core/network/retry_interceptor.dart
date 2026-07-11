import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If it's a connection timeout or network issue, we could retry.
    // For now, let it pass through to the next interceptor.
    super.onError(err, handler);
  }
}
