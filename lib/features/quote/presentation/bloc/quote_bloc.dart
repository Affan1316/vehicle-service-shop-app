import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../customer/domain/usecases/get_customers_usecase.dart';
import '../../../vehicle/domain/usecases/get_vehicles_usecase.dart';
import '../../domain/usecases/create_quote.dart';
import '../../domain/usecases/get_quotes.dart';
import '../../domain/usecases/update_quote.dart';
import '../../domain/entities/quote.dart';
import 'quote_event.dart';
import 'quote_state.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  final GetQuotesUseCase _getQuotesUseCase;
  final CreateQuoteUseCase _createQuoteUseCase;
  final UpdateQuoteUseCase _updateQuoteUseCase;
  final GetCustomersUseCase _getCustomersUseCase;
  final GetVehiclesUseCase _getVehiclesUseCase;

  // Cache to avoid duplicate fetch operations
  Map<String, String> _customerNames = {};
  Map<String, String> _vehicleNames = {};

  QuoteBloc({
    required GetQuotesUseCase getQuotesUseCase,
    required CreateQuoteUseCase createQuoteUseCase,
    required UpdateQuoteUseCase updateQuoteUseCase,
    required GetCustomersUseCase getCustomersUseCase,
    required GetVehiclesUseCase getVehiclesUseCase,
  })  : _getQuotesUseCase = getQuotesUseCase,
        _createQuoteUseCase = createQuoteUseCase,
        _updateQuoteUseCase = updateQuoteUseCase,
        _getCustomersUseCase = getCustomersUseCase,
        _getVehiclesUseCase = getVehiclesUseCase,
        super(QuoteInitial()) {
    on<FetchQuotes>(_onFetchQuotes);
    on<CreateQuoteEvent>(_onCreateQuote);
    on<UpdateQuoteStatusEvent>(_onUpdateQuoteStatus);
  }

  Future<void> _onFetchQuotes(
    FetchQuotes event,
    Emitter<QuoteState> emit,
  ) async {
    emit(QuoteLoading());

    // If cache is empty or forceRefresh, load lookups first
    if (_customerNames.isEmpty || _vehicleNames.isEmpty || event.forceRefresh) {
      final customersRes = await _getCustomersUseCase(limit: 100);
      customersRes.fold(
        (failure) {},
        (customers) {
          _customerNames = {for (var c in customers) c.id: c.name};
        },
      );

      final vehiclesRes = await _getVehiclesUseCase(limit: 100);
      vehiclesRes.fold(
        (failure) {},
        (vehicles) {
          _vehicleNames = {for (var v in vehicles) v.vin: '${v.year} ${v.make} ${v.model}'};
        },
      );
    }

    final quotesRes = await _getQuotesUseCase(limit: 100);
    quotesRes.fold(
      (failure) => emit(QuoteError(failure.message)),
      (quotesList) {
        // Enrich quotes list with cached names
        final enrichedQuotes = quotesList.map((q) {
          return Quote(
            quoteId: q.quoteId,
            customerId: q.customerId,
            vehicleId: q.vehicleId,
            visitId: q.visitId,
            status: q.status,
            totalAmount: q.totalAmount,
            draftedAt: q.draftedAt,
            validUntil: q.validUntil,
            issuedAt: q.issuedAt,
            declineReason: q.declineReason,
            customerName: _customerNames[q.customerId] ?? 'Client #${q.customerId.substring(0, 5)}',
            vehicleName: _vehicleNames[q.vehicleId] ?? 'Vehicle #${q.vehicleId.substring(0, 5)}',
          );
        }).toList();

        emit(QuotesLoaded(
          quotes: enrichedQuotes,
          customerNames: _customerNames,
          vehicleNames: _vehicleNames,
        ));
      },
    );
  }

  Future<void> _onCreateQuote(
    CreateQuoteEvent event,
    Emitter<QuoteState> emit,
  ) async {
    emit(QuoteLoading());
    final result = await _createQuoteUseCase(
      customerId: event.customerId,
      vehicleId: event.vehicleId,
      visitId: event.visitId,
      totalAmount: event.totalAmount,
      validUntil: event.validUntil,
    );

    await result.fold(
      (failure) async => emit(QuoteError(failure.message)),
      (quote) async {
        emit(const QuoteOperationSuccess('Quote drafted successfully'));
        add(const FetchQuotes(forceRefresh: true));
      },
    );
  }

  Future<void> _onUpdateQuoteStatus(
    UpdateQuoteStatusEvent event,
    Emitter<QuoteState> emit,
  ) async {
    emit(QuoteLoading());
    final result = await _updateQuoteUseCase(
      event.quoteId,
      status: event.status,
      totalAmount: event.totalAmount,
      validUntil: event.validUntil,
      issuedAt: event.issuedAt,
      declineReason: event.declineReason,
    );

    await result.fold(
      (failure) async => emit(QuoteError(failure.message)),
      (quote) async {
        emit(QuoteOperationSuccess('Quote updated to status: ${event.status}'));
        add(const FetchQuotes(forceRefresh: true));
      },
    );
  }
}
