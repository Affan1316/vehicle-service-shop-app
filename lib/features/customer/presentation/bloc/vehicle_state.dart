import 'package:equatable/equatable.dart';
import '../../../vehicle/domain/entities/vehicle.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  const VehiclesLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleOperationSuccess extends VehicleState {
  final Vehicle vehicle;
  final String message;

  const VehicleOperationSuccess(this.vehicle, this.message);

  @override
  List<Object?> get props => [vehicle, message];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}
