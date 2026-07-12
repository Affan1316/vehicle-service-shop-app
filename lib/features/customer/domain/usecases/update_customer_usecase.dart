import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomerUseCase {
  final CustomerRepository _repository;

  UpdateCustomerUseCase(this._repository);

  Future<Either<Failure, Customer>> call({
    required String id,
    String? name,
    String? customerType,
    String? billingAddress,
    bool? taxExempt,
  }) async {
    return _repository.updateCustomer(
      id: id,
      name: name,
      customerType: customerType,
      billingAddress: billingAddress,
      taxExempt: taxExempt,
    );
  }
}
