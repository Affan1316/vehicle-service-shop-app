import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/work_order.dart';
import '../../domain/entities/line_item.dart';
import '../../domain/entities/labor_entry.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  JobRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<WorkOrder>>> getWorkOrders({int limit = 100, int offset = 0}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final workOrders = await _remoteDataSource.getWorkOrders(limit: limit, offset: offset);
      return Right(workOrders);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkOrder>> createWorkOrder({
    required String quoteId,
    required String vehicleId,
    required String customerId,
    required double authorizedAmount,
    String? visitId,
    DateTime? promisedDate,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final workOrder = await _remoteDataSource.createWorkOrder(
        quoteId: quoteId,
        vehicleId: vehicleId,
        customerId: customerId,
        authorizedAmount: authorizedAmount,
        visitId: visitId,
        promisedDate: promisedDate,
      );
      return Right(workOrder);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkOrder>> updateWorkOrder(
    String workOrderId, {
    String? status,
    String? bayId,
    double? authorizedAmount,
    DateTime? promisedDate,
    DateTime? scheduledAt,
    DateTime? pausedAt,
    String? pauseReason,
    DateTime? closedAt,
    DateTime? archivedAt,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final workOrder = await _remoteDataSource.updateWorkOrder(
        workOrderId,
        status: status,
        bayId: bayId,
        authorizedAmount: authorizedAmount,
        promisedDate: promisedDate,
        scheduledAt: scheduledAt,
        pausedAt: pausedAt,
        pauseReason: pauseReason,
        closedAt: closedAt,
        archivedAt: archivedAt,
      );
      return Right(workOrder);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LineItem>> createLineItem(
    String workOrderId, {
    required String description,
    required String billingMode,
    required double price,
    required String status,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final lineItem = await _remoteDataSource.createLineItem(
        workOrderId,
        description: description,
        billingMode: billingMode,
        price: price,
        status: status,
      );
      return Right(lineItem);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LineItem>> updateLineItem(
    String lineItemId, {
    String? description,
    String? billingMode,
    double? price,
    String? status,
    String? holdReason,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final lineItem = await _remoteDataSource.updateLineItem(
        lineItemId,
        description: description,
        billingMode: billingMode,
        price: price,
        status: status,
        holdReason: holdReason,
        startedAt: startedAt,
        completedAt: completedAt,
      );
      return Right(lineItem);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, LaborEntry>> createLaborEntry(
    String workOrderId, {
    required String techId,
    required String lineItemId,
    required DateTime workDate,
    required double hours,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final laborEntry = await _remoteDataSource.createLaborEntry(
        workOrderId,
        techId: techId,
        lineItemId: lineItemId,
        workDate: workDate,
        hours: hours,
      );
      return Right(laborEntry);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<LaborEntry>>> getLaborEntries(String workOrderId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final entries = await _remoteDataSource.getLaborEntries(workOrderId);
      return Right(entries);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
