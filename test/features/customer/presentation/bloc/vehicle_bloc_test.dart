import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/core/error/failures.dart';
import 'package:wheels_doc/features/customer/domain/entities/vehicle.dart';
import 'package:wheels_doc/features/customer/domain/usecases/get_vehicles_usecase.dart';
import 'package:wheels_doc/features/customer/domain/usecases/register_vehicle_usecase.dart';
import 'package:wheels_doc/features/customer/presentation/bloc/vehicle_bloc.dart';
import 'package:wheels_doc/features/customer/presentation/bloc/vehicle_event.dart';
import 'package:wheels_doc/features/customer/presentation/bloc/vehicle_state.dart';

class MockGetVehiclesUseCase extends Mock implements GetVehiclesUseCase {}

class MockRegisterVehicleUseCase extends Mock implements RegisterVehicleUseCase {}

void main() {
  late VehicleBloc vehicleBloc;
  late MockGetVehiclesUseCase mockGetVehiclesUseCase;
  late MockRegisterVehicleUseCase mockRegisterVehicleUseCase;

  final tVehicle = Vehicle(
    vin: '1HGCM82633A123456',
    customerId: 'cust-123',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
    currentMileage: 50000,
  );

  setUp(() {
    mockGetVehiclesUseCase = MockGetVehiclesUseCase();
    mockRegisterVehicleUseCase = MockRegisterVehicleUseCase();

    vehicleBloc = VehicleBloc(
      getVehiclesUseCase: mockGetVehiclesUseCase,
      registerVehicleUseCase: mockRegisterVehicleUseCase,
    );
  });

  tearDown(() {
    vehicleBloc.close();
  });

  group('FetchVehicles', () {
    blocTest<VehicleBloc, VehicleState>(
      'should emit [VehicleLoading, VehiclesLoaded] when fetching vehicles successfully',
      build: () {
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tVehicle]));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(const FetchVehicles()),
      expect: () => [
        VehicleLoading(),
        VehiclesLoaded([tVehicle]),
      ],
    );
  });

  group('RegisterVehicleEvent', () {
    blocTest<VehicleBloc, VehicleState>(
      'should emit [VehicleLoading, VehicleOperationSuccess] when registration succeeds',
      build: () {
        when(() => mockRegisterVehicleUseCase(
              vin: any(named: 'vin'),
              customerId: any(named: 'customerId'),
              make: any(named: 'make'),
              model: any(named: 'model'),
              year: any(named: 'year'),
              currentMileage: any(named: 'currentMileage'),
            )).thenAnswer((_) async => Right(tVehicle));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(const RegisterVehicleEvent(
        vin: '1HGCM82633A123456',
        customerId: 'cust-123',
        make: 'Toyota',
        model: 'Corolla',
        year: 2020,
        currentMileage: 50000,
      )),
      expect: () => [
        VehicleLoading(),
        VehicleOperationSuccess(tVehicle, 'Vehicle registered successfully'),
      ],
    );
  });
}
