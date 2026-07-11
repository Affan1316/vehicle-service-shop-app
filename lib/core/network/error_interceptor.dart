import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    if (response != null) {
      final data = response.data;
      String message = 'API call failed';
      
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          final detail = data['detail'];
          if (detail is String) {
            message = detail;
          } else if (detail is List) {
            // Pydantic validation error lists
            try {
              message = detail.map((e) => "${e['loc']?.last ?? 'field'}: ${e['msg']}").join(', ');
            } catch (_) {
              message = detail.toString();
            }
          }
        } else if (data.containsKey('message')) {
          message = data['message'] as String;
        }
      }

      if (response.statusCode == 400 || response.statusCode == 422) {
        throw ValidationException(message);
      } else {
        throw ServerException(message);
      }
    }
    super.onError(err, handler);
  }
}
