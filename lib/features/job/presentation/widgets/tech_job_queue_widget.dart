import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/line_item.dart';
import '../../domain/entities/work_order.dart';
import '../bloc/job_bloc.dart';
import '../bloc/job_event.dart';
import '../bloc/job_state.dart';
import '../bloc/labor_bloc.dart';
import '../bloc/labor_event.dart';

class TechJobQueueWidget extends StatefulWidget {
  const TechJobQueueWidget({super.key});

  @override
  State<TechJobQueueWidget> createState() => _TechJobQueueWidgetState();
}

class _CheckInTimeTracker {
  final String lineItemId;
  final DateTime startTime;

  _CheckInTimeTracker({required this.lineItemId, required this.startTime});
}

class _TechJobQueueWidgetState extends State<TechJobQueueWidget> {
  final List<_CheckInTimeTracker> _activeTrackers = [];
  String? _expandedWorkOrderId;

  void _startTracking(String lineItemId) {
    setState(() {
      _activeTrackers.add(
        _CheckInTimeTracker(lineItemId: lineItemId, startTime: DateTime.now()),
      );
    });
  }

  _CheckInTimeTracker? _getTracker(String lineItemId) {
    for (final tracker in _activeTrackers) {
      if (tracker.lineItemId == lineItemId) return tracker;
    }
    return null;
  }

  void _stopTracking(String lineItemId) {
    setState(() {
      _activeTrackers.removeWhere((t) => t.lineItemId == lineItemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    final techId = authState.user.techId;
    if (techId == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.circleAlert, color: AppColors.warningBorder),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No Technician Profile linked to this account. Unable to log labor hours.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.warningText),
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        if (state is JobLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is JobError) {
          return Center(
            child: Text(
              'Error loading queue: ${state.message}',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.dangerText),
            ),
          );
        }

        if (state is WorkOrdersLoaded) {
          final activeOrders = state.workOrders
              .where((wo) =>
                  wo.status == 'created' ||
                  wo.status == 'scheduled' ||
                  wo.status == 'active' ||
                  wo.status == 'paused')
              .toList();

          if (activeOrders.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.clipboardCheck, color: AppColors.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No active jobs in queue',
                      style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDefault),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.listTodo, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          'Technician Job Queue',
                          style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Text(
                      '${activeOrders.length} Pending',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final wo = activeOrders[index];
                    final isExpanded = _expandedWorkOrderId == wo.workOrderId;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isExpanded ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderDefault,
                        ),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(LucideIcons.car, color: AppColors.primary, size: 20),
                            ),
                            title: Text(
                              'WO-${wo.workOrderId.substring(0, 5).toUpperCase()}',
                              style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            subtitle: Text(
                              'VIN: ${wo.vehicleId.toUpperCase()}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildStatusBadge(wo.status),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _expandedWorkOrderId = isExpanded ? null : wo.workOrderId;
                              });
                            },
                          ),
                          if (isExpanded) ...[
                            const Divider(color: AppColors.borderDefault, height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tasks / Line Items',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (wo.lineItems.isEmpty)
                                    Text(
                                      'No tasks assigned to this work order.',
                                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: wo.lineItems.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                                      itemBuilder: (context, liIndex) {
                                        final li = wo.lineItems[liIndex];
                                        return _buildLineItemRow(context, wo, li, techId);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLineItemRow(BuildContext context, WorkOrder wo, LineItem li, String techId) {
    final tracker = _getTracker(li.lineItemId);
    final isWorking = tracker != null || li.status == 'in_progress';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  li.description,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    decoration: li.status == 'completed' ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: li.billingMode == 'hourly'
                            ? AppColors.infoBg.withValues(alpha: 0.2)
                            : AppColors.successBg.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        li.billingMode.toUpperCase(),
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 9,
                          color: li.billingMode == 'hourly' ? AppColors.infoText : AppColors.successText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildLineItemStatusBadge(li.status),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (li.status != 'completed') ...[
            if (!isWorking)
              SizedBox(
                width: 110,
                height: 36,
                child: AppButton(
                  text: 'Start Work',
                  onPressed: () {
                    context.read<JobBloc>().add(
                          UpdateLineItemProgressEvent(
                            lineItemId: li.lineItemId,
                            status: 'in_progress',
                            startedAt: DateTime.now(),
                          ),
                        );
                    _startTracking(li.lineItemId);
                  },
                ),
              )
            else
              SizedBox(
                width: 110,
                height: 36,
                child: AppButton(
                  text: 'Clock Out',
                  isSecondary: true,
                  onPressed: () => _showClockOutDialog(context, wo, li, techId, tracker?.startTime),
                ),
              ),
          ] else
            const Row(
              children: [
                Icon(LucideIcons.circleCheck, color: AppColors.successText, size: 18),
                SizedBox(width: 4),
                Text(
                  'Done',
                  style: TextStyle(color: AppColors.successText, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showClockOutDialog(
    BuildContext context,
    WorkOrder wo,
    LineItem li,
    String techId,
    DateTime? startTime,
  ) {
    final hoursController = TextEditingController();
    double suggestedHours = 1.0;

    if (startTime != null) {
      final diff = DateTime.now().difference(startTime);
      final elapsedHours = diff.inMinutes / 60.0;
      if (elapsedHours > 0.05) {
        suggestedHours = double.parse(elapsedHours.toStringAsFixed(2));
      }
    }
    hoursController.text = suggestedHours.toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(
            'Clock Out & Log Labor',
            style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task: ${li.description}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirmed Hours worked:',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: hoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  suffixText: 'Hours',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final double? confirmedHours = double.tryParse(hoursController.text);
                if (confirmedHours == null || confirmedHours <= 0) return;

                // Log the labor entry
                context.read<LaborBloc>().add(
                      AddLaborEntry(
                        workOrderId: wo.workOrderId,
                        techId: techId,
                        lineItemId: li.lineItemId,
                        workDate: DateTime.now(),
                        hours: confirmedHours,
                      ),
                    );

                // Update line item to completed
                context.read<JobBloc>().add(
                      UpdateLineItemProgressEvent(
                        lineItemId: li.lineItemId,
                        status: 'completed',
                        completedAt: DateTime.now(),
                      ),
                    );

                _stopTracking(li.lineItemId);
                Navigator.pop(dialogContext);
              },
              child: const Text('Submit & Done', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = AppColors.textSecondary;
    switch (status) {
      case 'created':
        color = AppColors.infoBorder;
        break;
      case 'scheduled':
        color = AppColors.primary;
        break;
      case 'active':
        color = AppColors.successBorder;
        break;
      case 'paused':
        color = AppColors.warningBorder;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLineItemStatusBadge(String status) {
    Color color = AppColors.textSecondary;
    switch (status) {
      case 'not_started':
        color = AppColors.textDisabled;
        break;
      case 'in_progress':
        color = AppColors.infoBorder;
        break;
      case 'on_hold':
        color = AppColors.warningBorder;
        break;
      case 'completed':
        color = AppColors.successBorder;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
      ),
    );
  }
}
