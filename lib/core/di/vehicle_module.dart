import 'package:get_it/get_it.dart';
import '../../features/vehicle/data/datasources/vehicle_remote_datasource.dart';
import '../../features/vehicle/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicle/domain/repositories/vehicle_repository.dart';
import '../../features/vehicle/domain/usecases/delete_vehicle_usecase.dart';
import '../../features/vehicle/domain/usecases/get_vehicle_by_vin_usecase.dart';
import '../../features/vehicle/domain/usecases/get_vehicles_by_customer_usecase.dart';
import '../../features/vehicle/domain/usecases/get_vehicles_usecase.dart';
import '../../features/vehicle/domain/usecases/register_vehicle_usecase.dart';
import '../../features/vehicle/domain/usecases/update_vehicle_usecase.dart';
import '../../features/vehicle/presentation/bloc/vehicle_detail/vehicle_detail_cubit.dart';
import '../../features/vehicle/presentation/bloc/vehicle_list/vehicle_list_bloc.dart';

final sl = GetIt.instance;

void initVehicle() {
  // Remote Datasources
  sl.registerLazySingleton<VehicleRemoteDataSource>(
    () => VehicleRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(sl(), sl()),
  );

  // Use Cases
  sl.registerLazySingleton<GetVehiclesUseCase>(() => GetVehiclesUseCase(sl()));
  sl.registerLazySingleton<GetVehicleByVinUseCase>(() => GetVehicleByVinUseCase(sl()));
  sl.registerLazySingleton<GetVehiclesByCustomerUseCase>(() => GetVehiclesByCustomerUseCase(sl()));
  sl.registerLazySingleton<RegisterVehicleUseCase>(() => RegisterVehicleUseCase(sl()));
  sl.registerLazySingleton<UpdateVehicleUseCase>(() => UpdateVehicleUseCase(sl()));
  sl.registerLazySingleton<DeleteVehicleUseCase>(() => DeleteVehicleUseCase(sl()));

  // BLoCs & Cubits
  sl.registerFactory<VehicleListBloc>(
    () => VehicleListBloc(getVehiclesUseCase: sl()),
  );
  sl.registerFactory<VehicleDetailCubit>(
    () => VehicleDetailCubit(
      getVehicleByVinUseCase: sl(),
      getCustomerByIdUseCase: sl(),
      updateVehicleUseCase: sl(),
      deleteVehicleUseCase: sl(),
    ),
  );
}
