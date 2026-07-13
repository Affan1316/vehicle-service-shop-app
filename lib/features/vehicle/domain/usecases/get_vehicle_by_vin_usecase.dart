import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehicleByVinUseCase {
  final VehicleRepository _repository;

  GetVehicleByVinUseCase(this._repository);

  Future<Either<Failure, Vehicle>> call(String vin) async {
    return _repository.getVehicleByVin(vin);
  }
}
