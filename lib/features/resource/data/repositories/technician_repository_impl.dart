import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/technician.dart';
import '../../domain/repositories/technician_repository.dart';
import '../datasources/resource_remote_datasource.dart';

class TechnicianRepositoryImpl implements TechnicianRepository {
  final ResourceRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  TechnicianRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<Technician>>> getTechnicians({int limit = 50, int offset = 0}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final technicians = await _remoteDataSource.getTechnicians(limit: limit, offset: offset);
      return Right(technicians);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
