import 'package:equatable/equatable.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class FetchVehicles extends VehicleEvent {
  final int limit;
  final int offset;

  const FetchVehicles({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}

class RegisterVehicleEvent extends VehicleEvent {
  final String vin;
  final String customerId;
  final String make;
  final String model;
  final int year;
  final int currentMileage;

  const RegisterVehicleEvent({
    required this.vin,
    required this.customerId,
    required this.make,
    required this.model,
    required this.year,
    required this.currentMileage,
  });

  @override
  List<Object?> get props => [vin, customerId, make, model, year, currentMileage];
}
