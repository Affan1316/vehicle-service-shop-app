import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/customer/presentation/pages/customer_list_page.dart';
import '../../features/customer/presentation/pages/customer_hub_page.dart';
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
              ],
            ),
          ),
        ),
      ),
      GoRoute(
        name: RouteNames.customerListName,
        path: RouteNames.customerListPath,
        builder: (context, state) => const CustomerListPage(),
      ),
      GoRoute(
        name: RouteNames.customerHubName,
        path: RouteNames.customerHubPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CustomerHubPage(customerId: id);
        },
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
