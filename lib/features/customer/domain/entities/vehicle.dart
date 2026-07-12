class Vehicle {
  final String vin;
  final String customerId;
  final String make;
  final String model;
  final int year;
  final int currentMileage;

  const Vehicle({
    required this.vin,
    required this.customerId,
    required this.make,
    required this.model,
    required this.year,
    required this.currentMileage,
  });
}
