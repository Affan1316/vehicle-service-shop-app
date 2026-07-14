import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/auth_interceptor.dart';
import '../network/error_interceptor.dart';
import '../network/network_info.dart';
import '../network/retry_interceptor.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import 'auth_module.dart';
import 'customer_module.dart';
import 'vehicle_module.dart';
import 'visit_module.dart';
import 'job_module.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core Storage
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage(sl()));
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sl()));

  // Core Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(sl()));
  sl.registerLazySingleton<ErrorInterceptor>(() => ErrorInterceptor());
  sl.registerLazySingleton<RetryInterceptor>(() => RetryInterceptor());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl(), sl(), sl(), sl()));

  // Features
  initAuth();
  initCustomer();
  initVehicle();
  initVisit();
  initJob();
}
