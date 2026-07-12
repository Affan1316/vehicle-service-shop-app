import '../../domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  const VehicleModel({
    required super.vin,
    required super.customerId,
    required super.make,
    required super.model,
    required super.year,
    required super.currentMileage,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      vin: json['vin'] as String,
      customerId: json['customer_id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      currentMileage: (json['current_mileage'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vin': vin,
      'customer_id': customerId,
      'make': make,
      'model': model,
      'year': year,
      'current_mileage': currentMileage,
    };
  }
}
