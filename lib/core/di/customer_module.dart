import 'package:get_it/get_it.dart';
import '../../features/customer/data/datasources/customer_remote_datasource.dart';
import '../../features/customer/data/repositories/customer_repository_impl.dart';
import '../../features/customer/domain/repositories/customer_repository.dart';
import '../../features/customer/domain/usecases/create_customer_usecase.dart';
import '../../features/customer/domain/usecases/get_customer_by_id_usecase.dart';
import '../../features/customer/domain/usecases/get_customers_usecase.dart';
import '../../features/customer/domain/usecases/update_customer_usecase.dart';
import '../../features/customer/presentation/bloc/customer_bloc.dart';
import '../../features/customer/presentation/bloc/vehicle_bloc.dart';

final sl = GetIt.instance;

void initCustomer() {
  // Remote Datasources
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl(), sl()),
  );

  // Use Cases
  sl.registerLazySingleton<GetCustomersUseCase>(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton<GetCustomerByIdUseCase>(() => GetCustomerByIdUseCase(sl()));
  sl.registerLazySingleton<CreateCustomerUseCase>(() => CreateCustomerUseCase(sl()));
  sl.registerLazySingleton<UpdateCustomerUseCase>(() => UpdateCustomerUseCase(sl()));

  // BLoCs
  sl.registerFactory<CustomerBloc>(
    () => CustomerBloc(
      getCustomersUseCase: sl(),
      getCustomerByIdUseCase: sl(),
      createCustomerUseCase: sl(),
      updateCustomerUseCase: sl(),
      getVehiclesByCustomerUseCase: sl(),
    ),
  );
  sl.registerFactory<VehicleBloc>(
    () => VehicleBloc(
      getVehiclesUseCase: sl(),
      registerVehicleUseCase: sl(),
    ),
  );
}
