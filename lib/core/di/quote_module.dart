import 'package:get_it/get_it.dart';
import '../../features/quote/data/datasources/quote_remote_datasource.dart';
import '../../features/quote/data/repositories/quote_repository_impl.dart';
import '../../features/quote/domain/repositories/quote_repository.dart';
import '../../features/quote/domain/usecases/create_quote.dart';
import '../../features/quote/domain/usecases/get_quotes.dart';
import '../../features/quote/domain/usecases/update_quote.dart';
import '../../features/quote/presentation/bloc/quote_bloc.dart';

final sl = GetIt.instance;

void initQuote() {
  // BLoC
  sl.registerFactory(
    () => QuoteBloc(
      getQuotesUseCase: sl(),
      createQuoteUseCase: sl(),
      updateQuoteUseCase: sl(),
      getCustomersUseCase: sl(),
      getVehiclesUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetQuotesUseCase(sl()));
  sl.registerLazySingleton(() => CreateQuoteUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuoteUseCase(sl()));

  // Repository
  sl.registerLazySingleton<QuoteRepository>(
    () => QuoteRepositoryImpl(sl(), sl()),
  );

  // Data Sources
  sl.registerLazySingleton<QuoteRemoteDataSource>(
    () => QuoteRemoteDataSourceImpl(sl()),
  );
}
