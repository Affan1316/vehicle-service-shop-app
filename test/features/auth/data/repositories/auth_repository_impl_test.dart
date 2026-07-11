import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/core/error/exceptions.dart';
import 'package:wheels_doc/core/error/failures.dart';
import 'package:wheels_doc/core/network/network_info.dart';
import 'package:wheels_doc/core/storage/secure_storage.dart';
import 'package:wheels_doc/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:wheels_doc/features/auth/data/models/token_model.dart';
import 'package:wheels_doc/features/auth/data/models/user_model.dart';
import 'package:wheels_doc/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureStorage extends Mock implements SecureStorage {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSecureStorage mockSecureStorage;
  late MockNetworkInfo mockNetworkInfo;

  const tTokenModel = TokenModel(
    accessToken: 'access',
    refreshToken: 'refresh',
    tokenType: 'bearer',
  );

  const tUserModel = UserModel(
    id: '1',
    username: 'testuser',
    email: 'test@example.com',
    role: 'customer',
    isActive: true,
  );

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorage = MockSecureStorage();
    mockNetworkInfo = MockNetworkInfo();

    repository = AuthRepositoryImpl(
      mockRemoteDataSource,
      mockSecureStorage,
      mockNetworkInfo,
    );
  });

  group('login', () {
    test('should check if device is online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => tTokenModel);
      when(() => mockSecureStorage.saveAccessToken(any()))
          .thenAnswer((_) async => {});
      when(() => mockSecureStorage.saveRefreshToken(any()))
          .thenAnswer((_) async => {});

      await repository.login('user', 'pass');

      verify(() => mockNetworkInfo.isConnected);
    });

    test('should return Left(ServerFailure) when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.login('user', 'pass');

      expect(result, equals(const Left(ServerFailure('No internet connection'))));
    });

    test('should cache tokens on successful login', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenAnswer((_) async => tTokenModel);
      when(() => mockSecureStorage.saveAccessToken(any()))
          .thenAnswer((_) async => {});
      when(() => mockSecureStorage.saveRefreshToken(any()))
          .thenAnswer((_) async => {});

      final result = await repository.login('user', 'pass');

      verify(() => mockSecureStorage.saveAccessToken(tTokenModel.accessToken));
      verify(() => mockSecureStorage.saveRefreshToken(tTokenModel.refreshToken));
      expect(result, equals(const Right(tTokenModel)));
    });

    test('should return Left(ServerFailure) on ServerException', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(any(), any()))
          .thenThrow(ServerException('Server Error'));

      final result = await repository.login('user', 'pass');

      expect(result, equals(const Left(ServerFailure('Server Error'))));
    });
  });

  group('register', () {
    test('should return Right(User) on successful remote registration', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.register(
            username: any(named: 'username'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
          )).thenAnswer((_) async => tUserModel);

      final result = await repository.register(
        username: 'testuser',
        email: 'test@example.com',
        password: 'password',
        role: 'customer',
      );

      expect(result, equals(const Right(tUserModel)));
      verify(() => mockRemoteDataSource.register(
            username: 'testuser',
            email: 'test@example.com',
            password: 'password',
            role: 'customer',
          ));
    });
  });
}
