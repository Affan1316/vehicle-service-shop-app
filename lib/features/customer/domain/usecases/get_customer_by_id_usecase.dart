import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomerByIdUseCase {
  final CustomerRepository _repository;

  GetCustomerByIdUseCase(this._repository);

  Future<Either<Failure, Customer>> call(String id) async {
    return _repository.getCustomerById(id);
  }
}
