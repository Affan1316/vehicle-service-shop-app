import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/features/customer/domain/entities/customer.dart';
import 'package:wheels_doc/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:wheels_doc/features/vehicle/domain/entities/vehicle.dart';
import 'package:wheels_doc/features/vehicle/domain/usecases/get_vehicles_usecase.dart';
import 'package:wheels_doc/features/quote/domain/entities/quote.dart';
import 'package:wheels_doc/features/quote/domain/usecases/create_quote.dart';
import 'package:wheels_doc/features/quote/domain/usecases/get_quotes.dart';
import 'package:wheels_doc/features/quote/domain/usecases/update_quote.dart';
import 'package:wheels_doc/features/quote/presentation/bloc/quote_bloc.dart';
import 'package:wheels_doc/features/quote/presentation/bloc/quote_event.dart';
import 'package:wheels_doc/features/quote/presentation/bloc/quote_state.dart';

class MockGetQuotesUseCase extends Mock implements GetQuotesUseCase {}
class MockCreateQuoteUseCase extends Mock implements CreateQuoteUseCase {}
class MockUpdateQuoteUseCase extends Mock implements UpdateQuoteUseCase {}
class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}
class MockGetVehiclesUseCase extends Mock implements GetVehiclesUseCase {}

void main() {
  late QuoteBloc quoteBloc;
  late MockGetQuotesUseCase mockGetQuotesUseCase;
  late MockCreateQuoteUseCase mockCreateQuoteUseCase;
  late MockUpdateQuoteUseCase mockUpdateQuoteUseCase;
  late MockGetCustomersUseCase mockGetCustomersUseCase;
  late MockGetVehiclesUseCase mockGetVehiclesUseCase;

  final tQuote = Quote(
    quoteId: 'quote-123',
    customerId: 'cust-123',
    vehicleId: 'VIN12345678901234',
    status: 'draft',
    totalAmount: 150.0,
    draftedAt: DateTime(2026, 1, 1),
    validUntil: DateTime(2026, 2, 1),
  );

  final tCustomer = Customer(
    id: 'cust-123',
    name: 'John Doe',
    customerType: 'individual',
    billingAddress: '123 Main St',
    taxExempt: false,
  );

  final tVehicle = Vehicle(
    vin: 'VIN12345678901234',
    customerId: 'cust-123',
    make: 'Toyota',
    model: 'Corolla',
    year: 2020,
    currentMileage: 50000,
  );

  setUp(() {
    mockGetQuotesUseCase = MockGetQuotesUseCase();
    mockCreateQuoteUseCase = MockCreateQuoteUseCase();
    mockUpdateQuoteUseCase = MockUpdateQuoteUseCase();
    mockGetCustomersUseCase = MockGetCustomersUseCase();
    mockGetVehiclesUseCase = MockGetVehiclesUseCase();

    quoteBloc = QuoteBloc(
      getQuotesUseCase: mockGetQuotesUseCase,
      createQuoteUseCase: mockCreateQuoteUseCase,
      updateQuoteUseCase: mockUpdateQuoteUseCase,
      getCustomersUseCase: mockGetCustomersUseCase,
      getVehiclesUseCase: mockGetVehiclesUseCase,
    );
  });

  tearDown(() {
    quoteBloc.close();
  });

  group('FetchQuotes', () {
    blocTest<QuoteBloc, QuoteState>(
      'should emit [QuoteLoading, QuotesLoaded] with enriched names when quotes fetched successfully',
      build: () {
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetVehiclesUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tVehicle]));
        when(() => mockGetQuotesUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tQuote]));
        return quoteBloc;
      },
      act: (bloc) => bloc.add(const FetchQuotes()),
      expect: () => [
        QuoteLoading(),
        QuotesLoaded(
          quotes: [
            Quote(
              quoteId: 'quote-123',
              customerId: 'cust-123',
              vehicleId: 'VIN12345678901234',
              status: 'draft',
              totalAmount: 150.0,
              draftedAt: DateTime(2026, 1, 1),
              validUntil: DateTime(2026, 2, 1),
              customerName: 'John Doe',
              vehicleName: '2020 Toyota Corolla',
            )
          ],
          customerNames: const {'cust-123': 'John Doe'},
          vehicleNames: const {'VIN12345678901234': '2020 Toyota Corolla'},
        ),
      ],
    );
  });
}
