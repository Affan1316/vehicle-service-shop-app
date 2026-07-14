import '../../../../core/network/api_client.dart';
import '../models/work_order_model.dart';
import '../models/line_item_model.dart';

abstract class JobRemoteDataSource {
  Future<List<WorkOrderModel>> getWorkOrders({int limit = 100, int offset = 0});

  Future<WorkOrderModel> createWorkOrder({
    required String quoteId,
    required String vehicleId,
    required String customerId,
    required double authorizedAmount,
    String? visitId,
    DateTime? promisedDate,
  });

  Future<WorkOrderModel> updateWorkOrder(
    String workOrderId, {
    String? status,
    String? bayId,
    double? authorizedAmount,
    DateTime? promisedDate,
    DateTime? scheduledAt,
    DateTime? pausedAt,
    String? pauseReason,
    DateTime? closedAt,
    DateTime? archivedAt,
  });

  Future<LineItemModel> createLineItem(
    String workOrderId, {
    required String description,
    required String billingMode,
    required double price,
    required String status,
  });

  Future<LineItemModel> updateLineItem(
    String lineItemId, {
    String? description,
    String? billingMode,
    double? price,
    String? status,
    String? holdReason,
    DateTime? startedAt,
    DateTime? completedAt,
  });
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final ApiClient _client;

  JobRemoteDataSourceImpl(this._client);

  @override
  Future<List<WorkOrderModel>> getWorkOrders({int limit = 100, int offset = 0}) async {
    final response = await _client.get(
      '/work-orders',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => WorkOrderModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<WorkOrderModel> createWorkOrder({
    required String quoteId,
    required String vehicleId,
    required String customerId,
    required double authorizedAmount,
    String? visitId,
    DateTime? promisedDate,
  }) async {
    final Map<String, dynamic> body = {
      'quote_id': quoteId,
      'vehicle_id': vehicleId,
      'customer_id': customerId,
      'authorized_amount': authorizedAmount,
      'status': 'created',
    };
    if (visitId != null) {
      body['visit_id'] = visitId;
    }
    if (promisedDate != null) {
      body['promised_date'] = promisedDate.toIso8601String().substring(0, 10);
    }

    final response = await _client.post(
      '/work-orders',
      data: body,
    );
    return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<WorkOrderModel> updateWorkOrder(
    String workOrderId, {
    String? status,
    String? bayId,
    double? authorizedAmount,
    DateTime? promisedDate,
    DateTime? scheduledAt,
    DateTime? pausedAt,
    String? pauseReason,
    DateTime? closedAt,
    DateTime? archivedAt,
  }) async {
    final Map<String, dynamic> body = {};
    if (status != null) body['status'] = status;
    if (bayId != null) body['bay_id'] = bayId;
    if (authorizedAmount != null) body['authorized_amount'] = authorizedAmount;
    if (promisedDate != null) body['promised_date'] = promisedDate.toIso8601String().substring(0, 10);
    if (scheduledAt != null) body['scheduled_at'] = scheduledAt.toIso8601String();
    if (pausedAt != null) body['paused_at'] = pausedAt.toIso8601String();
    if (pauseReason != null) body['pause_reason'] = pauseReason;
    if (closedAt != null) body['closed_at'] = closedAt.toIso8601String();
    if (archivedAt != null) body['archived_at'] = archivedAt.toIso8601String();

    final response = await _client.put(
      '/work-orders/$workOrderId',
      data: body,
    );
    return WorkOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<LineItemModel> createLineItem(
    String workOrderId, {
    required String description,
    required String billingMode,
    required double price,
    required String status,
  }) async {
    final Map<String, dynamic> body = {
      'work_order_id': workOrderId,
      'description': description,
      'billing_mode': billingMode,
      'price': price,
      'status': status,
    };

    final response = await _client.post(
      '/work-orders/$workOrderId/line-items',
      data: body,
    );
    return LineItemModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<LineItemModel> updateLineItem(
    String lineItemId, {
    String? description,
    String? billingMode,
    double? price,
    String? status,
    String? holdReason,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final Map<String, dynamic> body = {};
    if (description != null) body['description'] = description;
    if (billingMode != null) body['billing_mode'] = billingMode;
    if (price != null) body['price'] = price;
    if (status != null) body['status'] = status;
    if (holdReason != null) body['hold_reason'] = holdReason;
    if (startedAt != null) body['started_at'] = startedAt.toIso8601String();
    if (completedAt != null) body['completed_at'] = completedAt.toIso8601String();

    final response = await _client.put(
      '/line-items/$lineItemId',
      data: body,
    );
    return LineItemModel.fromJson(response.data as Map<String, dynamic>);
  }
}
