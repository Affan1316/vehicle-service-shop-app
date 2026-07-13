import 'package:equatable/equatable.dart';

abstract class VehicleListEvent extends Equatable {
  const VehicleListEvent();

  @override
  List<Object?> get props => [];
}

class FetchVehiclesList extends VehicleListEvent {
  final int limit;
  final int offset;

  const FetchVehiclesList({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}
