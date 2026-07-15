import 'package:equatable/equatable.dart';
import '../../domain/entities/invoice.dart';

abstract class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class InvoicesLoaded extends BillingState {
  final List<Invoice> invoices;
  final Map<String, String> customerNames;
  final Map<String, String> workOrderNumbers;

  const InvoicesLoaded({
    required this.invoices,
    required this.customerNames,
    required this.workOrderNumbers,
  });

  @override
  List<Object?> get props => [invoices, customerNames, workOrderNumbers];
}

class BillingOperationSuccess extends BillingState {
  final String message;

  const BillingOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BillingError extends BillingState {
  final String message;

  const BillingError(this.message);

  @override
  List<Object?> get props => [message];
}
