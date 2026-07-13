import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_vehicles_usecase.dart';
import 'vehicle_list_event.dart';
import 'vehicle_list_state.dart';

class VehicleListBloc extends Bloc<VehicleListEvent, VehicleListState> {
  final GetVehiclesUseCase _getVehiclesUseCase;

  VehicleListBloc({
    required GetVehiclesUseCase getVehiclesUseCase,
  })  : _getVehiclesUseCase = getVehiclesUseCase,
        super(VehicleListInitial()) {
    on<FetchVehiclesList>(_onFetchVehiclesList);
  }

  Future<void> _onFetchVehiclesList(
    FetchVehiclesList event,
    Emitter<VehicleListState> emit,
  ) async {
    emit(VehicleListLoading());
    final result = await _getVehiclesUseCase(limit: event.limit, offset: event.offset);
    result.fold(
      (failure) => emit(VehicleListError(failure.message)),
      (vehicles) => emit(VehicleListLoaded(vehicles)),
    );
  }
}
