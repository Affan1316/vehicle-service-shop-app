import '../../../../core/network/api_client.dart';
import '../models/customer_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers({int limit = 50, int offset = 0});
  Future<CustomerModel> getCustomerById(String id);
  Future<CustomerModel> createCustomer({
    required String name,
    required String customerType,
    String? billingAddress,
    required bool taxExempt,
  });
  Future<CustomerModel> updateCustomer({
    required String id,
    String? name,
    String? customerType,
    String? billingAddress,
    bool? taxExempt,
  });
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient _client;

  CustomerRemoteDataSourceImpl(this._client);

  @override
  Future<List<CustomerModel>> getCustomers({int limit = 50, int offset = 0}) async {
    final response = await _client.get(
      '/customers',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => CustomerModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<CustomerModel> getCustomerById(String id) async {
    final response = await _client.get('/customers/$id');
    return CustomerModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CustomerModel> createCustomer({
    required String name,
    required String customerType,
    String? billingAddress,
    required bool taxExempt,
  }) async {
    final response = await _client.post(
      '/customers',
      data: {
        'name': name,
        'customer_type': customerType,
        'billing_address': billingAddress,
        'tax_exempt': taxExempt,
      },
    );
    return CustomerModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CustomerModel> updateCustomer({
    required String id,
    String? name,
    String? customerType,
    String? billingAddress,
    bool? taxExempt,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (customerType != null) data['customer_type'] = customerType;
    if (billingAddress != null) data['billing_address'] = billingAddress;
    if (taxExempt != null) data['tax_exempt'] = taxExempt;

    final response = await _client.put(
      '/customers/$id',
      data: data,
    );
    return CustomerModel.fromJson(response.data as Map<String, dynamic>);
  }
}
