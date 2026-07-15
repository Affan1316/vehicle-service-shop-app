import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/bay.dart';
import '../../domain/repositories/bay_repository.dart';
import '../datasources/resource_remote_datasource.dart';

class BayRepositoryImpl implements BayRepository {
  final ResourceRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  BayRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<Bay>>> getBays({int limit = 50, int offset = 0}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final bays = await _remoteDataSource.getBays(limit: limit, offset: offset);
      return Right(bays);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bay>> updateBay(
    String bayId, {
    String? status,
    String? bayType,
    String? currentWorkOrderId,
    DateTime? heldUntil,
    bool clearWorkOrder = false,
    bool clearHeldUntil = false,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final bay = await _remoteDataSource.updateBay(
        bayId,
        status: status,
        bayType: bayType,
        currentWorkOrderId: currentWorkOrderId,
        heldUntil: heldUntil,
        clearWorkOrder: clearWorkOrder,
        clearHeldUntil: clearHeldUntil,
      );
      return Right(bay);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
