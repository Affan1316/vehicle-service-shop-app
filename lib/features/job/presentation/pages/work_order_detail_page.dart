import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/work_order.dart';
import '../../domain/entities/line_item.dart';
import '../bloc/job_bloc.dart';
import '../bloc/job_event.dart';
import '../bloc/job_state.dart';

class WorkOrderDetailPage extends StatefulWidget {
  final String workOrderId;

  const WorkOrderDetailPage({super.key, required this.workOrderId});

  @override
  State<WorkOrderDetailPage> createState() => _WorkOrderDetailPageState();
}

class _WorkOrderDetailPageState extends State<WorkOrderDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(const FetchWorkOrders());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'created':
        return Colors.indigoAccent;
      case 'scheduled':
        return Colors.tealAccent;
      case 'active':
        return Colors.orangeAccent;
      case 'paused':
        return Colors.redAccent;
      case 'closed':
        return AppColors.successBorder;
      case 'archived':
        return AppColors.textDisabled;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getLineItemStatusColor(String status) {
    switch (status) {
      case 'not_started':
        return AppColors.textDisabled;
      case 'gated':
        return Colors.purpleAccent;
      case 'in_progress':
        return Colors.orangeAccent;
      case 'on_hold':
        return Colors.redAccent;
      case 'completed':
        return AppColors.successBorder;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatStatusLabel(String status) {
    return status.toUpperCase().replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userRole = authState is Authenticated ? authState.user.role : 'viewer';
    final isStaff = userRole == 'manager' || userRole == 'advisor';

    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        backgroundColor: AppColors.bgDefault,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Job Card Details',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textPrimary),
            onPressed: () => context.read<JobBloc>().add(const FetchWorkOrders(forceRefresh: true)),
          ),
        ],
      ),
      body: BlocConsumer<JobBloc, JobState>(
        listener: (context, state) {
          if (state is JobError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.dangerBorder,
              ),
            );
          } else if (state is WorkOrderOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.successBorder,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is JobLoading || state is JobInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is WorkOrdersLoaded) {
            final workOrders = state.workOrders;
            final woIndex = workOrders.indexWhere((w) => w.workOrderId == widget.workOrderId);
            if (woIndex == -1) {
              return Center(
                child: Text(
                  'Job Card not found.',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.dangerText),
                ),
              );
            }

            final wo = workOrders[woIndex];
            final custName = state.customerNames[wo.customerId] ?? 'Unknown Customer';
            final vehName = state.vehicleNames[wo.vehicleId] ?? 'Unknown Vehicle';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info Card
                  _buildHeaderCard(wo, custName, vehName, isStaff),
                  const SizedBox(height: 24),

                  // Financial summary card
                  _buildFinancialsRow(wo),
                  const SizedBox(height: 32),

                  // Tasks Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SERVICE LINE ITEMS (${wo.lineItems.length})',
                        style: AppTypography.headingSmall.copyWith(letterSpacing: 0.8),
                      ),
                      if (isStaff)
                        TextButton.icon(
                          onPressed: () => _showAddLineItemDialog(context, wo.workOrderId),
                          icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                          label: Text(
                            'Add Task',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tasks List
                  if (wo.lineItems.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Center(
                        child: Text(
                          'No service tasks added to this Job Card yet.',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wo.lineItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = wo.lineItems[index];
                        return _buildLineItemRow(item, userRole);
                      },
                    ),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'Something went wrong.',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.dangerText),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(WorkOrder wo, String customerName, String vehicleName, bool isStaff) {
    final statusColor = _getStatusColor(wo.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleName,
                      style: AppTypography.headingLarge.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'VIN: ${wo.vehicleId}',
                      style: AppTypography.monospace.copyWith(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isStaff)
                DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                    ),
                    child: DropdownButton<String>(
                      value: wo.status,
                      dropdownColor: AppColors.bgSurface,
                      icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.textPrimary),
                      style: AppTypography.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          context.read<JobBloc>().add(
                                UpdateWorkOrderEvent(
                                  workOrderId: wo.workOrderId,
                                  status: val,
                                ),
                              );
                        }
                      },
                      items: <String>['created', 'scheduled', 'active', 'paused', 'closed']
                          .map((val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(
                            val.toUpperCase(),
                            style: TextStyle(color: _getStatusColor(val)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _formatStatusLabel(wo.status),
                    style: AppTypography.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.borderDefault),
          const SizedBox(height: 16),
          _buildInfoRow('CLIENT', customerName),
          const SizedBox(height: 12),
          _buildInfoRow('CREATED AT', wo.createdAt.toIso8601String().substring(0, 10)),
          const SizedBox(height: 12),
          _buildInfoRow('BAY ALLOCATION', wo.bayId ?? 'NOT ASSIGNED'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppTypography.monospace.copyWith(
              color: AppColors.textDisabled,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialsRow(WorkOrder wo) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AUTHORIZED AMOUNT',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${wo.authorizedAmount.toStringAsFixed(2)}',
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL JOB COST',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${wo.totalCost.toStringAsFixed(2)}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: wo.totalCost > wo.authorizedAmount ? Colors.redAccent : AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineItemRow(LineItem item, String userRole) {
    final statusColor = _getLineItemStatusColor(item.status);
    final isTech = userRole == 'technician' || userRole == 'manager';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.billingMode.toUpperCase().replaceAll('_', ' ')}  •  \$${item.price.toStringAsFixed(2)}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 0.5),
                ),
                child: Text(
                  _formatStatusLabel(item.status),
                  style: AppTypography.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          if (item.holdReason != null && item.holdReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.info, color: Colors.redAccent, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hold Reason: ${item.holdReason}',
                      style: AppTypography.bodySmall.copyWith(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isTech) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderDefault, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildTechActionButtons(item),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildTechActionButtons(LineItem item) {
    if (item.status == 'not_started') {
      return [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            context.read<JobBloc>().add(
                  UpdateLineItemProgressEvent(
                    lineItemId: item.lineItemId,
                    status: 'in_progress',
                    startedAt: DateTime.now(),
                  ),
                );
          },
          icon: const Icon(LucideIcons.play, size: 14, color: AppColors.bgDefault),
          label: Text(
            'Start Task',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.bgDefault,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ];
    }

    if (item.status == 'in_progress') {
      return [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () => _showHoldReasonDialog(context, item.lineItemId),
          icon: const Icon(LucideIcons.pause, size: 14, color: Colors.redAccent),
          label: Text(
            'Hold',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successBorder,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            context.read<JobBloc>().add(
                  UpdateLineItemProgressEvent(
                    lineItemId: item.lineItemId,
                    status: 'completed',
                    completedAt: DateTime.now(),
                  ),
                );
          },
          icon: const Icon(LucideIcons.check, size: 14, color: AppColors.bgDefault),
          label: Text(
            'Complete',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.bgDefault,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ];
    }

    if (item.status == 'on_hold') {
      return [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            context.read<JobBloc>().add(
                  UpdateLineItemProgressEvent(
                    lineItemId: item.lineItemId,
                    status: 'in_progress',
                    holdReason: '',
                  ),
                );
          },
          icon: const Icon(LucideIcons.play, size: 14, color: AppColors.bgDefault),
          label: Text(
            'Resume Task',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.bgDefault,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ];
    }

    return [];
  }

  void _showHoldReasonDialog(BuildContext context, String lineItemId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(
            'Hold Task Reason',
            style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Reason for putting task on hold',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Reason required' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<JobBloc>().add(
                        UpdateLineItemProgressEvent(
                          lineItemId: lineItemId,
                          status: 'on_hold',
                          holdReason: reasonController.text.trim(),
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Confirm Hold', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddLineItemDialog(BuildContext context, String workOrderId) {
    final descController = TextEditingController();
    final priceController = TextEditingController();
    String billingMode = 'flat_rate';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.bgSurface,
              title: Text(
                'Add Service Task',
                style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: descController,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Task Description (e.g. Front Brake Pads replacement)',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Description required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: priceController,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price / Cost (\$)',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                      ),
                      validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid price' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Billing Mode:',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                        DropdownButton<String>(
                          value: billingMode,
                          dropdownColor: AppColors.bgSurface,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                billingMode = val;
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 'flat_rate', child: Text('Flat Rate')),
                            DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<JobBloc>().add(
                            AddLineItemEvent(
                              workOrderId: workOrderId,
                              description: descController.text.trim(),
                              billingMode: billingMode,
                              price: double.parse(priceController.text.trim()),
                              status: 'not_started',
                            ),
                          );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Add Task', style: TextStyle(color: AppColors.bgDefault)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
