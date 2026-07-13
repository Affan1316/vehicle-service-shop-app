import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_remote_datasource.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  VisitRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<Visit>>> getVisits({int limit = 50, int offset = 0}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final visits = await _remoteDataSource.getVisits(limit: limit, offset: offset);
      return Right(visits);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Visit>> createVisit({
    required String vehicleId,
    required String customerId,
    String? appointmentId,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final visit = await _remoteDataSource.createVisit(
        vehicleId: vehicleId,
        customerId: customerId,
        appointmentId: appointmentId,
      );
      return Right(visit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Visit>> updateVisit(
    String visitId, {
    String? status,
    DateTime? checkedOutAt,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final visit = await _remoteDataSource.updateVisit(
        visitId,
        status: status,
        checkedOutAt: checkedOutAt,
      );
      return Right(visit);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
