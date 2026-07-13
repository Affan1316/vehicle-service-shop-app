import 'package:equatable/equatable.dart';

abstract class VisitListEvent extends Equatable {
  const VisitListEvent();

  @override
  List<Object?> get props => [];
}

class FetchVisitsList extends VisitListEvent {
  final int limit;
  final int offset;

  const FetchVisitsList({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}

class CreateVisitEvent extends VisitListEvent {
  final String vehicleId;
  final String customerId;
  final String? appointmentId;

  const CreateVisitEvent({
    required this.vehicleId,
    required this.customerId,
    this.appointmentId,
  });

  @override
  List<Object?> get props => [vehicleId, customerId, appointmentId];
}

class UpdateVisitStatusEvent extends VisitListEvent {
  final String visitId;
  final String? status;
  final DateTime? checkedOutAt;

  const UpdateVisitStatusEvent({
    required this.visitId,
    this.status,
    this.checkedOutAt,
  });

  @override
  List<Object?> get props => [visitId, status, checkedOutAt];
}
