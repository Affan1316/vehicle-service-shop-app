import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wheels_doc/features/customer/domain/entities/customer.dart';
import 'package:wheels_doc/features/customer/domain/usecases/get_customers_usecase.dart';
import 'package:wheels_doc/features/job/domain/entities/work_order.dart';
import 'package:wheels_doc/features/job/domain/usecases/get_work_orders.dart';
import 'package:wheels_doc/features/billing/domain/entities/invoice.dart';
import 'package:wheels_doc/features/billing/domain/usecases/create_deposit.dart';
import 'package:wheels_doc/features/billing/domain/usecases/create_invoice.dart';
import 'package:wheels_doc/features/billing/domain/usecases/create_payment.dart';
import 'package:wheels_doc/features/billing/domain/usecases/get_invoices.dart';
import 'package:wheels_doc/features/billing/domain/usecases/update_invoice.dart';
import 'package:wheels_doc/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:wheels_doc/features/billing/presentation/bloc/billing_event.dart';
import 'package:wheels_doc/features/billing/presentation/bloc/billing_state.dart';

class MockGetInvoicesUseCase extends Mock implements GetInvoicesUseCase {}
class MockCreateInvoiceUseCase extends Mock implements CreateInvoiceUseCase {}
class MockUpdateInvoiceUseCase extends Mock implements UpdateInvoiceUseCase {}
class MockCreatePaymentUseCase extends Mock implements CreatePaymentUseCase {}
class MockCreateDepositUseCase extends Mock implements CreateDepositUseCase {}
class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}
class MockGetWorkOrdersUseCase extends Mock implements GetWorkOrdersUseCase {}

void main() {
  late BillingBloc billingBloc;
  late MockGetInvoicesUseCase mockGetInvoicesUseCase;
  late MockCreateInvoiceUseCase mockCreateInvoiceUseCase;
  late MockUpdateInvoiceUseCase mockUpdateInvoiceUseCase;
  late MockCreatePaymentUseCase mockCreatePaymentUseCase;
  late MockCreateDepositUseCase mockCreateDepositUseCase;
  late MockGetCustomersUseCase mockGetCustomersUseCase;
  late MockGetWorkOrdersUseCase mockGetWorkOrdersUseCase;

  final tInvoice = Invoice(
    invoiceId: 'inv-123',
    workOrderId: 'wo-123',
    customerId: 'cust-123',
    status: 'issued',
    amountDue: 500.0,
    totalBalance: 500.0,
    issuedAt: DateTime(2026, 1, 1),
  );

  final tCustomer = Customer(
    id: 'cust-123',
    name: 'Jane Doe',
    customerType: 'individual',
    billingAddress: '456 Oak St',
    taxExempt: false,
  );

  final tWorkOrder = WorkOrder(
    workOrderId: 'wo-123',
    quoteId: 'quote-123',
    vehicleId: 'VIN123',
    customerId: 'cust-123',
    status: 'completed',
    authorizedAmount: 500.0,
    createdAt: DateTime(2026, 1, 1),
    totalCost: 500.0,
    lineItems: const [],
  );

  setUp(() {
    mockGetInvoicesUseCase = MockGetInvoicesUseCase();
    mockCreateInvoiceUseCase = MockCreateInvoiceUseCase();
    mockUpdateInvoiceUseCase = MockUpdateInvoiceUseCase();
    mockCreatePaymentUseCase = MockCreatePaymentUseCase();
    mockCreateDepositUseCase = MockCreateDepositUseCase();
    mockGetCustomersUseCase = MockGetCustomersUseCase();
    mockGetWorkOrdersUseCase = MockGetWorkOrdersUseCase();

    billingBloc = BillingBloc(
      getInvoicesUseCase: mockGetInvoicesUseCase,
      createInvoiceUseCase: mockCreateInvoiceUseCase,
      updateInvoiceUseCase: mockUpdateInvoiceUseCase,
      createPaymentUseCase: mockCreatePaymentUseCase,
      createDepositUseCase: mockCreateDepositUseCase,
      getCustomersUseCase: mockGetCustomersUseCase,
      getWorkOrdersUseCase: mockGetWorkOrdersUseCase,
    );
  });

  tearDown(() {
    billingBloc.close();
  });

  group('FetchInvoices', () {
    blocTest<BillingBloc, BillingState>(
      'should emit [BillingLoading, InvoicesLoaded] with enriched lookup data when invoices load successfully',
      build: () {
        when(() => mockGetCustomersUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tCustomer]));
        when(() => mockGetWorkOrdersUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tWorkOrder]));
        when(() => mockGetInvoicesUseCase(limit: any(named: 'limit'), offset: any(named: 'offset')))
            .thenAnswer((_) async => Right([tInvoice]));
        return billingBloc;
      },
      act: (bloc) => bloc.add(const FetchInvoices()),
      expect: () => [
        BillingLoading(),
        InvoicesLoaded(
          invoices: [
            Invoice(
              invoiceId: 'inv-123',
              workOrderId: 'wo-123',
              customerId: 'cust-123',
              status: 'issued',
              amountDue: 500.0,
              totalBalance: 500.0,
              issuedAt: DateTime(2026, 1, 1),
              customerName: 'Jane Doe',
              workOrderNumber: 'WO-WO-12',
            ),
          ],
          customerNames: const {'cust-123': 'Jane Doe'},
          workOrderNumbers: const {'wo-123': 'WO-WO-12'},
        ),
      ],
    );
  });
}
