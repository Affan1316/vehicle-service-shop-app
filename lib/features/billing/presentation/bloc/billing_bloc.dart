import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/domain/usecases/get_customers_usecase.dart';
import '../../../job/domain/usecases/get_work_orders.dart';
import '../../domain/usecases/create_deposit.dart';
import '../../domain/usecases/create_invoice.dart';
import '../../domain/usecases/create_payment.dart';
import '../../domain/usecases/get_invoices.dart';
import '../../domain/usecases/update_invoice.dart';
import '../../domain/entities/invoice.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetInvoicesUseCase _getInvoicesUseCase;
  final CreateInvoiceUseCase _createInvoiceUseCase;
  final UpdateInvoiceUseCase _updateInvoiceUseCase;
  final CreatePaymentUseCase _createPaymentUseCase;
  final CreateDepositUseCase _createDepositUseCase;
  final GetCustomersUseCase _getCustomersUseCase;
  final GetWorkOrdersUseCase _getWorkOrdersUseCase;

  Map<String, String> _customerNames = {};
  Map<String, String> _workOrderNumbers = {};

  BillingBloc({
    required GetInvoicesUseCase getInvoicesUseCase,
    required CreateInvoiceUseCase createInvoiceUseCase,
    required UpdateInvoiceUseCase updateInvoiceUseCase,
    required CreatePaymentUseCase createPaymentUseCase,
    required CreateDepositUseCase createDepositUseCase,
    required GetCustomersUseCase getCustomersUseCase,
    required GetWorkOrdersUseCase getWorkOrdersUseCase,
  })  : _getInvoicesUseCase = getInvoicesUseCase,
        _createInvoiceUseCase = createInvoiceUseCase,
        _updateInvoiceUseCase = updateInvoiceUseCase,
        _createPaymentUseCase = createPaymentUseCase,
        _createDepositUseCase = createDepositUseCase,
        _getCustomersUseCase = getCustomersUseCase,
        _getWorkOrdersUseCase = getWorkOrdersUseCase,
        super(BillingInitial()) {
    on<FetchInvoices>(_onFetchInvoices);
    on<CreateInvoiceEvent>(_onCreateInvoice);
    on<UpdateInvoiceStatusEvent>(_onUpdateInvoiceStatus);
    on<RecordPaymentEvent>(_onRecordPayment);
    on<RecordDepositEvent>(_onRecordDeposit);
  }

  Future<void> _onFetchInvoices(
    FetchInvoices event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());

    if (_customerNames.isEmpty || _workOrderNumbers.isEmpty || event.forceRefresh) {
      final customersRes = await _getCustomersUseCase(limit: 100);
      customersRes.fold(
        (failure) {},
        (customers) {
          _customerNames = {for (var c in customers) c.id: c.name};
        },
      );

      final workOrdersRes = await _getWorkOrdersUseCase(limit: 100);
      workOrdersRes.fold(
        (failure) {},
        (orders) {
          _workOrderNumbers = {for (var o in orders) o.workOrderId: 'WO-${o.workOrderId.substring(0, 5).toUpperCase()}'};
        },
      );
    }

    final invoicesRes = await _getInvoicesUseCase(limit: 100);
    invoicesRes.fold(
      (failure) => emit(BillingError(failure.message)),
      (invoiceList) {
        final enrichedInvoices = invoiceList.map((inv) {
          return Invoice(
            invoiceId: inv.invoiceId,
            workOrderId: inv.workOrderId,
            customerId: inv.customerId,
            status: inv.status,
            amountDue: inv.amountDue,
            totalBalance: inv.totalBalance,
            issuedAt: inv.issuedAt,
            warrantyId: inv.warrantyId,
            creditAmount: inv.creditAmount,
            creditReason: inv.creditReason,
            customerName: _customerNames[inv.customerId] ?? 'Client #${inv.customerId.substring(0, 5)}',
            workOrderNumber: _workOrderNumbers[inv.workOrderId] ?? 'WO-${inv.workOrderId.substring(0, 5).toUpperCase()}',
          );
        }).toList();

        emit(InvoicesLoaded(
          invoices: enrichedInvoices,
          customerNames: _customerNames,
          workOrderNumbers: _workOrderNumbers,
        ));
      },
    );
  }

  Future<void> _onCreateInvoice(
    CreateInvoiceEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    final result = await _createInvoiceUseCase(
      workOrderId: event.workOrderId,
      customerId: event.customerId,
      status: 'issued',
      amountDue: event.amountDue,
    );

    await result.fold(
      (failure) async => emit(BillingError(failure.message)),
      (invoice) async {
        emit(const BillingOperationSuccess('Invoice generated successfully'));
        add(const FetchInvoices(forceRefresh: true));
      },
    );
  }

  Future<void> _onUpdateInvoiceStatus(
    UpdateInvoiceStatusEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    final result = await _updateInvoiceUseCase(
      event.invoiceId,
      status: event.status,
      amountDue: event.amountDue,
      warrantyId: event.warrantyId,
      creditAmount: event.creditAmount,
      creditReason: event.creditReason,
    );

    await result.fold(
      (failure) async => emit(BillingError(failure.message)),
      (invoice) async {
        emit(BillingOperationSuccess('Invoice updated to status: ${event.status}'));
        add(const FetchInvoices(forceRefresh: true));
      },
    );
  }

  Future<void> _onRecordPayment(
    RecordPaymentEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    final result = await _createPaymentUseCase(
      invoiceId: event.invoiceId,
      amount: event.amount,
      method: event.method,
    );

    await result.fold(
      (failure) async => emit(BillingError(failure.message)),
      (payment) async {
        emit(const BillingOperationSuccess('Payment recorded successfully'));
        add(const FetchInvoices(forceRefresh: true));
      },
    );
  }

  Future<void> _onRecordDeposit(
    RecordDepositEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    final result = await _createDepositUseCase(
      quoteId: event.quoteId,
      customerId: event.customerId,
      workOrderId: event.workOrderId,
      amount: event.amount,
    );

    await result.fold(
      (failure) async => emit(BillingError(failure.message)),
      (deposit) async {
        emit(const BillingOperationSuccess('Pre-payment deposit recorded successfully'));
        add(const FetchInvoices(forceRefresh: true));
      },
    );
  }
}
