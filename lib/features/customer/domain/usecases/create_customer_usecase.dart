import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CreateCustomerUseCase {
  final CustomerRepository _repository;

  CreateCustomerUseCase(this._repository);

  Future<Either<Failure, Customer>> call({
    required String name,
    required String customerType,
    String? billingAddress,
    required bool taxExempt,
  }) async {
    return _repository.createCustomer(
      name: name,
      customerType: customerType,
      billingAddress: billingAddress,
      taxExempt: taxExempt,
    );
  }
}
