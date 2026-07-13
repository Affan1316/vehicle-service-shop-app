import 'package:equatable/equatable.dart';
import '../../../domain/entities/vehicle.dart';

abstract class VehicleListState extends Equatable {
  const VehicleListState();

  @override
  List<Object?> get props => [];
}

class VehicleListInitial extends VehicleListState {}

class VehicleListLoading extends VehicleListState {}

class VehicleListLoaded extends VehicleListState {
  final List<Vehicle> vehicles;

  const VehicleListLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleListError extends VehicleListState {
  final String message;

  const VehicleListError(this.message);

  @override
  List<Object?> get props => [message];
}
