import 'package:get_it/get_it.dart';
import '../../features/resource/data/datasources/resource_remote_datasource.dart';
import '../../features/resource/data/repositories/bay_repository_impl.dart';
import '../../features/resource/data/repositories/technician_repository_impl.dart';
import '../../features/resource/domain/repositories/bay_repository.dart';
import '../../features/resource/domain/repositories/technician_repository.dart';
import '../../features/resource/domain/usecases/get_bays_usecase.dart';
import '../../features/resource/domain/usecases/update_bay_usecase.dart';
import '../../features/resource/domain/usecases/get_technicians_usecase.dart';
import '../../features/resource/presentation/bloc/bay_bloc.dart';

final sl = GetIt.instance;

void initResource() {
  // Remote Datasources
  sl.registerLazySingleton<ResourceRemoteDataSource>(
    () => ResourceRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<BayRepository>(
    () => BayRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<TechnicianRepository>(
    () => TechnicianRepositoryImpl(sl(), sl()),
  );

  // Use Cases
  sl.registerLazySingleton<GetBaysUseCase>(() => GetBaysUseCase(sl()));
  sl.registerLazySingleton<UpdateBayUseCase>(() => UpdateBayUseCase(sl()));
  sl.registerLazySingleton<GetTechniciansUseCase>(() => GetTechniciansUseCase(sl()));

  // BLoCs
  sl.registerFactory<BayBloc>(
    () => BayBloc(
      getBaysUseCase: sl(),
      updateBayUseCase: sl(),
    ),
  );
}
