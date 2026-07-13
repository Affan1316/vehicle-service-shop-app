import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  VehicleRepositoryImpl(this._remoteDataSource, this._networkInfo);

  @override
  Future<Either<Failure, List<Vehicle>>> getVehicles({
    int limit = 50,
    int offset = 0,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final vehicles = await _remoteDataSource.getVehicles(limit: limit, offset: offset);
      return Right(vehicles);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> getVehicleByVin(String vin) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final vehicle = await _remoteDataSource.getVehicleByVin(vin);
      return Right(vehicle);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Vehicle>>> getVehiclesByCustomer(String customerId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final vehicles = await _remoteDataSource.getVehicles(limit: 100);
      final filtered = vehicles.where((v) => v.customerId == customerId).toList();
      return Right(filtered);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> registerVehicle({
    required String vin,
    required String customerId,
    required String make,
    required String model,
    required int year,
    required int currentMileage,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final vehicle = await _remoteDataSource.registerVehicle(
        vin: vin,
        customerId: customerId,
        make: make,
        model: model,
        year: year,
        currentMileage: currentMileage,
      );
      return Right(vehicle);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> updateVehicle(
    String vin, {
    String? make,
    String? model,
    int? year,
    int? currentMileage,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      final vehicle = await _remoteDataSource.updateVehicle(
        vin,
        make: make,
        model: model,
        year: year,
        currentMileage: currentMileage,
      );
      return Right(vehicle);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVehicle(String vin) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection'));
    }
    try {
      await _remoteDataSource.deleteVehicle(vin);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
