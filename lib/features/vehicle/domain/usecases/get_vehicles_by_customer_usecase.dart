import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehiclesByCustomerUseCase {
  final VehicleRepository _repository;

  GetVehiclesByCustomerUseCase(this._repository);

  Future<Either<Failure, List<Vehicle>>> call(String customerId) async {
    return _repository.getVehiclesByCustomer(customerId);
  }
}
