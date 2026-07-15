import 'package:equatable/equatable.dart';

abstract class BayEvent extends Equatable {
  const BayEvent();

  @override
  List<Object?> get props => [];
}

class FetchBays extends BayEvent {
  final int limit;
  final int offset;

  const FetchBays({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}

class UpdateBayAllocation extends BayEvent {
  final String bayId;
  final String? status;
  final String? currentWorkOrderId;
  final DateTime? heldUntil;
  final bool clearWorkOrder;
  final bool clearHeldUntil;

  const UpdateBayAllocation({
    required this.bayId,
    this.status,
    this.currentWorkOrderId,
    this.heldUntil,
    this.clearWorkOrder = false,
    this.clearHeldUntil = false,
  });

  @override
  List<Object?> get props => [
        bayId,
        status,
        currentWorkOrderId,
        heldUntil,
        clearWorkOrder,
        clearHeldUntil,
      ];
}
