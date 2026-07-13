import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/core/error/failures.dart';
import 'package:wheels_doc/features/customer/domain/entities/customer.dart';
import 'package:wheels_doc/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:wheels_doc/features/vehicle/domain/entities/vehicle.dart';
import 'package:wheels_doc/features/vehicle/domain/usecases/get_vehicles_usecase.dart';
import 'package:wheels_doc/features/visit/domain/entities/visit.dart';
import 'package:wheels_doc/features/visit/domain/usecases/create_visit_usecase.dart';
import 'package:wheels_doc/features/visit/domain/usecases/get_visits_usecase.dart';
import 'package:wheels_doc/features/visit/domain/usecases/update_visit_usecase.dart';
import 'package:wheels_doc/features/visit/presentation/bloc/visit_list_bloc.dart';
import 'package:wheels_doc/features/visit/presentation/bloc/visit_list_event.dart';
import 'package:wheels_doc/features/visit/presentation/bloc/visit_list_state.dart';

class MockGetVisitsUseCase extends Mock implements GetVisitsUseCase {}
class MockCreateVisitUseCase extends Mock implements CreateVisitUseCase {}
class MockUpdateVisitUseCase extends Mock implements UpdateVisitUseCase {}
class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}
class MockGetVehiclesUseCase extends Mock implements GetVehiclesUseCase {}

void main() {
  late VisitListBloc visitListBloc;
  late MockGetVisitsUseCase mockGetVisitsUseCase;
  late MockCreateVisitUseCase mockCreateVisitUseCase;
  late MockUpdateVisitUseCase mockUpdateVisitUseCase;
  late MockGetCustomersUseCase mockGetCustomersUseCase;
  late MockGetVehiclesUseCase mockGetVehiclesUseCase;

  final tVisit = Visit(
    visitId: 'visit-123',
    vehicleId: 'vin-123',
    customerId: 'cust-123',
    checkedInAt: DateTime(2026, 7, 10, 10, 0),
    status: 'checked_in',
    isActive: true,
  );

  final tCustomer = Customer(
    id: 'cust-123',
    name: 'John Doe',
    customerType: 'individual',
    billingAddress: '123 Main St',
    taxExempt: false,
  );

  final tVehicle = Vehicle(
    vin: 'vin-123',
    customerId: 'cust-123',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
    currentMileage: 50000,
  );

  final tEnrichedVisit = Visit(
    visitId: 'visit-123',
    vehicleId: 'vin-123',
    customerId: 'cust-123',
    checkedInAt: DateTime(2026, 7, 10, 10, 0),
    status: 'checked_in',
    isActive: true,
    customerName: 'John Doe',
    vehicleName: '2020 Toyota Corolla',
  );

  setUp(() {
    mockGetVisitsUseCase = MockGetVisitsUseCase();
    mockCreateVisitUseCase = MockCreateVisitUseCase();
    mockUpdateVisitUseCase = MockUpdateVisitUseCase();
    mockGetCustomersUseCase = MockGetCustomersUseCase();
    mockGetVehiclesUseCase = MockGetVehiclesUseCase();

    visitListBloc = VisitListBloc(
      getVisitsUseCase: mockGetVisitsUseCase,
      createVisitUseCase: mockCreateVisitUseCase,
      updateVisitUseCase: mockUpdateVisitUseCase,
      getCustomersUseCase: mockGetCustomersUseCase,
      getVehiclesUseCase: mockGetVehiclesUseCase,
    );
  });

  tearDown(() {
    visitListBloc.close();
  });

  group('FetchVisitsList', () {
    blocTest<VisitListBloc, VisitListState>(
      'should emit [VisitListLoading, VisitListLoaded] with enriched names when fetching succeeds',
      build: () {
        when(() => mockGetVisitsUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tVisit]));
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit')))
            .thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit')))
            .thenAnswer((_) async => Right([tVehicle]));
        return visitListBloc;
      },
      act: (bloc) => bloc.add(const FetchVisitsList()),
      expect: () => [
        VisitListLoading(),
        VisitListLoaded([tEnrichedVisit]),
      ],
    );

    blocTest<VisitListBloc, VisitListState>(
      'should emit [VisitListLoading, VisitListError] when fetching visits fails',
      build: () {
        when(() => mockGetVisitsUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => const Left(ServerFailure('Server Error')));
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit')))
            .thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit')))
            .thenAnswer((_) async => Right([tVehicle]));
        return visitListBloc;
      },
      act: (bloc) => bloc.add(const FetchVisitsList()),
      expect: () => [
        VisitListLoading(),
        const VisitListError('Server Error'),
      ],
    );
  });

  group('CreateVisitEvent', () {
    blocTest<VisitListBloc, VisitListState>(
      'should emit [VisitListLoading, VisitOperationSuccess, VisitListLoading, VisitListLoaded] when creating succeeds',
      build: () {
        when(() => mockCreateVisitUseCase(
              vehicleId: any(named: 'vehicleId'),
              customerId: any(named: 'customerId'),
            )).thenAnswer((_) async => Right(tVisit));
        when(() => mockGetVisitsUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tVisit]));
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit')))
            .thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit')))
            .thenAnswer((_) async => Right([tVehicle]));
        return visitListBloc;
      },
      act: (bloc) => bloc.add(const CreateVisitEvent(vehicleId: 'vin-123', customerId: 'cust-123')),
      expect: () => [
        VisitListLoading(),
        VisitOperationSuccess(),
        VisitListLoading(),
        VisitListLoaded([tEnrichedVisit]),
      ],
    );
  });
}
