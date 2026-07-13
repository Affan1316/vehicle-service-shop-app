import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:wheels_doc/app.dart';
import 'package:wheels_doc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wheels_doc/features/auth/presentation/bloc/auth_event.dart';
import 'package:wheels_doc/features/auth/presentation/bloc/auth_state.dart';
import 'package:wheels_doc/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:wheels_doc/features/customer/presentation/bloc/customer_state.dart';
import 'package:wheels_doc/features/vehicle/presentation/bloc/vehicle_list/vehicle_list_bloc.dart';
import 'package:wheels_doc/features/vehicle/presentation/bloc/vehicle_list/vehicle_list_state.dart';
import 'package:wheels_doc/features/visit/presentation/bloc/visit_list_bloc.dart';
import 'package:wheels_doc/features/visit/presentation/bloc/visit_list_state.dart';

class MockAuthBloc extends Mock implements AuthBloc {}
class MockCustomerBloc extends Mock implements CustomerBloc {}
class MockVehicleListBloc extends Mock implements VehicleListBloc {}
class MockVisitListBloc extends Mock implements VisitListBloc {}

void main() {
  final sl = GetIt.instance;

  setUpAll(() {
    registerFallbackValue(AppStarted());
  });

  tearDown(() {
    sl.reset();
  });

  testWidgets('App loads placeholder smoke test', (WidgetTester tester) async {
    final mockAuthBloc = MockAuthBloc();
    final mockCustomerBloc = MockCustomerBloc();
    final mockVehicleListBloc = MockVehicleListBloc();
    final mockVisitListBloc = MockVisitListBloc();
    
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});

    when(() => mockCustomerBloc.state).thenReturn(CustomerInitial());
    when(() => mockCustomerBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCustomerBloc.close()).thenAnswer((_) async {});

    when(() => mockVehicleListBloc.state).thenReturn(VehicleListInitial());
    when(() => mockVehicleListBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockVehicleListBloc.close()).thenAnswer((_) async {});

    when(() => mockVisitListBloc.state).thenReturn(VisitListInitial());
    when(() => mockVisitListBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockVisitListBloc.close()).thenAnswer((_) async {});

    sl.registerFactory<AuthBloc>(() => mockAuthBloc);
    sl.registerFactory<CustomerBloc>(() => mockCustomerBloc);
    sl.registerFactory<VehicleListBloc>(() => mockVehicleListBloc);
    sl.registerFactory<VisitListBloc>(() => mockVisitListBloc);

    await tester.pumpWidget(const WheelsDocApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
