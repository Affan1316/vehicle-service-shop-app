import '../../domain/entities/labor_entry.dart';

class LaborEntryModel extends LaborEntry {
  const LaborEntryModel({
    required super.laborEntryId,
    required super.techId,
    required super.lineItemId,
    required super.workDate,
    required super.hours,
  });

  factory LaborEntryModel.fromJson(Map<String, dynamic> json) {
    final rawHours = json['hours'];
    double parsedHours = 0.0;
    if (rawHours is String) {
      parsedHours = double.parse(rawHours);
    } else if (rawHours is num) {
      parsedHours = rawHours.toDouble();
    }

    return LaborEntryModel(
      laborEntryId: json['labor_entry_id'] as String,
      techId: json['tech_id'] as String,
      lineItemId: json['line_item_id'] as String,
      workDate: DateTime.parse(json['work_date'] as String),
      hours: parsedHours,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'labor_entry_id': laborEntryId,
      'tech_id': techId,
      'line_item_id': lineItemId,
      'work_date': '${workDate.year.toString().padLeft(4, '0')}-${workDate.month.toString().padLeft(2, '0')}-${workDate.day.toString().padLeft(2, '0')}',
      'hours': hours,
    };
  }
}
