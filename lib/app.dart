import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

import 'features/customer/presentation/bloc/customer_bloc.dart';
import 'features/customer/presentation/bloc/vehicle_bloc.dart';

class WheelsDocApp extends StatelessWidget {
  const WheelsDocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AppStarted()),
        ),
        BlocProvider<CustomerBloc>(
          create: (context) => sl<CustomerBloc>(),
        ),
        BlocProvider<VehicleBloc>(
          create: (context) => sl<VehicleBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final appRouter = AppRouter(context.read<AuthBloc>());
          return MaterialApp.router(
            title: 'Wheels Doc',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
