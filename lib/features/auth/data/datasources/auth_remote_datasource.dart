import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel> login(String username, String password);

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? role,
    String? customerId,
    String? techId,
  });

  Future<TokenModel> refreshToken(String refreshToken);

  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<TokenModel> login(String username, String password) async {
    final resp = await _client.post(
      ApiEndpoints.login,
      data: {
        'username': username,
        'password': password,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return TokenModel.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? role,
    String? customerId,
    String? techId,
  }) async {
    final resp = await _client.post(
      ApiEndpoints.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
        'role': role ?? 'customer',
        if (customerId != null) 'customer_id': customerId,
        if (techId != null) 'tech_id': techId,
      },
    );
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<TokenModel> refreshToken(String refreshToken) async {
    final resp = await _client.post(
      ApiEndpoints.refresh,
      data: {
        'refresh_token': refreshToken,
      },
    );
    return TokenModel.fromJson(resp.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getProfile() async {
    final resp = await _client.get(ApiEndpoints.profile);
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
