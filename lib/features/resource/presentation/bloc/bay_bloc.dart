import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_bays_usecase.dart';
import '../../domain/usecases/update_bay_usecase.dart';
import 'bay_event.dart';
import 'bay_state.dart';

class BayBloc extends Bloc<BayEvent, BayState> {
  final GetBaysUseCase getBaysUseCase;
  final UpdateBayUseCase updateBayUseCase;

  BayBloc({
    required this.getBaysUseCase,
    required this.updateBayUseCase,
  }) : super(BayInitial()) {
    on<FetchBays>(_onFetchBays);
    on<UpdateBayAllocation>(_onUpdateBayAllocation);
  }

  Future<void> _onFetchBays(FetchBays event, Emitter<BayState> emit) async {
    emit(BayLoading());
    final result = await getBaysUseCase(limit: event.limit, offset: event.offset);
    result.fold(
      (failure) => emit(BayError(failure.message)),
      (bays) => emit(BaysLoaded(bays)),
    );
  }

  Future<void> _onUpdateBayAllocation(UpdateBayAllocation event, Emitter<BayState> emit) async {
    emit(BayLoading());
    final result = await updateBayUseCase(
      event.bayId,
      status: event.status,
      currentWorkOrderId: event.currentWorkOrderId,
      heldUntil: event.heldUntil,
      clearWorkOrder: event.clearWorkOrder,
      clearHeldUntil: event.clearHeldUntil,
    );
    result.fold(
      (failure) => emit(BayError(failure.message)),
      (bay) => emit(BayOperationSuccess(bay)),
    );
  }
}
