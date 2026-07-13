import 'package:equatable/equatable.dart';
import '../../../../customer/domain/entities/customer.dart';
import '../../../domain/entities/vehicle.dart';

abstract class VehicleDetailState extends Equatable {
  const VehicleDetailState();

  @override
  List<Object?> get props => [];
}

class VehicleDetailInitial extends VehicleDetailState {}

class VehicleDetailLoading extends VehicleDetailState {}

class VehicleDetailLoaded extends VehicleDetailState {
  final Vehicle vehicle;
  final Customer customer;

  const VehicleDetailLoaded({required this.vehicle, required this.customer});

  @override
  List<Object?> get props => [vehicle, customer];
}

class VehicleDetailError extends VehicleDetailState {
  final String message;

  const VehicleDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class VehicleDeleteSuccess extends VehicleDetailState {}
