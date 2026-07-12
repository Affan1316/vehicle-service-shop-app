import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/timeline_event.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomersLoaded extends CustomerState {
  final List<Customer> customers;

  const CustomersLoaded(this.customers);

  @override
  List<Object?> get props => [customers];
}

class CustomerDetailsLoaded extends CustomerState {
  final Customer customer;
  final List<Vehicle> vehicles;
  final List<TimelineEvent> timelineEvents;

  const CustomerDetailsLoaded({
    required this.customer,
    required this.vehicles,
    required this.timelineEvents,
  });

  @override
  List<Object?> get props => [customer, vehicles, timelineEvents];
}

class CustomerOperationSuccess extends CustomerState {
  final Customer customer;
  final String message;

  const CustomerOperationSuccess(this.customer, this.message);

  @override
  List<Object?> get props => [customer, message];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
