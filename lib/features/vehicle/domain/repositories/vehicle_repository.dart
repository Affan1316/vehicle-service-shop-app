import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle.dart';

abstract class VehicleRepository {
  Future<Either<Failure, List<Vehicle>>> getVehicles({
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, Vehicle>> getVehicleByVin(String vin);

  Future<Either<Failure, List<Vehicle>>> getVehiclesByCustomer(String customerId);

  Future<Either<Failure, Vehicle>> registerVehicle({
    required String vin,
    required String customerId,
    required String make,
    required String model,
    required int year,
    required int currentMileage,
  });

  Future<Either<Failure, Vehicle>> updateVehicle(
    String vin, {
    String? make,
    String? model,
    int? year,
    int? currentMileage,
  });

  Future<Either<Failure, void>> deleteVehicle(String vin);
}
