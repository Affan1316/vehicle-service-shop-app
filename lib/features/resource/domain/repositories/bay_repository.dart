import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bay.dart';

abstract class BayRepository {
  Future<Either<Failure, List<Bay>>> getBays({int limit = 50, int offset = 0});
  Future<Either<Failure, Bay>> updateBay(
    String bayId, {
    String? status,
    String? bayType,
    String? currentWorkOrderId,
    DateTime? heldUntil,
    bool clearWorkOrder = false,
    bool clearHeldUntil = false,
  });
}
