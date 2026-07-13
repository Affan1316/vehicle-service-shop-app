import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/visit.dart';

abstract class VisitRepository {
  Future<Either<Failure, List<Visit>>> getVisits({int limit = 50, int offset = 0});
  
  Future<Either<Failure, Visit>> createVisit({
    required String vehicleId,
    required String customerId,
    String? appointmentId,
  });

  Future<Either<Failure, Visit>> updateVisit(
    String visitId, {
    String? status,
    DateTime? checkedOutAt,
  });
}
