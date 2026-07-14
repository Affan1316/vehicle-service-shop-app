import 'package:equatable/equatable.dart';
import '../../domain/entities/work_order.dart';

abstract class JobState extends Equatable {
  const JobState();

  @override
  List<Object?> get props => [];
}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class WorkOrdersLoaded extends JobState {
  final List<WorkOrder> workOrders;
  final Map<String, String> customerNames;
  final Map<String, String> vehicleNames;

  const WorkOrdersLoaded({
    required this.workOrders,
    required this.customerNames,
    required this.vehicleNames,
  });

  @override
  List<Object?> get props => [workOrders, customerNames, vehicleNames];
}

class WorkOrderOperationSuccess extends JobState {
  final String message;

  const WorkOrderOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class JobError extends JobState {
  final String message;

  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}
