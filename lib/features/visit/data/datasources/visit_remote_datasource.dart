import '../../../../core/network/api_client.dart';
import '../models/visit_model.dart';

abstract class VisitRemoteDataSource {
  Future<List<VisitModel>> getVisits({int limit = 50, int offset = 0});
  Future<VisitModel> createVisit({
    required String vehicleId,
    required String customerId,
    String? appointmentId,
  });
  Future<VisitModel> updateVisit(
    String visitId, {
    String? status,
    DateTime? checkedOutAt,
  });
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final ApiClient _client;

  VisitRemoteDataSourceImpl(this._client);

  @override
  Future<List<VisitModel>> getVisits({int limit = 50, int offset = 0}) async {
    final response = await _client.get(
      '/visits',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => VisitModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<VisitModel> createVisit({
    required String vehicleId,
    required String customerId,
    String? appointmentId,
  }) async {
    final Map<String, dynamic> body = {
      'vehicle_id': vehicleId,
      'customer_id': customerId,
    };
    if (appointmentId != null) {
      body['appointment_id'] = appointmentId;
    }

    final response = await _client.post(
      '/visits',
      data: body,
    );
    return VisitModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<VisitModel> updateVisit(
    String visitId, {
    String? status,
    DateTime? checkedOutAt,
  }) async {
    final Map<String, dynamic> body = {};
    if (status != null) {
      body['status'] = status;
    }
    if (checkedOutAt != null) {
      body['checked_out_at'] = checkedOutAt.toIso8601String();
    }

    final response = await _client.put(
      '/visits/$visitId',
      data: body,
    );
    return VisitModel.fromJson(response.data as Map<String, dynamic>);
  }
}
