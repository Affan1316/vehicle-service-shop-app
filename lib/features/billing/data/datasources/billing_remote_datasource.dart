import '../../../../core/network/api_client.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';
import '../models/deposit_model.dart';

abstract class BillingRemoteDataSource {
  Future<List<InvoiceModel>> getInvoices({int limit = 50, int offset = 0});
  Future<InvoiceModel> createInvoice({
    required String workOrderId,
    required String customerId,
    required String status,
    required double amountDue,
  });
  Future<InvoiceModel> updateInvoice(
    String invoiceId, {
    String? status,
    double? amountDue,
    String? warrantyId,
    double? creditAmount,
    String? creditReason,
  });
  Future<PaymentModel> createPayment({
    required String invoiceId,
    required double amount,
    required String method,
  });
  Future<DepositModel> createDeposit({
    required String quoteId,
    required String customerId,
    String? workOrderId,
    required double amount,
  });
}

class BillingRemoteDataSourceImpl implements BillingRemoteDataSource {
  final ApiClient _client;

  BillingRemoteDataSourceImpl(this._client);

  @override
  Future<List<InvoiceModel>> getInvoices({int limit = 50, int offset = 0}) async {
    final response = await _client.get(
      '/invoices',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => InvoiceModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<InvoiceModel> createInvoice({
    required String workOrderId,
    required String customerId,
    required String status,
    required double amountDue,
  }) async {
    final response = await _client.post(
      '/invoices',
      data: {
        'work_order_id': workOrderId,
        'customer_id': customerId,
        'status': status,
        'amount_due': amountDue,
      },
    );
    return InvoiceModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<InvoiceModel> updateInvoice(
    String invoiceId, {
    String? status,
    double? amountDue,
    String? warrantyId,
    double? creditAmount,
    String? creditReason,
  }) async {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (amountDue != null) data['amount_due'] = amountDue;
    if (warrantyId != null) data['warranty_id'] = warrantyId;
    if (creditAmount != null) data['credit_amount'] = creditAmount;
    if (creditReason != null) data['credit_reason'] = creditReason;

    final response = await _client.put(
      '/invoices/$invoiceId',
      data: data,
    );
    return InvoiceModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PaymentModel> createPayment({
    required String invoiceId,
    required double amount,
    required String method,
  }) async {
    final response = await _client.post(
      '/payments',
      data: {
        'invoice_id': invoiceId,
        'amount': amount,
        'method': method,
        'collected_at': DateTime.now().toIso8601String(),
      },
    );
    return PaymentModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<DepositModel> createDeposit({
    required String quoteId,
    required String customerId,
    String? workOrderId,
    required double amount,
  }) async {
    final response = await _client.post(
      '/deposits',
      data: {
        'quote_id': quoteId,
        'customer_id': customerId,
        'work_order_id': workOrderId,
        'amount': amount,
        'collected_at': DateTime.now().toIso8601String(),
      },
    );
    return DepositModel.fromJson(response.data as Map<String, dynamic>);
  }
}
