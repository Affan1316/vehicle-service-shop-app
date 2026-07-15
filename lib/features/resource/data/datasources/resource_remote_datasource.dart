import '../../../../core/network/api_client.dart';
import '../models/bay_model.dart';
import '../models/technician_model.dart';

abstract class ResourceRemoteDataSource {
  Future<List<BayModel>> getBays({int limit = 50, int offset = 0});
  Future<BayModel> updateBay(
    String bayId, {
    String? status,
    String? bayType,
    String? currentWorkOrderId,
    DateTime? heldUntil,
    bool clearWorkOrder = false,
    bool clearHeldUntil = false,
  });
  Future<List<TechnicianModel>> getTechnicians({int limit = 50, int offset = 0});
}

class ResourceRemoteDataSourceImpl implements ResourceRemoteDataSource {
  final ApiClient _client;

  ResourceRemoteDataSourceImpl(this._client);

  @override
  Future<List<BayModel>> getBays({int limit = 50, int offset = 0}) async {
    final response = await _client.get(
      '/bays',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => BayModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<BayModel> updateBay(
    String bayId, {
    String? status,
    String? bayType,
    String? currentWorkOrderId,
    DateTime? heldUntil,
    bool clearWorkOrder = false,
    bool clearHeldUntil = false,
  }) async {
    final Map<String, dynamic> data = {};
    if (status != null) data['status'] = status;
    if (bayType != null) data['bay_type'] = bayType;
    
    if (clearWorkOrder) {
      data['current_work_order_id'] = null;
    } else if (currentWorkOrderId != null) {
      data['current_work_order_id'] = currentWorkOrderId;
    }

    if (clearHeldUntil) {
      data['held_until'] = null;
    } else if (heldUntil != null) {
      data['held_until'] = heldUntil.toIso8601String();
    }

    final response = await _client.put(
      '/bays/$bayId',
      data: data,
    );
    return BayModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<TechnicianModel>> getTechnicians({int limit = 50, int offset = 0}) async {
    final response = await _client.get(
      '/technicians',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => TechnicianModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
