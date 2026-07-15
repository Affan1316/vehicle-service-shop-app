import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/bay.dart';
import '../repositories/bay_repository.dart';

class UpdateBayUseCase {
  final BayRepository _repository;

  UpdateBayUseCase(this._repository);

  Future<Either<Failure, Bay>> call(
    String bayId, {
    String? status,
    String? bayType,
    String? currentWorkOrderId,
    DateTime? heldUntil,
    bool clearWorkOrder = false,
    bool clearHeldUntil = false,
  }) async {
    return _repository.updateBay(
      bayId,
      status: status,
      bayType: bayType,
      currentWorkOrderId: currentWorkOrderId,
      heldUntil: heldUntil,
      clearWorkOrder: clearWorkOrder,
      clearHeldUntil: clearHeldUntil,
    );
  }
}
