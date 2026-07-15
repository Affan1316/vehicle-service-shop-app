import 'package:get_it/get_it.dart';
import '../../features/billing/data/datasources/billing_remote_datasource.dart';
import '../../features/billing/data/repositories/billing_repository_impl.dart';
import '../../features/billing/domain/repositories/billing_repository.dart';
import '../../features/billing/domain/usecases/create_deposit.dart';
import '../../features/billing/domain/usecases/create_invoice.dart';
import '../../features/billing/domain/usecases/create_payment.dart';
import '../../features/billing/domain/usecases/get_invoices.dart';
import '../../features/billing/domain/usecases/update_invoice.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';

final sl = GetIt.instance;

void initBilling() {
  // BLoC
  sl.registerFactory(
    () => BillingBloc(
      getInvoicesUseCase: sl(),
      createInvoiceUseCase: sl(),
      updateInvoiceUseCase: sl(),
      createPaymentUseCase: sl(),
      createDepositUseCase: sl(),
      getCustomersUseCase: sl(),
      getWorkOrdersUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetInvoicesUseCase(sl()));
  sl.registerLazySingleton(() => CreateInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => UpdateInvoiceUseCase(sl()));
  sl.registerLazySingleton(() => CreatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => CreateDepositUseCase(sl()));

  // Repository
  sl.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(sl(), sl()),
  );

  // Data Sources
  sl.registerLazySingleton<BillingRemoteDataSource>(
    () => BillingRemoteDataSourceImpl(sl()),
  );
}
