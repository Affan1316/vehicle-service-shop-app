import 'package:equatable/equatable.dart';

class Technician extends Equatable {
  final String techId;
  final String name;
  final double hourlyRate;

  const Technician({
    required this.techId,
    required this.name,
    required this.hourlyRate,
  });

  @override
  List<Object?> get props => [techId, name, hourlyRate];
}
