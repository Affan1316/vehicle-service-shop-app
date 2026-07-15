import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/technician.dart';

abstract class TechnicianRepository {
  Future<Either<Failure, List<Technician>>> getTechnicians({int limit = 50, int offset = 0});
}
