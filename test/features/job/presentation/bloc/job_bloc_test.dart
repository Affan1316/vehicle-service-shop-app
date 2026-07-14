import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/core/error/failures.dart';
import 'package:wheels_doc/features/customer/domain/entities/customer.dart';
import 'package:wheels_doc/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:wheels_doc/features/vehicle/domain/entities/vehicle.dart';
import 'package:wheels_doc/features/vehicle/domain/usecases/get_vehicles_usecase.dart';
import 'package:wheels_doc/features/job/domain/entities/work_order.dart';
import 'package:wheels_doc/features/job/domain/entities/line_item.dart';
import 'package:wheels_doc/features/job/domain/usecases/create_line_item.dart';
import 'package:wheels_doc/features/job/domain/usecases/create_work_order.dart';
import 'package:wheels_doc/features/job/domain/usecases/get_work_orders.dart';
import 'package:wheels_doc/features/job/domain/usecases/update_line_item.dart';
import 'package:wheels_doc/features/job/domain/usecases/update_work_order.dart';
import 'package:wheels_doc/features/job/presentation/bloc/job_bloc.dart';
import 'package:wheels_doc/features/job/presentation/bloc/job_event.dart';
import 'package:wheels_doc/features/job/presentation/bloc/job_state.dart';

class MockGetWorkOrdersUseCase extends Mock implements GetWorkOrdersUseCase {}
class MockCreateWorkOrderUseCase extends Mock implements CreateWorkOrderUseCase {}
class MockUpdateWorkOrderUseCase extends Mock implements UpdateWorkOrderUseCase {}
class MockCreateLineItemUseCase extends Mock implements CreateLineItemUseCase {}
class MockUpdateLineItemUseCase extends Mock implements UpdateLineItemUseCase {}
class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}
class MockGetVehiclesUseCase extends Mock implements GetVehiclesUseCase {}

void main() {
  late JobBloc jobBloc;
  late MockGetWorkOrdersUseCase mockGetWorkOrdersUseCase;
  late MockCreateWorkOrderUseCase mockCreateWorkOrderUseCase;
  late MockUpdateWorkOrderUseCase mockUpdateWorkOrderUseCase;
  late MockCreateLineItemUseCase mockCreateLineItemUseCase;
  late MockUpdateLineItemUseCase mockUpdateLineItemUseCase;
  late MockGetCustomersUseCase mockGetCustomersUseCase;
  late MockGetVehiclesUseCase mockGetVehiclesUseCase;

  final tWorkOrder = WorkOrder(
    workOrderId: 'wo-123',
    quoteId: 'quote-123',
    vehicleId: 'vin-123',
    customerId: 'cust-123',
    status: 'created',
    authorizedAmount: 500.0,
    createdAt: DateTime(2026, 7, 10, 10, 0),
    totalCost: 0.0,
    lineItems: const [],
  );

  final tLineItem = LineItem(
    lineItemId: 'li-123',
    workOrderId: 'wo-123',
    description: 'Front brake service',
    billingMode: 'flat_rate',
    price: 150.0,
    status: 'not_started',
  );

  final tCustomer = Customer(
    id: 'cust-123',
    name: 'Jane Smith',
    customerType: 'individual',
    billingAddress: '456 Oak St',
    taxExempt: false,
  );

  final tVehicle = Vehicle(
    vin: 'vin-123',
    customerId: 'cust-123',
    make: 'Ford',
    model: 'F-150',
    year: 2021,
    currentMileage: 30000,
  );

  setUp(() {
    mockGetWorkOrdersUseCase = MockGetWorkOrdersUseCase();
    mockCreateWorkOrderUseCase = MockCreateWorkOrderUseCase();
    mockUpdateWorkOrderUseCase = MockUpdateWorkOrderUseCase();
    mockCreateLineItemUseCase = MockCreateLineItemUseCase();
    mockUpdateLineItemUseCase = MockUpdateLineItemUseCase();
    mockGetCustomersUseCase = MockGetCustomersUseCase();
    mockGetVehiclesUseCase = MockGetVehiclesUseCase();

    jobBloc = JobBloc(
      getWorkOrdersUseCase: mockGetWorkOrdersUseCase,
      createWorkOrderUseCase: mockCreateWorkOrderUseCase,
      updateWorkOrderUseCase: mockUpdateWorkOrderUseCase,
      createLineItemUseCase: mockCreateLineItemUseCase,
      updateLineItemUseCase: mockUpdateLineItemUseCase,
      getCustomersUseCase: mockGetCustomersUseCase,
      getVehiclesUseCase: mockGetVehiclesUseCase,
    );
  });

  tearDown(() {
    jobBloc.close();
  });

  group('FetchWorkOrders', () {
    blocTest<JobBloc, JobState>(
      'should emit [JobLoading, WorkOrdersLoaded] on success',
      build: () {
        when(() => mockGetWorkOrdersUseCase()).thenAnswer((_) async => Right([tWorkOrder]));
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Right([tVehicle]));
        return jobBloc;
      },
      act: (bloc) => bloc.add(const FetchWorkOrders()),
      expect: () => [
        JobLoading(),
        WorkOrdersLoaded(
          workOrders: [tWorkOrder],
          customerNames: const {'cust-123': 'Jane Smith'},
          vehicleNames: const {'vin-123': '2021 Ford F-150'},
        ),
      ],
    );

    blocTest<JobBloc, JobState>(
      'should emit [JobLoading, JobError] when fetching fails',
      build: () {
        when(() => mockGetWorkOrdersUseCase()).thenAnswer((_) async => const Left(ServerFailure('Fetch Failed')));
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Right([tVehicle]));
        return jobBloc;
      },
      act: (bloc) => bloc.add(const FetchWorkOrders()),
      expect: () => [
        JobLoading(),
        const JobError('Fetch Failed'),
      ],
    );
  group('CreateWorkOrderEvent', () {
    blocTest<JobBloc, JobState>(
      'should emit [JobLoading, WorkOrderOperationSuccess, JobLoading, WorkOrdersLoaded] on success',
      build: () {
        when(() => mockCreateWorkOrderUseCase(
              quoteId: any(named: 'quoteId'),
              vehicleId: any(named: 'vehicleId'),
              customerId: any(named: 'customerId'),
              authorizedAmount: any(named: 'authorizedAmount'),
            )).thenAnswer((_) async => Right(tWorkOrder));
        when(() => mockGetWorkOrdersUseCase()).thenAnswer((_) async => Right([tWorkOrder]));
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Right([tVehicle]));
        return jobBloc;
      },
      act: (bloc) => bloc.add(const CreateWorkOrderEvent(
        quoteId: 'quote-123',
        vehicleId: 'vin-123',
        customerId: 'cust-123',
        authorizedAmount: 500.0,
      )),
      expect: () => [
        JobLoading(),
        const WorkOrderOperationSuccess('Work order generated successfully!'),
        JobLoading(),
        WorkOrdersLoaded(
          workOrders: [tWorkOrder],
          customerNames: const {'cust-123': 'Jane Smith'},
          vehicleNames: const {'vin-123': '2021 Ford F-150'},
        ),
      ],
    );
  });

  group('AddLineItemEvent', () {
    blocTest<JobBloc, JobState>(
      'should emit [JobLoading, WorkOrderOperationSuccess, JobLoading, WorkOrdersLoaded] on success',
      build: () {
        when(() => mockCreateLineItemUseCase(
              any(),
              description: any(named: 'description'),
              billingMode: any(named: 'billingMode'),
              price: any(named: 'price'),
              status: any(named: 'status'),
            )).thenAnswer((_) async => Right(tLineItem));
        when(() => mockGetWorkOrdersUseCase()).thenAnswer((_) async => Right([tWorkOrder]));
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit'))).thenAnswer((_) async => Right([tVehicle]));
        return jobBloc;
      },
      act: (bloc) => bloc.add(const AddLineItemEvent(
        workOrderId: 'wo-123',
        description: 'Front brake service',
        billingMode: 'flat_rate',
        price: 150.0,
        status: 'not_started',
      )),
      expect: () => [
        JobLoading(),
        const WorkOrderOperationSuccess('Task line item added successfully!'),
        JobLoading(),
        WorkOrdersLoaded(
          workOrders: [tWorkOrder],
          customerNames: const {'cust-123': 'Jane Smith'},
          vehicleNames: const {'vin-123': '2021 Ford F-150'},
        ),
      ],
    );
  });
  });
}
