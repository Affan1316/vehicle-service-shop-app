import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_labor_entry_usecase.dart';
import '../../domain/usecases/get_labor_entries_usecase.dart';
import 'labor_event.dart';
import 'labor_state.dart';

class LaborBloc extends Bloc<LaborEvent, LaborState> {
  final CreateLaborEntryUseCase createLaborEntryUseCase;
  final GetLaborEntriesUseCase getLaborEntriesUseCase;

  LaborBloc({
    required this.createLaborEntryUseCase,
    required this.getLaborEntriesUseCase,
  }) : super(LaborInitial()) {
    on<FetchLaborEntries>(_onFetchLaborEntries);
    on<AddLaborEntry>(_onAddLaborEntry);
  }

  Future<void> _onFetchLaborEntries(FetchLaborEntries event, Emitter<LaborState> emit) async {
    emit(LaborLoading());
    final result = await getLaborEntriesUseCase(event.workOrderId);
    result.fold(
      (failure) => emit(LaborError(failure.message)),
      (entries) => emit(LaborEntriesLoaded(entries)),
    );
  }

  Future<void> _onAddLaborEntry(AddLaborEntry event, Emitter<LaborState> emit) async {
    emit(LaborLoading());
    final result = await createLaborEntryUseCase(
      event.workOrderId,
      techId: event.techId,
      lineItemId: event.lineItemId,
      workDate: event.workDate,
      hours: event.hours,
    );
    result.fold(
      (failure) => emit(LaborError(failure.message)),
      (entry) {
        emit(LaborOperationSuccess(entry));
        add(FetchLaborEntries(event.workOrderId));
      },
    );
  }
}
