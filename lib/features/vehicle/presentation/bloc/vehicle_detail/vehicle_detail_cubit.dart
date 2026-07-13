import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../customer/domain/usecases/get_customer_by_id_usecase.dart';
import '../../../domain/usecases/delete_vehicle_usecase.dart';
import '../../../domain/usecases/get_vehicle_by_vin_usecase.dart';
import '../../../domain/usecases/update_vehicle_usecase.dart';
import 'vehicle_detail_state.dart';

class VehicleDetailCubit extends Cubit<VehicleDetailState> {
  final GetVehicleByVinUseCase _getVehicleByVinUseCase;
  final GetCustomerByIdUseCase _getCustomerByIdUseCase;
  final UpdateVehicleUseCase _updateVehicleUseCase;
  final DeleteVehicleUseCase _deleteVehicleUseCase;

  VehicleDetailCubit({
    required GetVehicleByVinUseCase getVehicleByVinUseCase,
    required GetCustomerByIdUseCase getCustomerByIdUseCase,
    required UpdateVehicleUseCase updateVehicleUseCase,
    required DeleteVehicleUseCase deleteVehicleUseCase,
  })  : _getVehicleByVinUseCase = getVehicleByVinUseCase,
        _getCustomerByIdUseCase = getCustomerByIdUseCase,
        _updateVehicleUseCase = updateVehicleUseCase,
        _deleteVehicleUseCase = deleteVehicleUseCase,
        super(VehicleDetailInitial());

  Future<void> loadVehicle(String vin) async {
    emit(VehicleDetailLoading());
    final vehicleResult = await _getVehicleByVinUseCase(vin);
    await vehicleResult.fold(
      (failure) async => emit(VehicleDetailError(failure.message)),
      (vehicle) async {
        final customerResult = await _getCustomerByIdUseCase(vehicle.customerId);
        customerResult.fold(
          (failure) => emit(VehicleDetailError(failure.message)),
          (customer) => emit(VehicleDetailLoaded(vehicle: vehicle, customer: customer)),
        );
      },
    );
  }

  Future<void> updateVehicle(
    String vin, {
    String? make,
    String? model,
    int? year,
    int? currentMileage,
  }) async {
    // Save reference to previous states if we want to restore on failure, or just show loading
    final vehicleResult = await _updateVehicleUseCase(
      vin,
      make: make,
      model: model,
      year: year,
      currentMileage: currentMileage,
    );
    await vehicleResult.fold(
      (failure) async => emit(VehicleDetailError(failure.message)),
      (updatedVehicle) async {
        // Reload details with owner customer
        final customerResult = await _getCustomerByIdUseCase(updatedVehicle.customerId);
        customerResult.fold(
          (failure) => emit(VehicleDetailError(failure.message)),
          (customer) => emit(VehicleDetailLoaded(vehicle: updatedVehicle, customer: customer)),
        );
      },
    );
  }

  Future<void> deleteVehicle(String vin) async {
    emit(VehicleDetailLoading());
    final result = await _deleteVehicleUseCase(vin);
    result.fold(
      (failure) => emit(VehicleDetailError(failure.message)),
      (_) => emit(VehicleDeleteSuccess()),
    );
  }
}
