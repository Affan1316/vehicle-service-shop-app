import 'package:equatable/equatable.dart';

abstract class LaborEvent extends Equatable {
  const LaborEvent();

  @override
  List<Object?> get props => [];
}

class FetchLaborEntries extends LaborEvent {
  final String workOrderId;

  const FetchLaborEntries(this.workOrderId);

  @override
  List<Object?> get props => [workOrderId];
}

class AddLaborEntry extends LaborEvent {
  final String workOrderId;
  final String techId;
  final String lineItemId;
  final DateTime workDate;
  final double hours;

  const AddLaborEntry({
    required this.workOrderId,
    required this.techId,
    required this.lineItemId,
    required this.workDate,
    required this.hours,
  });

  @override
  List<Object?> get props => [workOrderId, techId, lineItemId, workDate, hours];
}
