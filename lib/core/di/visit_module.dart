import 'package:get_it/get_it.dart';
import '../../features/visit/data/datasources/visit_remote_datasource.dart';
import '../../features/visit/data/repositories/visit_repository_impl.dart';
import '../../features/visit/domain/repositories/visit_repository.dart';
import '../../features/visit/domain/usecases/create_visit_usecase.dart';
import '../../features/visit/domain/usecases/get_visits_usecase.dart';
import '../../features/visit/domain/usecases/update_visit_usecase.dart';
import '../../features/visit/presentation/bloc/visit_list_bloc.dart';

final sl = GetIt.instance;

void initVisit() {
  // Remote Datasources
  sl.registerLazySingleton<VisitRemoteDataSource>(
    () => VisitRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<VisitRepository>(
    () => VisitRepositoryImpl(sl(), sl()),
  );

  // Use Cases
  sl.registerLazySingleton<GetVisitsUseCase>(() => GetVisitsUseCase(sl()));
  sl.registerLazySingleton<CreateVisitUseCase>(() => CreateVisitUseCase(sl()));
  sl.registerLazySingleton<UpdateVisitUseCase>(() => UpdateVisitUseCase(sl()));

  // BLoCs
  sl.registerFactory<VisitListBloc>(
    () => VisitListBloc(
      getVisitsUseCase: sl(),
      createVisitUseCase: sl(),
      updateVisitUseCase: sl(),
      getCustomersUseCase: sl(),
      getVehiclesUseCase: sl(),
    ),
  );
}
