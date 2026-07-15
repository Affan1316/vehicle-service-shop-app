import 'package:equatable/equatable.dart';

class Bay extends Equatable {
  final String bayId;
  final String status; // available, held, confirmed, occupied, cleaning, maintenance
  final String bayType;
  final String? currentWorkOrderId;
  final DateTime? heldUntil;

  const Bay({
    required this.bayId,
    required this.status,
    required this.bayType,
    this.currentWorkOrderId,
    this.heldUntil,
  });

  @override
  List<Object?> get props => [
        bayId,
        status,
        bayType,
        currentWorkOrderId,
        heldUntil,
      ];
}
