import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vehicle.dart';
import '../repositories/vehicle_repository.dart';

class GetVehiclesUseCase {
  final VehicleRepository _repository;

  GetVehiclesUseCase(this._repository);

  Future<Either<Failure, List<Vehicle>>> call({
    int limit = 50,
    int offset = 0,
  }) async {
    return _repository.getVehicles(limit: limit, offset: offset);
  }
}
