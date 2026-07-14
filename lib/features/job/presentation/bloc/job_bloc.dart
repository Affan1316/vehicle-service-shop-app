import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/domain/usecases/get_customers_usecase.dart';
import '../../../vehicle/domain/usecases/get_vehicles_usecase.dart';
import '../../domain/usecases/create_line_item.dart';
import '../../domain/usecases/create_work_order.dart';
import '../../domain/usecases/get_work_orders.dart';
import '../../domain/usecases/update_line_item.dart';
import '../../domain/usecases/update_work_order.dart';
import 'job_event.dart';
import 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {
  final GetWorkOrdersUseCase _getWorkOrdersUseCase;
  final CreateWorkOrderUseCase _createWorkOrderUseCase;
  final UpdateWorkOrderUseCase _updateWorkOrderUseCase;
  final CreateLineItemUseCase _createLineItemUseCase;
  final UpdateLineItemUseCase _updateLineItemUseCase;
  final GetCustomersUseCase _getCustomersUseCase;
  final GetVehiclesUseCase _getVehiclesUseCase;

  JobBloc({
    required GetWorkOrdersUseCase getWorkOrdersUseCase,
    required CreateWorkOrderUseCase createWorkOrderUseCase,
    required UpdateWorkOrderUseCase updateWorkOrderUseCase,
    required CreateLineItemUseCase createLineItemUseCase,
    required UpdateLineItemUseCase updateLineItemUseCase,
    required GetCustomersUseCase getCustomersUseCase,
    required GetVehiclesUseCase getVehiclesUseCase,
  })  : _getWorkOrdersUseCase = getWorkOrdersUseCase,
        _createWorkOrderUseCase = createWorkOrderUseCase,
        _updateWorkOrderUseCase = updateWorkOrderUseCase,
        _createLineItemUseCase = createLineItemUseCase,
        _updateLineItemUseCase = updateLineItemUseCase,
        _getCustomersUseCase = getCustomersUseCase,
        _getVehiclesUseCase = getVehiclesUseCase,
        super(JobInitial()) {
    on<FetchWorkOrders>(_onFetchWorkOrders);
    on<CreateWorkOrderEvent>(_onCreateWorkOrder);
    on<UpdateWorkOrderEvent>(_onUpdateWorkOrder);
    on<AddLineItemEvent>(_onAddLineItem);
    on<UpdateLineItemProgressEvent>(_onUpdateLineItemProgress);
  }

  Future<void> _onFetchWorkOrders(
    FetchWorkOrders event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    final woResult = await _getWorkOrdersUseCase();
    final customersResult = await _getCustomersUseCase(limit: 500);
    final vehiclesResult = await _getVehiclesUseCase(limit: 500);

    woResult.fold(
      (failure) => emit(JobError(failure.message)),
      (workOrders) {
        final customers = customersResult.getOrElse(() => []);
        final vehicles = vehiclesResult.getOrElse(() => []);

        final customerMap = {for (var c in customers) c.id: c.name};
        final vehicleMap = {for (var v in vehicles) v.vin: '${v.year} ${v.make} ${v.model}'};

        emit(WorkOrdersLoaded(
          workOrders: workOrders,
          customerNames: customerMap,
          vehicleNames: vehicleMap,
        ));
      },
    );
  }

  Future<void> _onCreateWorkOrder(
    CreateWorkOrderEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    final result = await _createWorkOrderUseCase(
      quoteId: event.quoteId,
      vehicleId: event.vehicleId,
      customerId: event.customerId,
      authorizedAmount: event.authorizedAmount,
      visitId: event.visitId,
      promisedDate: event.promisedDate,
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (_) {
        emit(const WorkOrderOperationSuccess('Work order generated successfully!'));
        add(const FetchWorkOrders());
      },
    );
  }

  Future<void> _onUpdateWorkOrder(
    UpdateWorkOrderEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    final result = await _updateWorkOrderUseCase(
      event.workOrderId,
      status: event.status,
      bayId: event.bayId,
      authorizedAmount: event.authorizedAmount,
      promisedDate: event.promisedDate,
      scheduledAt: event.scheduledAt,
      pausedAt: event.pausedAt,
      pauseReason: event.pauseReason,
      closedAt: event.closedAt,
      archivedAt: event.archivedAt,
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (_) {
        emit(const WorkOrderOperationSuccess('Work order updated successfully!'));
        add(const FetchWorkOrders());
      },
    );
  }

  Future<void> _onAddLineItem(
    AddLineItemEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    final result = await _createLineItemUseCase(
      event.workOrderId,
      description: event.description,
      billingMode: event.billingMode,
      price: event.price,
      status: event.status,
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (_) {
        emit(const WorkOrderOperationSuccess('Task line item added successfully!'));
        add(const FetchWorkOrders());
      },
    );
  }

  Future<void> _onUpdateLineItemProgress(
    UpdateLineItemProgressEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    final result = await _updateLineItemUseCase(
      event.lineItemId,
      status: event.status,
      holdReason: event.holdReason,
      startedAt: event.startedAt,
      completedAt: event.completedAt,
    );
    result.fold(
      (failure) => emit(JobError(failure.message)),
      (_) {
        emit(const WorkOrderOperationSuccess('Task progress updated successfully!'));
        add(const FetchWorkOrders());
      },
    );
  }
}
