import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/core/error/failures.dart';
import 'package:wheels_doc/features/vehicle/domain/entities/vehicle.dart';
import 'package:wheels_doc/features/vehicle/domain/usecases/get_vehicles_usecase.dart';
import 'package:wheels_doc/features/vehicle/presentation/bloc/vehicle_list/vehicle_list_bloc.dart';
import 'package:wheels_doc/features/vehicle/presentation/bloc/vehicle_list/vehicle_list_event.dart';
import 'package:wheels_doc/features/vehicle/presentation/bloc/vehicle_list/vehicle_list_state.dart';

class MockGetVehiclesUseCase extends Mock implements GetVehiclesUseCase {}

void main() {
  late VehicleListBloc vehicleListBloc;
  late MockGetVehiclesUseCase mockGetVehiclesUseCase;

  const tVehicle = Vehicle(
    vin: '1HGCM82633A123456',
    customerId: 'cust-123',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
    currentMileage: 50000,
  );

  setUp(() {
    mockGetVehiclesUseCase = MockGetVehiclesUseCase();
    vehicleListBloc = VehicleListBloc(getVehiclesUseCase: mockGetVehiclesUseCase);
  });

  tearDown(() {
    vehicleListBloc.close();
  });

  group('FetchVehiclesList', () {
    blocTest<VehicleListBloc, VehicleListState>(
      'should emit [VehicleListLoading, VehicleListLoaded] when fetching vehicles successfully',
      build: () {
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => const Right([tVehicle]));
        return vehicleListBloc;
      },
      act: (bloc) => bloc.add(const FetchVehiclesList()),
      expect: () => [
        VehicleListLoading(),
        const VehicleListLoaded([tVehicle]),
      ],
    );

    blocTest<VehicleListBloc, VehicleListState>(
      'should emit [VehicleListLoading, VehicleListError] when fetching vehicles fails',
      build: () {
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => const Left(ServerFailure('Error')));
        return vehicleListBloc;
      },
      act: (bloc) => bloc.add(const FetchVehiclesList()),
      expect: () => [
        VehicleListLoading(),
        const VehicleListError('Error'),
      ],
    );
  });
}
