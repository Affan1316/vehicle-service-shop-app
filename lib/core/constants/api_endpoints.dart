class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://localhost:8000';

  static const String register = '/auth/register';
  static const String login = '/auth/token';
  static const String refresh = '/auth/refresh';
  static const String profile = '/auth/me';
}
