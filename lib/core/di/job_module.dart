import 'package:get_it/get_it.dart';
import '../../features/job/data/datasources/job_remote_datasource.dart';
import '../../features/job/data/repositories/job_repository_impl.dart';
import '../../features/job/domain/repositories/job_repository.dart';
import '../../features/job/domain/usecases/create_line_item.dart';
import '../../features/job/domain/usecases/create_work_order.dart';
import '../../features/job/domain/usecases/get_work_orders.dart';
import '../../features/job/domain/usecases/update_line_item.dart';
import '../../features/job/domain/usecases/update_work_order.dart';
import '../../features/job/presentation/bloc/job_bloc.dart';

final sl = GetIt.instance;

void initJob() {
  // Remote Datasources
  sl.registerLazySingleton<JobRemoteDataSource>(
    () => JobRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<JobRepository>(
    () => JobRepositoryImpl(sl(), sl()),
  );

  // Use Cases
  sl.registerLazySingleton<GetWorkOrdersUseCase>(() => GetWorkOrdersUseCase(sl()));
  sl.registerLazySingleton<CreateWorkOrderUseCase>(() => CreateWorkOrderUseCase(sl()));
  sl.registerLazySingleton<UpdateWorkOrderUseCase>(() => UpdateWorkOrderUseCase(sl()));
  sl.registerLazySingleton<CreateLineItemUseCase>(() => CreateLineItemUseCase(sl()));
  sl.registerLazySingleton<UpdateLineItemUseCase>(() => UpdateLineItemUseCase(sl()));

  // BLoCs
  sl.registerFactory<JobBloc>(
    () => JobBloc(
      getWorkOrdersUseCase: sl(),
      createWorkOrderUseCase: sl(),
      updateWorkOrderUseCase: sl(),
      createLineItemUseCase: sl(),
      updateLineItemUseCase: sl(),
      getCustomersUseCase: sl(),
      getVehiclesUseCase: sl(),
    ),
  );
}
