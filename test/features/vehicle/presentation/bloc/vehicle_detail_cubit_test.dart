import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/core/error/failures.dart';
import 'package:wheels_doc/features/customer/domain/entities/customer.dart';
import 'package:wheels_doc/features/customer/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:wheels_doc/features/vehicle/domain/entities/vehicle.dart';
import 'package:wheels_doc/features/vehicle/domain/usecases/delete_vehicle_usecase.dart';
import 'package:wheels_doc/features/vehicle/domain/usecases/get_vehicle_by_vin_usecase.dart';
import 'package:wheels_doc/features/vehicle/domain/usecases/update_vehicle_usecase.dart';
import 'package:wheels_doc/features/vehicle/presentation/bloc/vehicle_detail/vehicle_detail_cubit.dart';
import 'package:wheels_doc/features/vehicle/presentation/bloc/vehicle_detail/vehicle_detail_state.dart';

class MockGetVehicleByVinUseCase extends Mock implements GetVehicleByVinUseCase {}
class MockGetCustomerByIdUseCase extends Mock implements GetCustomerByIdUseCase {}
class MockUpdateVehicleUseCase extends Mock implements UpdateVehicleUseCase {}
class MockDeleteVehicleUseCase extends Mock implements DeleteVehicleUseCase {}

void main() {
  late VehicleDetailCubit vehicleDetailCubit;
  late MockGetVehicleByVinUseCase mockGetVehicleByVinUseCase;
  late MockGetCustomerByIdUseCase mockGetCustomerByIdUseCase;
  late MockUpdateVehicleUseCase mockUpdateVehicleUseCase;
  late MockDeleteVehicleUseCase mockDeleteVehicleUseCase;

  const tVehicle = Vehicle(
    vin: '1HGCM82633A123456',
    customerId: 'cust-123',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
    currentMileage: 50000,
  );

  final tCustomer = Customer(
    id: 'cust-123',
    name: 'John Doe',
    customerType: 'individual',
    billingAddress: '123 Main St',
    taxExempt: false,
  );

  setUp(() {
    mockGetVehicleByVinUseCase = MockGetVehicleByVinUseCase();
    mockGetCustomerByIdUseCase = MockGetCustomerByIdUseCase();
    mockUpdateVehicleUseCase = MockUpdateVehicleUseCase();
    mockDeleteVehicleUseCase = MockDeleteVehicleUseCase();

    vehicleDetailCubit = VehicleDetailCubit(
      getVehicleByVinUseCase: mockGetVehicleByVinUseCase,
      getCustomerByIdUseCase: mockGetCustomerByIdUseCase,
      updateVehicleUseCase: mockUpdateVehicleUseCase,
      deleteVehicleUseCase: mockDeleteVehicleUseCase,
    );
  });

  tearDown(() {
    vehicleDetailCubit.close();
  });

  group('loadVehicle', () {
    blocTest<VehicleDetailCubit, VehicleDetailState>(
      'should emit [VehicleDetailLoading, VehicleDetailLoaded] when vehicle and owner are fetched successfully',
      build: () {
        when(() => mockGetVehicleByVinUseCase(any())).thenAnswer((_) async => const Right(tVehicle));
        when(() => mockGetCustomerByIdUseCase(any())).thenAnswer((_) async => Right(tCustomer));
        return vehicleDetailCubit;
      },
      act: (cubit) => cubit.loadVehicle('1HGCM82633A123456'),
      expect: () => [
        VehicleDetailLoading(),
        VehicleDetailLoaded(vehicle: tVehicle, customer: tCustomer),
      ],
    );

    blocTest<VehicleDetailCubit, VehicleDetailState>(
      'should emit [VehicleDetailLoading, VehicleDetailError] when vehicle fetch fails',
      build: () {
        when(() => mockGetVehicleByVinUseCase(any())).thenAnswer((_) async => const Left(ServerFailure('Error')));
        return vehicleDetailCubit;
      },
      act: (cubit) => cubit.loadVehicle('1HGCM82633A123456'),
      expect: () => [
        VehicleDetailLoading(),
        const VehicleDetailError('Error'),
      ],
    );
  });

  group('updateVehicle', () {
    blocTest<VehicleDetailCubit, VehicleDetailState>(
      'should emit updated VehicleDetailLoaded when vehicle update succeeds',
      build: () {
        when(() => mockUpdateVehicleUseCase(any(),
                make: any(named: 'make'),
                model: any(named: 'model'),
                year: any(named: 'year'),
                currentMileage: any(named: 'currentMileage')))
            .thenAnswer((_) async => const Right(tVehicle));
        when(() => mockGetCustomerByIdUseCase(any())).thenAnswer((_) async => Right(tCustomer));
        return vehicleDetailCubit;
      },
      act: (cubit) => cubit.updateVehicle('1HGCM82633A123456', currentMileage: 55000),
      expect: () => [
        VehicleDetailLoaded(vehicle: tVehicle, customer: tCustomer),
      ],
    );
  });

  group('deleteVehicle', () {
    blocTest<VehicleDetailCubit, VehicleDetailState>(
      'should emit [VehicleDetailLoading, VehicleDeleteSuccess] when vehicle deletion succeeds',
      build: () {
        when(() => mockDeleteVehicleUseCase(any())).thenAnswer((_) async => const Right(null));
        return vehicleDetailCubit;
      },
      act: (cubit) => cubit.deleteVehicle('1HGCM82633A123456'),
      expect: () => [
        VehicleDetailLoading(),
        VehicleDeleteSuccess(),
      ],
    );
  });
}
