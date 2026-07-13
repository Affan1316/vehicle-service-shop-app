import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/customer/presentation/pages/customer_list_page.dart';
import '../../features/customer/presentation/pages/customer_hub_page.dart';
import '../../features/vehicle/presentation/bloc/vehicle_list/vehicle_list_bloc.dart';
import '../../features/vehicle/presentation/pages/vehicle_list_page.dart';
import '../../features/visit/presentation/bloc/visit_list_bloc.dart';
import '../../features/visit/presentation/pages/visit_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection_container.dart';
import '../../features/customer/presentation/bloc/customer_bloc.dart';
import '../../features/customer/presentation/bloc/vehicle_bloc.dart';
import 'route_names.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.dashboardPath,
    refreshListenable: _GoRouterRefreshStream(authBloc.stream),
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation == RouteNames.loginPath;
      final isRegistering = state.matchedLocation == RouteNames.registerPath;

      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      final isLoggedIn = authState is Authenticated;

      if (!isLoggedIn && !isLoggingIn && !isRegistering) {
        return RouteNames.loginPath;
      }

      if (isLoggedIn && (isLoggingIn || isRegistering)) {
        return RouteNames.dashboardPath;
      }

      return null;
    },
    routes: [
      GoRoute(
        name: RouteNames.loginName,
        path: RouteNames.loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        name: RouteNames.registerName,
        path: RouteNames.registerPath,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        name: RouteNames.dashboardName,
        path: RouteNames.dashboardPath,
        builder: (context, state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Dashboard Placeholder'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.push('/customers'),
                  child: const Text('Go to Customers Directory'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/vehicles'),
                  child: const Text('Go to Vehicles Directory'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/visits'),
                  child: const Text('Go to Visits Directory'),
                ),
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.customerListName,
        path: RouteNames.customerListPath,
        builder: (context, state) => BlocProvider<CustomerBloc>(
          create: (context) => sl<CustomerBloc>(),
          child: const CustomerListPage(),
        ),
      ),
      GoRoute(
        name: RouteNames.customerHubName,
        path: RouteNames.customerHubPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return MultiBlocProvider(
            providers: [
              BlocProvider<CustomerBloc>(
                create: (context) => sl<CustomerBloc>(),
              ),
              BlocProvider<VehicleBloc>(
                create: (context) => sl<VehicleBloc>(),
              ),
            ],
            child: CustomerHubPage(customerId: id),
          );
        },
      ),
      GoRoute(
        name: RouteNames.vehicleListName,
        path: RouteNames.vehicleListPath,
        builder: (context, state) => BlocProvider<VehicleListBloc>(
          create: (context) => sl<VehicleListBloc>(),
          child: const VehicleListPage(),
        ),
      ),
      GoRoute(
        name: RouteNames.visitListName,
        path: RouteNames.visitListPath,
        builder: (context, state) => BlocProvider<VisitListBloc>(
          create: (context) => sl<VisitListBloc>(),
          child: const VisitListPage(),
        ),
      ),
    ],
  );
}

class _GoRouterRefreshStream extends ChangeNotifier {
  late final dynamic _subscription;

  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
