import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/technician.dart';
import '../repositories/technician_repository.dart';

class GetTechniciansUseCase {
  final TechnicianRepository _repository;

  GetTechniciansUseCase(this._repository);

  Future<Either<Failure, List<Technician>>> call({int limit = 50, int offset = 0}) async {
    return _repository.getTechnicians(limit: limit, offset: offset);
  }
}
