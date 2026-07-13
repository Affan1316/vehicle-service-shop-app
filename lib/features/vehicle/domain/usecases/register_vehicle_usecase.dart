import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class RegisterVehicleUseCase {
  final VehicleRepository _repository;

  RegisterVehicleUseCase(this._repository);

  Future<Either<Failure, Vehicle>> call({
    required String vin,
    required String customerId,
    required String make,
    required String model,
    required int year,
    required int currentMileage,
  }) async {
    return _repository.registerVehicle(
      vin: vin,
      customerId: customerId,
      make: make,
      model: model,
      year: year,
      currentMileage: currentMileage,
    );
  }
}
