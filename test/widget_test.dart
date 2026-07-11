import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:wheels_doc/app.dart';
import 'package:wheels_doc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wheels_doc/features/auth/presentation/bloc/auth_event.dart';
import 'package:wheels_doc/features/auth/presentation/bloc/auth_state.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

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
    
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});

    sl.registerFactory<AuthBloc>(() => mockAuthBloc);

    await tester.pumpWidget(const WheelsDocApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
