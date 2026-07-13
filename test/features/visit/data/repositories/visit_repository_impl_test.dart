import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/core/error/failures.dart';
import 'package:wheels_doc/core/network/network_info.dart';
import 'package:wheels_doc/features/visit/data/datasources/visit_remote_datasource.dart';
import 'package:wheels_doc/features/visit/data/models/visit_model.dart';
import 'package:wheels_doc/features/visit/data/repositories/visit_repository_impl.dart';

class MockVisitRemoteDataSource extends Mock implements VisitRemoteDataSource {}
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late VisitRepositoryImpl repository;
  late MockVisitRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  final tVisitModel = VisitModel(
    visitId: 'visit-123',
    vehicleId: 'vin-123',
    customerId: 'cust-123',
    checkedInAt: DateTime(2026, 7, 10, 10, 0),
    status: 'checked_in',
    isActive: true,
  );

  setUp(() {
    mockRemoteDataSource = MockVisitRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = VisitRepositoryImpl(mockRemoteDataSource, mockNetworkInfo);
  });

  group('getVisits', () {
    test('should check if device is online and return list of visits', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getVisits(limit: any(named: 'limit'), offset: any(named: 'offset')))
          .thenAnswer((_) async => [tVisitModel]);

      final result = await repository.getVisits();

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), equals([tVisitModel]));
      verify(() => mockNetworkInfo.isConnected);
      verify(() => mockRemoteDataSource.getVisits(limit: any(named: 'limit'), offset: any(named: 'offset')));
    });

    test('should return Left(ServerFailure) when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getVisits();

      expect(result, equals(const Left(ServerFailure('No internet connection'))));
    });
  });
}
