import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class UpdateVehicleUseCase {
  final VehicleRepository _repository;

  UpdateVehicleUseCase(this._repository);

  Future<Either<Failure, Vehicle>> call(
    String vin, {
    String? make,
    String? model,
    int? year,
    int? currentMileage,
  }) async {
    return _repository.updateVehicle(
      vin,
      make: make,
      model: model,
      year: year,
      currentMileage: currentMileage,
    );
  }
}
