class Customer {
  final String id;
  final String name;
  final String customerType;
  final String? billingAddress;
  final bool taxExempt;

  const Customer({
    required this.id,
    required this.name,
    required this.customerType,
    this.billingAddress,
    required this.taxExempt,
  });
}
