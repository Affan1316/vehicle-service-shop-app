import 'package:equatable/equatable.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomers extends CustomerEvent {
  final int limit;
  final int offset;

  const FetchCustomers({this.limit = 50, this.offset = 0});

  @override
  List<Object?> get props => [limit, offset];
}

class FetchCustomerDetails extends CustomerEvent {
  final String customerId;

  const FetchCustomerDetails(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class CreateCustomer extends CustomerEvent {
  final String name;
  final String customerType;
  final String? billingAddress;
  final bool taxExempt;

  const CreateCustomer({
    required this.name,
    required this.customerType,
    this.billingAddress,
    required this.taxExempt,
  });

  @override
  List<Object?> get props => [name, customerType, billingAddress, taxExempt];
}

class UpdateCustomer extends CustomerEvent {
  final String id;
  final String? name;
  final String? customerType;
  final String? billingAddress;
  final bool? taxExempt;

  const UpdateCustomer({
    required this.id,
    this.name,
    this.customerType,
    this.billingAddress,
    this.taxExempt,
  });

  @override
  List<Object?> get props => [id, name, customerType, billingAddress, taxExempt];
}
