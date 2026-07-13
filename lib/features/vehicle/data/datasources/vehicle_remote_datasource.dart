import '../../../../core/network/api_client.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getVehicles({int limit = 50, int offset = 0});
  Future<VehicleModel> getVehicleByVin(String vin);
  Future<VehicleModel> registerVehicle({
    required String vin,
    required String customerId,
    required String make,
    required String model,
    required int year,
    required int currentMileage,
  });
  Future<VehicleModel> updateVehicle(
    String vin, {
    String? make,
    String? model,
    int? year,
    int? currentMileage,
  });
  Future<void> deleteVehicle(String vin);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final ApiClient _client;

  VehicleRemoteDataSourceImpl(this._client);

  @override
  Future<List<VehicleModel>> getVehicles({int limit = 50, int offset = 0}) async {
    final response = await _client.get(
      '/vehicles',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;
    return items.map((item) => VehicleModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<VehicleModel> getVehicleByVin(String vin) async {
    final response = await _client.get('/vehicles/$vin');
    return VehicleModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<VehicleModel> registerVehicle({
    required String vin,
    required String customerId,
    required String make,
    required String model,
    required int year,
    required int currentMileage,
  }) async {
    final response = await _client.post(
      '/vehicles',
      data: {
        'vin': vin,
        'customer_id': customerId,
        'make': make,
        'model': model,
        'year': year,
        'current_mileage': currentMileage,
      },
    );
    return VehicleModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<VehicleModel> updateVehicle(
    String vin, {
    String? make,
    String? model,
    int? year,
    int? currentMileage,
  }) async {
    final Map<String, dynamic> data = {};
    if (make != null) data['make'] = make;
    if (model != null) data['model'] = model;
    if (year != null) data['year'] = year;
    if (currentMileage != null) data['current_mileage'] = currentMileage;

    final response = await _client.put(
      '/vehicles/$vin',
      data: data,
    );
    return VehicleModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteVehicle(String vin) async {
    await _client.delete('/vehicles/$vin');
  }
}
