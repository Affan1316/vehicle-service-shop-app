import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit.dart';
import '../repositories/visit_repository.dart';

class CreateVisitUseCase {
  final VisitRepository _repository;

  CreateVisitUseCase(this._repository);

  Future<Either<Failure, Visit>> call({
    required String vehicleId,
    required String customerId,
    String? appointmentId,
  }) async {
    return _repository.createVisit(
      vehicleId: vehicleId,
      customerId: customerId,
      appointmentId: appointmentId,
    );
  }
}
