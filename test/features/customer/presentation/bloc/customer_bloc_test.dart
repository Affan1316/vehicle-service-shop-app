import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/core/error/failures.dart';
import 'package:wheels_doc/features/customer/domain/entities/customer.dart';
import 'package:wheels_doc/features/vehicle/domain/entities/vehicle.dart';
import 'package:wheels_doc/features/customer/domain/usecases/create_customer_usecase.dart';
import 'package:wheels_doc/features/customer/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:wheels_doc/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:wheels_doc/features/vehicle/domain/usecases/get_vehicles_by_customer_usecase.dart';
import 'package:wheels_doc/features/customer/domain/usecases/update_customer_usecase.dart';
import 'package:wheels_doc/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:wheels_doc/features/customer/presentation/bloc/customer_event.dart';
import 'package:wheels_doc/features/customer/presentation/bloc/customer_state.dart';

class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}

class MockGetCustomerByIdUseCase extends Mock implements GetCustomerByIdUseCase {}

class MockCreateCustomerUseCase extends Mock implements CreateCustomerUseCase {}

class MockUpdateCustomerUseCase extends Mock implements UpdateCustomerUseCase {}

class MockGetVehiclesByCustomerUseCase extends Mock implements GetVehiclesByCustomerUseCase {}

void main() {
  late CustomerBloc customerBloc;
  late MockGetCustomersUseCase mockGetCustomersUseCase;
  late MockGetCustomerByIdUseCase mockGetCustomerByIdUseCase;
  late MockCreateCustomerUseCase mockCreateCustomerUseCase;
  late MockUpdateCustomerUseCase mockUpdateCustomerUseCase;
  late MockGetVehiclesByCustomerUseCase mockGetVehiclesByCustomerUseCase;

  final tCustomer = Customer(
    id: 'cust-123',
    name: 'John Doe',
    customerType: 'individual',
    billingAddress: '123 Main St',
    taxExempt: false,
  );

  final tVehicle = Vehicle(
    vin: '1HGCM82633A123456',
    customerId: 'cust-123',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
    currentMileage: 50000,
  );

  setUp(() {
    mockGetCustomersUseCase = MockGetCustomersUseCase();
    mockGetCustomerByIdUseCase = MockGetCustomerByIdUseCase();
    mockCreateCustomerUseCase = MockCreateCustomerUseCase();
    mockUpdateCustomerUseCase = MockUpdateCustomerUseCase();
    mockGetVehiclesByCustomerUseCase = MockGetVehiclesByCustomerUseCase();

    customerBloc = CustomerBloc(
      getCustomersUseCase: mockGetCustomersUseCase,
      getCustomerByIdUseCase: mockGetCustomerByIdUseCase,
      createCustomerUseCase: mockCreateCustomerUseCase,
      updateCustomerUseCase: mockUpdateCustomerUseCase,
      getVehiclesByCustomerUseCase: mockGetVehiclesByCustomerUseCase,
    );
  });

  tearDown(() {
    customerBloc.close();
  });

  group('FetchCustomers', () {
    blocTest<CustomerBloc, CustomerState>(
      'should emit [CustomerLoading, CustomersLoaded] when fetching customers successfully',
      build: () {
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tCustomer]));
        return customerBloc;
      },
      act: (bloc) => bloc.add(const FetchCustomers()),
      expect: () => [
        CustomerLoading(),
        CustomersLoaded([tCustomer]),
      ],
    );

    blocTest<CustomerBloc, CustomerState>(
      'should emit [CustomerLoading, CustomerError] when fetching customers fails',
      build: () {
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => const Left(ServerFailure('Fetch Failed')));
        return customerBloc;
      },
      act: (bloc) => bloc.add(const FetchCustomers()),
      expect: () => [
        CustomerLoading(),
        const CustomerError('Fetch Failed'),
      ],
    );
  });

  group('CreateCustomer', () {
    blocTest<CustomerBloc, CustomerState>(
      'should emit [CustomerLoading, CustomerOperationSuccess] when customer is created successfully',
      build: () {
        when(() => mockCreateCustomerUseCase(
              name: any(named: 'name'),
              customerType: any(named: 'customerType'),
              billingAddress: any(named: 'billingAddress'),
              taxExempt: any(named: 'taxExempt'),
            )).thenAnswer((_) async => Right(tCustomer));
        return customerBloc;
      },
      act: (bloc) => bloc.add(const CreateCustomer(
        name: 'John Doe',
        customerType: 'individual',
        billingAddress: '123 Main St',
        taxExempt: false,
      )),
      expect: () => [
        CustomerLoading(),
        CustomerOperationSuccess(tCustomer, 'Customer created successfully'),
      ],
    );
  });
}
