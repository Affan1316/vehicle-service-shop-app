import 'package:equatable/equatable.dart';

class Visit extends Equatable {
  final String visitId;
  final String vehicleId;
  final String customerId;
  final String? appointmentId;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final String status;
  final bool isActive;
  final String? customerName;
  final String? vehicleName;

  const Visit({
    required this.visitId,
    required this.vehicleId,
    required this.customerId,
    this.appointmentId,
    required this.checkedInAt,
    this.checkedOutAt,
    required this.status,
    required this.isActive,
    this.customerName,
    this.vehicleName,
  });

  @override
  List<Object?> get props => [
        visitId,
        vehicleId,
        customerId,
        appointmentId,
        checkedInAt,
        checkedOutAt,
        status,
        isActive,
        customerName,
        vehicleName,
      ];
}
