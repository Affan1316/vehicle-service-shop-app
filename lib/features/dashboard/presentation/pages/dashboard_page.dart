import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';
import '../../../customer/presentation/bloc/customer_event.dart';
import '../../../customer/presentation/bloc/customer_state.dart';
import '../../../vehicle/presentation/bloc/vehicle_list/vehicle_list_bloc.dart';
import '../../../vehicle/presentation/bloc/vehicle_list/vehicle_list_event.dart';
import '../../../vehicle/presentation/bloc/vehicle_list/vehicle_list_state.dart';
import '../../../visit/domain/entities/visit.dart';
import '../../../visit/presentation/bloc/visit_list_bloc.dart';
import '../../../visit/presentation/bloc/visit_list_event.dart';
import '../../../visit/presentation/bloc/visit_list_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch fetch events to populate dashboard metrics
    context.read<CustomerBloc>().add(FetchCustomers());
    context.read<VehicleListBloc>().add(const FetchVehiclesList());
    context.read<VisitListBloc>().add(FetchVisitsList());
  }

  void _handleLogout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  String _formatStatusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;

    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<CustomerBloc>().add(FetchCustomers());
            context.read<VehicleListBloc>().add(const FetchVehiclesList());
            context.read<VisitListBloc>().add(FetchVisitsList());
          },
          color: AppColors.primary,
          backgroundColor: AppColors.bgSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildStatsGrid(isDesktop, isTablet),
                const SizedBox(height: 32),
                _buildShortcutsSection(isDesktop, isTablet),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildLiveMonitorSection()),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _buildComingSoonSidebar()),
                    ],
                  )
                else ...[
                  _buildLiveMonitorSection(),
                  const SizedBox(height: 32),
                  _buildComingSoonSidebar(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String username = 'Guest';
        String role = 'viewer';
        if (state is Authenticated) {
          username = state.user.username;
          role = state.user.role;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDefault),
            gradient: LinearGradient(
              colors: [AppColors.bgSurface, AppColors.bgElevated.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_car_filled,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK, ${username.toUpperCase()}',
                      style: AppTypography.headingMedium.copyWith(letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.infoBg,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.infoBorder, width: 0.5),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.infoText,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SYSTEM ONLINE',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.successText,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: AppColors.dangerText),
                tooltip: 'Sign Out',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(bool isDesktop, bool isTablet) {
    int crossAxisCount = 1;
    if (isDesktop) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, custState) {
        return BlocBuilder<VehicleListBloc, VehicleListState>(
          builder: (context, vehState) {
            return BlocBuilder<VisitListBloc, VisitListState>(
              builder: (context, visitState) {
                // Determine active visits
                String activeVisitsCount = '...';
                if (visitState is VisitListLoaded) {
                  final active = visitState.visits
                      .where((v) => v.status != 'completed' && v.checkedOutAt == null);
                  activeVisitsCount = active.length.toString();
                } else if (visitState is VisitListError) {
                  activeVisitsCount = 'Err';
                }

                // Determine customer count
                String customerCount = '...';
                if (custState is CustomersLoaded) {
                  customerCount = custState.customers.length.toString();
                } else if (custState is CustomerError) {
                  customerCount = 'Err';
                }

                // Determine vehicles count
                String vehicleCount = '...';
                if (vehState is VehicleListLoaded) {
                  vehicleCount = vehState.vehicles.length.toString();
                } else if (vehState is VehicleListError) {
                  vehicleCount = 'Err';
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isDesktop ? 1.4 : 2.5,
                  children: [
                    _buildStatCard(
                      'ACTIVE CHECK-INS',
                      activeVisitsCount,
                      Icons.pending_actions,
                      AppColors.primary,
                    ),
                    _buildStatCard(
                      'CUSTOMERS',
                      customerCount,
                      Icons.people,
                      AppColors.infoBorder,
                    ),
                    _buildStatCard(
                      'VEHICLE FLEET',
                      vehicleCount,
                      Icons.directions_car,
                      AppColors.successBorder,
                    ),
                    _buildStatCard(
                      'TODAY\'S REVENUE',
                      '\$4,850',
                      Icons.monetization_on,
                      Colors.purpleAccent,
                      isComingSoon: true,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color accentColor, {
    bool isComingSoon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(
                value,
                style: AppTypography.displayMedium.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isComingSoon) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'SOON',
                    style: AppTypography.monospace.copyWith(
                      color: Colors.purpleAccent,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsSection(bool isDesktop, bool isTablet) {
    int crossAxisCount = 1;
    if (isDesktop) {
      crossAxisCount = 3;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK LINKS',
          style: AppTypography.headingSmall.copyWith(letterSpacing: 0.8),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isDesktop ? 1.6 : (isTablet ? 4.5 : 3.0),
          children: [
            _buildShortcutCard(
              'Customers Directory',
              'Manage profiles and bills',
              Icons.people_outline,
              () => context.push('/customers'),
            ),
            _buildShortcutCard(
              'Vehicles Directory',
              'Lookup specs and records',
              Icons.directions_car_outlined,
              () => context.push('/vehicles'),
            ),
            _buildShortcutCard(
              'Service Visits',
              'Active floor check-ins',
              Icons.assignment_outlined,
              () => context.push('/visits'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMonitorSection() {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Text(
                'LIVE SHOP FLOOR MONITOR',
                style: AppTypography.headingSmall.copyWith(letterSpacing: 0.8),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.successBorder,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current active service check-ins undergoing diagnostics or repairs.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 24),
          BlocBuilder<VisitListBloc, VisitListState>(
            builder: (context, state) {
              if (state is VisitListLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (state is VisitListError) {
                return Center(
                  child: Text(
                    'Failed to load active visits.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerText),
                  ),
                );
              }

              if (state is VisitListLoaded) {
                final activeVisits = state.visits
                    .where((v) => v.status != 'completed' && v.checkedOutAt == null)
                    .toList();

                if (activeVisits.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.done_all, color: AppColors.successText, size: 36),
                        const SizedBox(height: 12),
                        Text(
                          'No vehicles checked in.',
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All service slots are currently clear.',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeVisits.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final visit = activeVisits[index];
                    return _buildActiveVisitRow(visit);
                  },
                );
              }

              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActiveVisitRow(Visit visit) {
    final statusColor = _getStatusColor(visit.status);
    final progress = _getStatusProgressValue(visit.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDefault.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  visit.vehicleName ?? 'Unknown Vehicle',
                  style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatStatusLabel(visit.status),
                  style: AppTypography.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Owner: ${visit.customerName ?? 'Unknown Customer'} • VIN: ${visit.vehicleId}',
            style: AppTypography.bodyMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgDefault,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  double _getStatusProgressValue(String status) {
    switch (status) {
      case 'checked_in':
        return 0.2;
      case 'in_diagnosis':
        return 0.4;
      case 'awaiting_quote':
        return 0.6;
      case 'in_service':
        return 0.8;
      case 'awaiting_pickup':
        return 0.95;
      default:
        return 0.1;
    }
  }

  Widget _buildComingSoonSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING SYSTEM MODULES',
          style: AppTypography.headingSmall.copyWith(letterSpacing: 0.8),
        ),
        const SizedBox(height: 16),
        _buildPlaceholderModule(
          'Service Jobs Dispatch',
          'Track technician assignments, diagnostic logs, and job status counters.',
          Icons.engineering_outlined,
        ),
        const SizedBox(height: 16),
        _buildPlaceholderModule(
          'Shop Bay Manager',
          'Allocate physical service bays, map Gantt repair schedules, and minimize queue delays.',
          Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 16),
        _buildPlaceholderModule(
          'Billing & Payment Disputes',
          'Generate parts/labor invoices, record deposits, and process customer credit refunds.',
          Icons.receipt_long_outlined,
        ),
      ],
    );
  }

  Widget _buildPlaceholderModule(String name, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDefault.withOpacity(0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textDisabled, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.textDisabled.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        'SOON',
                        style: AppTypography.monospace.copyWith(
                          color: AppColors.textDisabled,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
