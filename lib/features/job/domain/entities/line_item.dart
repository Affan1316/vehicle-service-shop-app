import 'package:equatable/equatable.dart';

class LineItem extends Equatable {
  final String lineItemId;
  final String workOrderId;
  final String description;
  final String billingMode;
  final double price;
  final String status;
  final String? holdReason;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const LineItem({
    required this.lineItemId,
    required this.workOrderId,
    required this.description,
    required this.billingMode,
    required this.price,
    required this.status,
    this.holdReason,
    this.startedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        lineItemId,
        workOrderId,
        description,
        billingMode,
        price,
        status,
        holdReason,
        startedAt,
        completedAt,
      ];
}
