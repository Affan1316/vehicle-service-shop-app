import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/visit.dart';
import '../bloc/visit_list_bloc.dart';
import '../bloc/visit_list_event.dart';

class VisitDrawerContent extends StatelessWidget {
  final Visit visit;
  final VoidCallback onUpdateSuccess;

  const VisitDrawerContent({
    required this.visit,
    required this.onUpdateSuccess,
    super.key,
  });

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(DateTime start, DateTime? end) {
    final stop = end ?? DateTime.now();
    final diff = stop.difference(start);
    if (diff.inDays > 0) {
      return '${diff.inDays} day(s) ${diff.inHours % 24} hour(s)';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour(s) ${diff.inMinutes % 60} minute(s)';
    } else {
      return '${diff.inMinutes} minute(s)';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'checked_in':
        return AppColors.primary;
      case 'in_diagnosis':
        return AppColors.warningBorder;
      case 'awaiting_quote':
        return Colors.purple;
      case 'in_service':
        return Colors.indigo;
      case 'awaiting_pickup':
        return Colors.teal;
      case 'completed':
        return AppColors.successBorder;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatStatusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  List<String> _getAllowedTransitions(String currentStatus) {
    switch (currentStatus) {
      case 'checked_in':
        return ['checked_in', 'in_diagnosis', 'awaiting_quote', 'in_service'];
      case 'in_diagnosis':
        return ['in_diagnosis', 'awaiting_quote', 'in_service'];
      case 'awaiting_quote':
        return ['awaiting_quote', 'in_service', 'completed'];
      case 'in_service':
        return ['in_service', 'awaiting_pickup'];
      case 'awaiting_pickup':
        return ['awaiting_pickup', 'completed'];
      case 'completed':
        return ['completed'];
      default:
        return [currentStatus];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Role checking
    final authState = context.read<AuthBloc>().state;
    final isAdvisor = authState is Authenticated &&
        (authState.user.role == 'manager' || authState.user.role == 'advisor');

    final bool isCompleted = visit.status == 'completed' || visit.checkedOutAt != null;

    final allowedStatuses = _getAllowedTransitions(visit.status);
    final bool canCheckOut = visit.status == 'awaiting_quote' || visit.status == 'awaiting_pickup';

    return Container(
      width: MediaQuery.of(context).size.width >= 768 ? 400 : double.infinity,
      height: double.infinity,
      color: AppColors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VISIT DETAILS',
                style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
              ),
              IconButton(
                icon: Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(visit.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatStatusLabel(visit.status),
              style: AppTypography.bodySmall.copyWith(
                color: _getStatusColor(visit.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: AppColors.borderDefault),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem('CUSTOMER', visit.customerName ?? 'Unknown Customer'),
                  const SizedBox(height: 16),
                  _buildDetailItem('VEHICLE', visit.vehicleName ?? 'Unknown Vehicle'),
                  const SizedBox(height: 8),
                  Text(
                    'VIN: ${visit.vehicleId}',
                    style: AppTypography.monospace.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailItem('CHECKED IN', _formatDateTime(visit.checkedInAt)),
                  const SizedBox(height: 16),
                  if (isCompleted && visit.checkedOutAt != null) ...[
                    _buildDetailItem('CHECKED OUT', _formatDateTime(visit.checkedOutAt!)),
                    const SizedBox(height: 16),
                    _buildDetailItem(
                      'TOTAL DURATION',
                      _calculateDuration(visit.checkedInAt, visit.checkedOutAt),
                    ),
                  ] else ...[
                    _buildDetailItem(
                      'ACTIVE DURATION',
                      '${_calculateDuration(visit.checkedInAt, null)} (ongoing)',
                    ),
                  ],
                  const SizedBox(height: 28),
                  Divider(color: AppColors.borderDefault),
                  const SizedBox(height: 20),

                  if (isAdvisor && !isCompleted) ...[
                    Text(
                      'UPDATE STATUS',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: visit.status,
                      dropdownColor: AppColors.bgSurface,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: allowedStatuses.map((status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(_formatStatusLabel(status)),
                        );
                      }).toList(),
                      onChanged: (newStatus) {
                        if (newStatus != null && newStatus != visit.status) {
                          final DateTime? checkout =
                              newStatus == 'completed' ? DateTime.now() : null;
                          context.read<VisitListBloc>().add(
                                UpdateVisitStatusEvent(
                                  visitId: visit.visitId,
                                  status: newStatus,
                                  checkedOutAt: checkout,
                                ),
                              );
                          onUpdateSuccess();
                          Navigator.pop(context);
                        }
                      },
                    ),
                    if (canCheckOut) ...[
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Complete & Check Out',
                        onPressed: () {
                          context.read<VisitListBloc>().add(
                                UpdateVisitStatusEvent(
                                  visitId: visit.visitId,
                                  status: 'completed',
                                  checkedOutAt: DateTime.now(),
                                ),
                              );
                          onUpdateSuccess();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
