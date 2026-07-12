import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers({
    int limit = 50,
    int offset = 0,
  });

  Future<Either<Failure, Customer>> getCustomerById(String id);

  Future<Either<Failure, Customer>> createCustomer({
    required String name,
    required String customerType,
    String? billingAddress,
    required bool taxExempt,
  });

  Future<Either<Failure, Customer>> updateCustomer({
    required String id,
    String? name,
    String? customerType,
    String? billingAddress,
    bool? taxExempt,
  });
}
