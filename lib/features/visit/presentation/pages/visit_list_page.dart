import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/visit.dart';
import '../bloc/visit_list_bloc.dart';
import '../bloc/visit_list_event.dart';
import '../bloc/visit_list_state.dart';
import '../widgets/check_in_dialog.dart';
import '../widgets/visit_drawer_content.dart';

class VisitListPage extends StatefulWidget {
  const VisitListPage({super.key});

  @override
  State<VisitListPage> createState() => _VisitListPageState();
}

class _VisitListPageState extends State<VisitListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all'; // all, active, completed
  Visit? _selectedVisit;

  @override
  void initState() {
    super.initState();
    context.read<VisitListBloc>().add(const FetchVisitsList());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    // Determine user role
    final authState = context.read<AuthBloc>().state;
    final isAdvisor = authState is Authenticated &&
        (authState.user.role == 'manager' || authState.user.role == 'advisor');

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        backgroundColor: AppColors.bgDefault,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Service Visits',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, color: AppColors.textPrimary),
            onPressed: () =>
                context.read<VisitListBloc>().add(const FetchVisitsList()),
          ),
        ],
      ),
      floatingActionButton: isAdvisor
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: Icon(LucideIcons.plus, color: AppColors.textPrimary),
              label: Text(
                'Check In',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => CheckInDialog(
                    onSubmit: ({required String vehicleId, required String customerId}) {
                      context.read<VisitListBloc>().add(
                            CreateVisitEvent(
                              vehicleId: vehicleId,
                              customerId: customerId,
                            ),
                          );
                    },
                  ),
                );
              },
            )
          : null,
      endDrawer: _selectedVisit == null
          ? null
          : Drawer(
              backgroundColor: AppColors.bgSurface,
              width: MediaQuery.of(context).size.width >= 768
                  ? 400
                  : MediaQuery.of(context).size.width,
              child: VisitDrawerContent(
                visit: _selectedVisit!,
                onUpdateSuccess: () {
                  context.read<VisitListBloc>().add(const FetchVisitsList());
                },
              ),
            ),
      body: BlocConsumer<VisitListBloc, VisitListState>(
        listener: (context, state) {
          if (state is VisitListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.dangerBorder,
              ),
            );
          }
        },
        builder: (context, state) {
          List<Visit> visits = [];
          bool isLoading = false;

          if (state is VisitListLoading) {
            isLoading = true;
          } else if (state is VisitListLoaded) {
            visits = state.visits;
          }

          // Filter by status filter (All, Active, Completed)
          final statusFilteredVisits = visits.where((v) {
            if (_statusFilter == 'active') {
              return v.status != 'completed';
            } else if (_statusFilter == 'completed') {
              return v.status == 'completed';
            }
            return true;
          }).toList();

          // Filter by search query (Customer name, VIN, Vehicle specs)
          final filteredVisits = statusFilteredVisits.where((v) {
            final query = _searchQuery.toLowerCase();
            final customerName = (v.customerName ?? '').toLowerCase();
            final vehicleName = (v.vehicleName ?? '').toLowerCase();
            final vin = v.vehicleId.toLowerCase();
            return customerName.contains(query) ||
                vehicleName.contains(query) ||
                vin.contains(query);
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Search Visits',
                  hint: 'Search by customer, vehicle or VIN...',
                  controller: _searchController,
                  prefixIcon: Icon(LucideIcons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(LucideIcons.x, color: AppColors.textSecondary),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  validator: (value) => null,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Active', 'active'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Completed', 'completed'),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (filteredVisits.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No service visits found',
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredVisits.length,
                      itemBuilder: (context, index) {
                        final visit = filteredVisits[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderDefault),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              setState(() => _selectedVisit = visit);
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.car,
                                      color: _getStatusColor(visit.status), size: 28),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          visit.vehicleName ?? 'Unknown Vehicle',
                                          style: AppTypography.headingSmall
                                              .copyWith(color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Customer: ${visit.customerName ?? 'Unknown'}',
                                          style: AppTypography.bodyMedium
                                              .copyWith(color: AppColors.textSecondary),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'VIN: ${visit.vehicleId}',
                                          style: AppTypography.monospace.copyWith(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
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
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    LucideIcons.chevronRight,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.bgSurface,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.borderDefault,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _statusFilter = value;
          });
        }
      },
    );
  }
}
