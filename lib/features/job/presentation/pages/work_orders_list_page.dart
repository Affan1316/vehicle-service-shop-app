import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/work_order.dart';
import '../bloc/job_bloc.dart';
import '../bloc/job_event.dart';
import '../bloc/job_state.dart';

class WorkOrdersListPage extends StatefulWidget {
  const WorkOrdersListPage({super.key});

  @override
  State<WorkOrdersListPage> createState() => _WorkOrdersListPageState();
}

class _WorkOrdersListPageState extends State<WorkOrdersListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<JobBloc>().add(const FetchWorkOrders());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  String _formatStatusLabel(String status) {
    return status.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isStaff = authState is Authenticated &&
        (authState.user.role == 'manager' || authState.user.role == 'advisor');

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
          'Service Job Cards',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textPrimary),
            onPressed: () => context.read<JobBloc>().add(const FetchWorkOrders(forceRefresh: true)),
          ),
        ],
      ),
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.plus, color: AppColors.bgDefault),
              label: Text(
                'New Job Card',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.bgDefault,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _showCreateWorkOrderDialog(context),
            )
          : null,
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
            final customerMap = state.customerNames;
            final vehicleMap = state.vehicleNames;

            // Filter logic
            final filteredOrders = workOrders.where((wo) {
              final custName = (customerMap[wo.customerId] ?? '').toLowerCase();
              final vehName = (vehicleMap[wo.vehicleId] ?? '').toLowerCase();
              final vin = wo.vehicleId.toLowerCase();
              final matchesSearch = custName.contains(_searchQuery.toLowerCase()) ||
                  vehName.contains(_searchQuery.toLowerCase()) ||
                  vin.contains(_searchQuery.toLowerCase());

              final matchesStatus = _selectedStatusFilter == 'ALL' ||
                  wo.status.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesStatus;
            }).toList();

            // Stats breakdown
            final int totalCount = workOrders.length;
            final int activeCount = workOrders.where((w) => w.status == 'active').length;
            final int pausedCount = workOrders.where((w) => w.status == 'paused').length;
            final int completedCount = workOrders.where((w) => w.status == 'closed').length;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<JobBloc>().add(const FetchWorkOrders(forceRefresh: true));
              },
              color: AppColors.primary,
              backgroundColor: AppColors.bgSurface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Metrics Row
                    _buildMetricsRow(totalCount, activeCount, pausedCount, completedCount),
                    const SizedBox(height: 32),

                    // Filters Block
                    _buildSearchAndFilters(),
                    const SizedBox(height: 24),

                    // List View
                    if (filteredOrders.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.fileQuestion, size: 48, color: AppColors.textDisabled),
                              const SizedBox(height: 16),
                              Text(
                                'No Job Cards Found',
                                style: AppTypography.headingMedium.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Create a new work order or adjust filters.',
                                style: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredOrders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final wo = filteredOrders[index];
                          final custName = customerMap[wo.customerId] ?? 'Unknown Customer';
                          final vehName = vehicleMap[wo.vehicleId] ?? 'Unknown Vehicle';
                          return _buildWorkOrderCard(wo, custName, vehName);
                        },
                      ),
                  ],
                ),
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

  Widget _buildMetricsRow(int total, int active, int paused, int completed) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width >= 768 ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: width >= 768 ? 1.6 : 2.2,
          children: [
            _buildMetricCard('TOTAL JOBS', total.toString(), Colors.blueAccent),
            _buildMetricCard('ACTIVE', active.toString(), Colors.orangeAccent),
            _buildMetricCard('PAUSED', paused.toString(), Colors.redAccent),
            _buildMetricCard('COMPLETED', completed.toString(), AppColors.successBorder),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by client, model, or VIN...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatusFilter,
              dropdownColor: AppColors.bgSurface,
              icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary, size: 16),
              items: <String>['ALL', 'CREATED', 'SCHEDULED', 'ACTIVE', 'PAUSED', 'CLOSED']
                  .map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newVal) {
                if (newVal != null) {
                  setState(() {
                    _selectedStatusFilter = newVal;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkOrderCard(WorkOrder wo, String customerName, String vehicleName) {
    final statusColor = _getStatusColor(wo.status);

    return InkWell(
      onTap: () => context.push('/work-orders/${wo.workOrderId}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicleName,
                        style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CLIENT: $customerName',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 0.5),
                  ),
                  child: Text(
                    _formatStatusLabel(wo.status),
                    style: AppTypography.bodySmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderDefault, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AUTHORIZED LIMIT',
                      style: AppTypography.monospace.copyWith(
                        color: AppColors.textDisabled,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${wo.authorizedAmount.toStringAsFixed(2)}',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TASKS LIST',
                      style: AppTypography.monospace.copyWith(
                        color: AppColors.textDisabled,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${wo.lineItems.length} lines',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateWorkOrderDialog(BuildContext context) {
    final quoteController = TextEditingController();
    final vehicleController = TextEditingController();
    final customerController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(
            'Create Service Job Card',
            style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: quoteController,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Quote ID (UUID)',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: vehicleController,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Vehicle VIN (17 chars)',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    validator: (v) => v == null || v.length != 17 ? 'Must be 17 characters' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: customerController,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Customer ID (UUID)',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Authorized Limit Amount (\$)',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                    ),
                    validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid number' : null,
                  ),
                ],
              ),
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
                        CreateWorkOrderEvent(
                          quoteId: quoteController.text.trim(),
                          vehicleId: vehicleController.text.trim().toUpperCase(),
                          customerId: customerController.text.trim(),
                          authorizedAmount: double.parse(amountController.text.trim()),
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Generate', style: TextStyle(color: AppColors.bgDefault)),
            ),
          ],
        );
      },
    );
  }
}
