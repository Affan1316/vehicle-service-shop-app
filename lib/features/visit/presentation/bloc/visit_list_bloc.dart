import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/domain/usecases/get_customers_usecase.dart';
import '../../../vehicle/domain/usecases/get_vehicles_usecase.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/create_visit_usecase.dart';
import '../../domain/usecases/get_visits_usecase.dart';
import '../../domain/usecases/update_visit_usecase.dart';
import 'visit_list_event.dart';
import 'visit_list_state.dart';

class VisitListBloc extends Bloc<VisitListEvent, VisitListState> {
  final GetVisitsUseCase _getVisitsUseCase;
  final CreateVisitUseCase _createVisitUseCase;
  final UpdateVisitUseCase _updateVisitUseCase;
  final GetCustomersUseCase _getCustomersUseCase;
  final GetVehiclesUseCase _getVehiclesUseCase;

  VisitListBloc({
    required GetVisitsUseCase getVisitsUseCase,
    required CreateVisitUseCase createVisitUseCase,
    required UpdateVisitUseCase updateVisitUseCase,
    required GetCustomersUseCase getCustomersUseCase,
    required GetVehiclesUseCase getVehiclesUseCase,
  })  : _getVisitsUseCase = getVisitsUseCase,
        _createVisitUseCase = createVisitUseCase,
        _updateVisitUseCase = updateVisitUseCase,
        _getCustomersUseCase = getCustomersUseCase,
        _getVehiclesUseCase = getVehiclesUseCase,
        super(VisitListInitial()) {
    on<FetchVisitsList>(_onFetchVisitsList);
    on<CreateVisitEvent>(_onCreateVisit);
    on<UpdateVisitStatusEvent>(_onUpdateVisitStatus);
  }

  Future<void> _onFetchVisitsList(
    FetchVisitsList event,
    Emitter<VisitListState> emit,
  ) async {
    emit(VisitListLoading());
    final visitsResult = await _getVisitsUseCase(limit: event.limit, offset: event.offset);
    final customersResult = await _getCustomersUseCase(limit: 100);
    final vehiclesResult = await _getVehiclesUseCase(limit: 100);

    visitsResult.fold(
      (failure) => emit(VisitListError(failure.message)),
      (visits) {
        final customers = customersResult.getOrElse(() => []);
        final vehicles = vehiclesResult.getOrElse(() => []);

        final customerMap = {for (var c in customers) c.id: c.name};
        final vehicleMap = {for (var v in vehicles) v.vin: '${v.year} ${v.make} ${v.model}'};

        final enrichedVisits = visits.map((visit) {
          final customerName = customerMap[visit.customerId] ?? 'Unknown Customer';
          final vehicleName = vehicleMap[visit.vehicleId] ?? 'Unknown Vehicle';
          return Visit(
            visitId: visit.visitId,
            vehicleId: visit.vehicleId,
            customerId: visit.customerId,
            appointmentId: visit.appointmentId,
            checkedInAt: visit.checkedInAt,
            checkedOutAt: visit.checkedOutAt,
            status: visit.status,
            isActive: visit.isActive,
            customerName: customerName,
            vehicleName: vehicleName,
          );
        }).toList();

        emit(VisitListLoaded(enrichedVisits));
      },
    );
  }

  Future<void> _onCreateVisit(
    CreateVisitEvent event,
    Emitter<VisitListState> emit,
  ) async {
    emit(VisitListLoading());
    final result = await _createVisitUseCase(
      vehicleId: event.vehicleId,
      customerId: event.customerId,
      appointmentId: event.appointmentId,
    );
    result.fold(
      (failure) => emit(VisitListError(failure.message)),
      (_) {
        emit(VisitOperationSuccess());
        add(const FetchVisitsList());
      },
    );
  }

  Future<void> _onUpdateVisitStatus(
    UpdateVisitStatusEvent event,
    Emitter<VisitListState> emit,
  ) async {
    emit(VisitListLoading());
    final result = await _updateVisitUseCase(
      event.visitId,
      status: event.status,
      checkedOutAt: event.checkedOutAt,
    );
    result.fold(
      (failure) => emit(VisitListError(failure.message)),
      (_) {
        emit(VisitOperationSuccess());
        add(const FetchVisitsList());
      },
    );
  }
}
