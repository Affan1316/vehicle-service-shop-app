import '../../../../core/network/api_client.dart';
import '../models/quote_model.dart';

abstract class QuoteRemoteDataSource {
  Future<List<QuoteModel>> getQuotes({int limit = 50, int offset = 0});
  Future<QuoteModel> createQuote({
    required String customerId,
    required String vehicleId,
    String? visitId,
    required double totalAmount,
    required DateTime validUntil,
  });
  Future<QuoteModel> updateQuote(
    String quoteId, {
    String? status,
    double? totalAmount,
    DateTime? validUntil,
    DateTime? issuedAt,
    String? declineReason,
  });
}

class QuoteRemoteDataSourceImpl implements QuoteRemoteDataSource {
  final ApiClient _client;

  QuoteRemoteDataSourceImpl(this._client);

  @override
  Future<List<QuoteModel>> getQuotes({int limit = 50, int offset = 0}) async {
    final response = await _client.get(
      '/quotes',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => QuoteModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<QuoteModel> createQuote({
    required String customerId,
    required String vehicleId,
    String? visitId,
    required double totalAmount,
    required DateTime validUntil,
  }) async {
    final response = await _client.post(
      '/quotes',
      data: {
        'customer_id': customerId,
        'vehicle_id': vehicleId,
        'visit_id': visitId,
        'total_amount': totalAmount,
        'valid_until': '${validUntil.year}-${validUntil.month.toString().padLeft(2, '0')}-${validUntil.day.toString().padLeft(2, '0')}',
      },
    );
    return QuoteModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<QuoteModel> updateQuote(
    String quoteId, {
    String? status,
    double? totalAmount,
    DateTime? validUntil,
    DateTime? issuedAt,
    String? declineReason,
  }) async {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (totalAmount != null) data['total_amount'] = totalAmount;
    if (validUntil != null) {
      data['valid_until'] = '${validUntil.year}-${validUntil.month.toString().padLeft(2, '0')}-${validUntil.day.toString().padLeft(2, '0')}';
    }
    if (issuedAt != null) data['issued_at'] = issuedAt.toIso8601String();
    if (declineReason != null) data['decline_reason'] = declineReason;

    final response = await _client.put(
      '/quotes/$quoteId',
      data: data,
    );
    return QuoteModel.fromJson(response.data as Map<String, dynamic>);
  }
}
