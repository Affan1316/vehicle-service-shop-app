import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_vehicles_usecase.dart';
import '../../domain/usecases/register_vehicle_usecase.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GetVehiclesUseCase _getVehiclesUseCase;
  final RegisterVehicleUseCase _registerVehicleUseCase;

  VehicleBloc({
    required GetVehiclesUseCase getVehiclesUseCase,
    required RegisterVehicleUseCase registerVehicleUseCase,
  })  : _getVehiclesUseCase = getVehiclesUseCase,
        _registerVehicleUseCase = registerVehicleUseCase,
        super(VehicleInitial()) {
    on<FetchVehicles>(_onFetchVehicles);
    on<RegisterVehicleEvent>(_onRegisterVehicle);
  }

  Future<void> _onFetchVehicles(
    FetchVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    final result = await _getVehiclesUseCase(limit: event.limit, offset: event.offset);
    result.fold(
      (failure) => emit(VehicleError(failure.message)),
      (vehicles) => emit(VehiclesLoaded(vehicles)),
    );
  }

  Future<void> _onRegisterVehicle(
    RegisterVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    final result = await _registerVehicleUseCase(
      vin: event.vin,
      customerId: event.customerId,
      make: event.make,
      model: event.model,
      year: event.year,
      currentMileage: event.currentMileage,
    );
    result.fold(
      (failure) => emit(VehicleError(failure.message)),
      (vehicle) => emit(VehicleOperationSuccess(vehicle, 'Vehicle registered successfully')),
    );
  }
}
