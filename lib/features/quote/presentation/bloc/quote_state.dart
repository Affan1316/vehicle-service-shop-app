import 'package:equatable/equatable.dart';
import '../../domain/entities/quote.dart';

abstract class QuoteState extends Equatable {
  const QuoteState();

  @override
  List<Object?> get props => [];
}

class QuoteInitial extends QuoteState {}

class QuoteLoading extends QuoteState {}

class QuotesLoaded extends QuoteState {
  final List<Quote> quotes;
  final Map<String, String> customerNames;
  final Map<String, String> vehicleNames;

  const QuotesLoaded({
    required this.quotes,
    required this.customerNames,
    required this.vehicleNames,
  });

  @override
  List<Object?> get props => [quotes, customerNames, vehicleNames];
}

class QuoteOperationSuccess extends QuoteState {
  final String message;

  const QuoteOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class QuoteError extends QuoteState {
  final String message;

  const QuoteError(this.message);

  @override
  List<Object?> get props => [message];
}
