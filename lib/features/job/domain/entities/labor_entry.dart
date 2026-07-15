import 'package:equatable/equatable.dart';

class LaborEntry extends Equatable {
  final String laborEntryId;
  final String techId;
  final String lineItemId;
  final DateTime workDate;
  final double hours;

  const LaborEntry({
    required this.laborEntryId,
    required this.techId,
    required this.lineItemId,
    required this.workDate,
    required this.hours,
  });

  @override
  List<Object?> get props => [
        laborEntryId,
        techId,
        lineItemId,
        workDate,
        hours,
      ];
}
