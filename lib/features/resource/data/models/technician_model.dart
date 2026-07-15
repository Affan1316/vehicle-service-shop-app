import '../../domain/entities/technician.dart';

class TechnicianModel extends Technician {
  const TechnicianModel({
    required super.techId,
    required super.name,
    required super.hourlyRate,
  });

  factory TechnicianModel.fromJson(Map<String, dynamic> json) {
    final rawRate = json['hourly_rate'];
    double parsedRate = 0.0;
    if (rawRate is String) {
      parsedRate = double.parse(rawRate);
    } else if (rawRate is num) {
      parsedRate = rawRate.toDouble();
    }

    return TechnicianModel(
      techId: json['tech_id'] as String,
      name: json['name'] as String,
      hourlyRate: parsedRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tech_id': techId,
      'name': name,
      'hourly_rate': hourlyRate,
    };
  }
}
