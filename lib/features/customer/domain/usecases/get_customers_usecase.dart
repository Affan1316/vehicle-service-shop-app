import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository _repository;

  GetCustomersUseCase(this._repository);

  Future<Either<Failure, List<Customer>>> call({
    int limit = 50,
    int offset = 0,
  }) async {
    return _repository.getCustomers(limit: limit, offset: offset);
  }
}
