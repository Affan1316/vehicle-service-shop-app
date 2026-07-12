import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/timeline_event.dart';
import '../../domain/usecases/create_customer_usecase.dart';
import '../../domain/usecases/get_customer_by_id_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/get_vehicles_by_customer_usecase.dart';
import '../../domain/usecases/update_customer_usecase.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase _getCustomersUseCase;
  final GetCustomerByIdUseCase _getCustomerByIdUseCase;
  final CreateCustomerUseCase _createCustomerUseCase;
  final UpdateCustomerUseCase _updateCustomerUseCase;
  final GetVehiclesByCustomerUseCase _getVehiclesByCustomerUseCase;

  CustomerBloc({
    required GetCustomersUseCase getCustomersUseCase,
    required GetCustomerByIdUseCase getCustomerByIdUseCase,
    required CreateCustomerUseCase createCustomerUseCase,
    required UpdateCustomerUseCase updateCustomerUseCase,
    required GetVehiclesByCustomerUseCase getVehiclesByCustomerUseCase,
  })  : _getCustomersUseCase = getCustomersUseCase,
        _getCustomerByIdUseCase = getCustomerByIdUseCase,
        _createCustomerUseCase = createCustomerUseCase,
        _updateCustomerUseCase = updateCustomerUseCase,
        _getVehiclesByCustomerUseCase = getVehiclesByCustomerUseCase,
        super(CustomerInitial()) {
    on<FetchCustomers>(_onFetchCustomers);
    on<FetchCustomerDetails>(_onFetchCustomerDetails);
    on<CreateCustomer>(_onCreateCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
  }

  Future<void> _onFetchCustomers(
    FetchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await _getCustomersUseCase(limit: event.limit, offset: event.offset);
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(CustomersLoaded(customers)),
    );
  }

  Future<void> _onFetchCustomerDetails(
    FetchCustomerDetails event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());

    final customerResult = await _getCustomerByIdUseCase(event.customerId);
    await customerResult.fold(
      (failure) async => emit(CustomerError(failure.message)),
      (customer) async {
        final vehiclesResult = await _getVehiclesByCustomerUseCase(event.customerId);
        await vehiclesResult.fold(
          (failure) async => emit(CustomerError(failure.message)),
          (vehicles) async {
            // Generate beautiful, realistic timeline events for testing/rendering
            final timeline = [
              TimelineEvent(
                title: 'Invoice paid successfully',
                date: DateTime.now().subtract(const Duration(days: 2)),
                description: 'Paid \$185.00 for seasonal service checklist.',
                amount: '\$185.00',
                type: 'payment',
                status: 'paid',
              ),
              TimelineEvent(
                title: 'Work order completed',
                date: DateTime.now().subtract(const Duration(days: 3)),
                description: 'Brake pads replacement and rotor machining completed.',
                type: 'work_order',
                status: 'completed',
              ),
              TimelineEvent(
                title: 'Quote approved by owner',
                date: DateTime.now().subtract(const Duration(days: 5)),
                description: 'Diagnostics approved: Front pads & rotors replacement.',
                amount: '\$185.00',
                type: 'quote',
                status: 'approved',
              ),
              TimelineEvent(
                title: 'Vehicle checked in',
                date: DateTime.now().subtract(const Duration(days: 5)),
                description: 'Owner checked in Toyota Corolla for front brake noise.',
                type: 'check_in',
                status: 'completed',
              ),
            ];

            emit(CustomerDetailsLoaded(
              customer: customer,
              vehicles: vehicles,
              timelineEvents: timeline,
            ));
          },
        );
      },
    );
  }

  Future<void> _onCreateCustomer(
    CreateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await _createCustomerUseCase(
      name: event.name,
      customerType: event.customerType,
      billingAddress: event.billingAddress,
      taxExempt: event.taxExempt,
    );
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) => emit(CustomerOperationSuccess(customer, 'Customer created successfully')),
    );
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    final result = await _updateCustomerUseCase(
      id: event.id,
      name: event.name,
      customerType: event.customerType,
      billingAddress: event.billingAddress,
      taxExempt: event.taxExempt,
    );
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customer) => emit(CustomerOperationSuccess(customer, 'Customer updated successfully')),
    );
  }
}
