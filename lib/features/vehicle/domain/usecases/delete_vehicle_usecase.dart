import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/vehicle_repository.dart';

class DeleteVehicleUseCase {
  final VehicleRepository _repository;

  DeleteVehicleUseCase(this._repository);

  Future<Either<Failure, void>> call(String vin) async {
    return _repository.deleteVehicle(vin);
  }
}
