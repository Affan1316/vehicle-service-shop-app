import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.customerType,
    super.billingAddress,
    required super.taxExempt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['customer_id'] as String,
      name: json['name'] as String,
      customerType: json['customer_type'] as String,
      billingAddress: json['billing_address'] as String?,
      taxExempt: json['tax_exempt'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': id,
      'name': name,
      'customer_type': customerType,
      'billing_address': billingAddress,
      'tax_exempt': taxExempt,
    };
  }
}
