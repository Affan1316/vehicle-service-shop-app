import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'manager':
        return Colors.redAccent;
      case 'advisor':
        return AppColors.primary;
      case 'technician':
        return Colors.orangeAccent;
      case 'customer':
        return Colors.tealAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'manager':
        return 'SHOP MANAGER';
      case 'advisor':
        return 'SERVICE ADVISOR';
      case 'technician':
        return 'SERVICE TECHNICIAN';
      case 'customer':
        return 'CLIENT';
      default:
        return role.toUpperCase();
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
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            String role = 'viewer';
            if (authState is Authenticated) {
              role = authState.user.role;
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (role == 'customer') return;
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
                    if (role == 'customer')
                      _buildCustomerPlaceholder(context)
                    else ...[
                      _buildStatsGrid(isDesktop, isTablet, role),
                      const SizedBox(height: 32),
                      _buildShortcutsSection(isDesktop, isTablet, role),
                      const SizedBox(height: 32),
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildLiveMonitorSection()),
                            const SizedBox(width: 24),
                            Expanded(flex: 2, child: _buildComingSoonSidebar(role)),
                          ],
                        )
                      else ...[
                        _buildLiveMonitorSection(),
                        const SizedBox(height: 32),
                        _buildComingSoonSidebar(role),
                      ],
                    ],
                  ],
                ),
              ),
            );
          },
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

        final roleColor = _getRoleColor(role);
        final roleLabel = _getRoleLabel(role);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: roleColor.withValues(alpha: 0.5), width: 1.5),
            gradient: LinearGradient(
              colors: [AppColors.bgSurface, AppColors.bgElevated.withValues(alpha: 0.5)],
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
                  color: roleColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: roleColor.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    LucideIcons.car,
                    color: roleColor,
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
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: roleColor.withValues(alpha: 0.5), width: 0.5),
                          ),
                          child: Text(
                            roleLabel,
                            style: AppTypography.bodySmall.copyWith(
                              color: roleColor,
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
                icon: const Icon(LucideIcons.logOut, color: AppColors.dangerText),
                tooltip: 'Sign Out',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(bool isDesktop, bool isTablet, String role) {
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
                // Determine counts
                String activeVisitsCount = '...';
                int activeCountInt = 0;
                int diagnosisCountInt = 0;
                int serviceCountInt = 0;
                int awaitingPickupCountInt = 0;

                if (visitState is VisitListLoaded) {
                  final active = visitState.visits
                      .where((v) => v.status != 'completed' && v.checkedOutAt == null);
                  activeVisitsCount = active.length.toString();
                  activeCountInt = active.length;

                  diagnosisCountInt = visitState.visits
                      .where((v) => v.status == 'in_diagnosis')
                      .length;
                  serviceCountInt = visitState.visits
                      .where((v) => v.status == 'in_service')
                      .length;
                  awaitingPickupCountInt = visitState.visits
                      .where((v) => v.status == 'awaiting_pickup')
                      .length;
                }

                String customerCount = '...';
                if (custState is CustomersLoaded) {
                  customerCount = custState.customers.length.toString();
                }

                String vehicleCount = '...';
                if (vehState is VehicleListLoaded) {
                  vehicleCount = vehState.vehicles.length.toString();
                }

                List<Widget> cards = [];

                if (role == 'technician') {
                  cards = [
                    _buildStatCard(
                      'IN DIAGNOSTICS',
                      diagnosisCountInt.toString(),
                      LucideIcons.search,
                      AppColors.warningBorder,
                    ),
                    _buildStatCard(
                      'IN SERVICE',
                      serviceCountInt.toString(),
                      LucideIcons.wrench,
                      Colors.indigoAccent,
                    ),
                    _buildStatCard(
                      'AWAITING PICKUP',
                      awaitingPickupCountInt.toString(),
                      LucideIcons.checkCheck,
                      Colors.tealAccent,
                    ),
                    _buildStatCard(
                      'ACTIVE FLOOR LOAD',
                      activeCountInt.toString(),
                      LucideIcons.clipboardClock,
                      AppColors.primary,
                    ),
                  ];
                } else if (role == 'advisor') {
                  int pendingQueueCount = 0;
                  if (visitState is VisitListLoaded) {
                    pendingQueueCount = visitState.visits
                        .where((v) => v.status == 'checked_in' || v.status == 'in_diagnosis')
                        .length;
                  }
                  cards = [
                    _buildStatCard(
                      'ACTIVE CHECK-INS',
                      activeVisitsCount,
                      LucideIcons.clipboardClock,
                      AppColors.primary,
                    ),
                    _buildStatCard(
                      'PENDING QUEUE',
                      pendingQueueCount.toString(),
                      LucideIcons.circleDashed,
                      AppColors.warningBorder,
                    ),
                    _buildStatCard(
                      'CUSTOMERS',
                      customerCount,
                      LucideIcons.users,
                      AppColors.infoBorder,
                    ),
                    _buildStatCard(
                      'VEHICLE FLEET',
                      vehicleCount,
                      LucideIcons.car,
                      AppColors.successBorder,
                    ),
                  ];
                } else {
                  cards = [
                    _buildStatCard(
                      'ACTIVE CHECK-INS',
                      activeVisitsCount,
                      LucideIcons.clipboardClock,
                      AppColors.primary,
                    ),
                    _buildStatCard(
                      'CUSTOMERS',
                      customerCount,
                      LucideIcons.users,
                      AppColors.infoBorder,
                    ),
                    _buildStatCard(
                      'VEHICLE FLEET',
                      vehicleCount,
                      LucideIcons.car,
                      AppColors.successBorder,
                    ),
                    _buildStatCard(
                      'TODAY\'S REVENUE',
                      '\$4,850',
                      LucideIcons.circleDollarSign,
                      Colors.purpleAccent,
                      isComingSoon: true,
                    ),
                  ];
                }

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isDesktop ? 1.4 : 2.5,
                  children: cards,
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
                    color: Colors.purple.withValues(alpha: 0.2),
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

  Widget _buildShortcutsSection(bool isDesktop, bool isTablet, String role) {
    int crossAxisCount = 1;
    if (isDesktop) {
      crossAxisCount = 3;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    List<Widget> shortcuts = [];

    if (role == 'technician') {
      shortcuts = [
        _buildShortcutCard(
          'Active Work Floor',
          'View currently checked-in vehicles',
          LucideIcons.car,
          () => context.push('/visits'),
        ),
        _buildShortcutCard(
          'Tech Job Cards',
          'Check diagnostic & repair guidelines',
          LucideIcons.wrench,
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Job Cards module coming soon!'),
                backgroundColor: AppColors.infoBorder,
              ),
            );
          },
        ),
      ];
      if (isDesktop) {
        crossAxisCount = 2;
      }
    } else if (role == 'advisor') {
      shortcuts = [
        _buildShortcutCard(
          'Check In Vehicle',
          'Log new active visit check-ins',
          LucideIcons.clipboardClock,
          () => context.push('/visits'),
        ),
        _buildShortcutCard(
          'Customers Directory',
          'Create & manage customer profiles',
          LucideIcons.users,
          () => context.push('/customers'),
        ),
        _buildShortcutCard(
          'Vehicles Directory',
          'Lookup & register fleet specs',
          LucideIcons.car,
          () => context.push('/vehicles'),
        ),
      ];
    } else {
      // Manager shortcuts
      shortcuts = [
        _buildShortcutCard(
          'Customers Directory',
          'Manage profiles and bills',
          LucideIcons.users,
          () => context.push('/customers'),
        ),
        _buildShortcutCard(
          'Vehicles Directory',
          'Lookup specs and records',
          LucideIcons.car,
          () => context.push('/vehicles'),
        ),
        _buildShortcutCard(
          'Service Visits',
          'Active floor check-ins',
          LucideIcons.clipboard,
          () => context.push('/visits'),
        ),
      ];
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
          childAspectRatio: isDesktop ? 1.6 : (isTablet ? 2.5 : 2.5),
          children: shortcuts,
        ),
      ],
    );
  }

  Widget _buildShortcutCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
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
            Icon(LucideIcons.chevronRight, color: AppColors.textSecondary),
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
                        Icon(LucideIcons.checkCheck, color: AppColors.successText, size: 36),
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

  Widget _buildComingSoonSidebar(String role) {
    List<Widget> modules = [];

    if (role == 'manager') {
      modules = [
        _buildPlaceholderModule(
          'Billing & Payment Disputes',
          'Generate parts/labor invoices, record deposits, and process customer credit refunds.',
          LucideIcons.receipt,
        ),
        const SizedBox(height: 16),
        _buildPlaceholderModule(
          'Shop Bay Manager',
          'Allocate physical service bays, map Gantt repair schedules, and minimize queue delays.',
          LucideIcons.calendar,
        ),
      ];
    } else if (role == 'advisor') {
      modules = [
        _buildPlaceholderModule(
          'Shop Bay Manager',
          'Allocate physical service bays, map Gantt repair schedules, and minimize queue delays.',
          LucideIcons.calendar,
        ),
        const SizedBox(height: 16),
        _buildPlaceholderModule(
          'Service Jobs Dispatch',
          'Track technician assignments, diagnostic logs, and job status counters.',
          LucideIcons.wrench,
        ),
      ];
    } else {
      // technician
      modules = [
        _buildPlaceholderModule(
          'Service Jobs Dispatch',
          'Track technician assignments, diagnostic logs, and job status counters.',
          LucideIcons.wrench,
        ),
        const SizedBox(height: 16),
        _buildPlaceholderModule(
          'Shop Bay Manager',
          'Allocate physical service bays, map Gantt repair schedules, and minimize queue delays.',
          LucideIcons.calendar,
        ),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING SYSTEM MODULES',
          style: AppTypography.headingSmall.copyWith(letterSpacing: 0.8),
        ),
        const SizedBox(height: 16),
        ...modules,
      ],
    );
  }

  Widget _buildPlaceholderModule(String name, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderDefault.withValues(alpha: 0.5),
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
                        color: AppColors.textDisabled.withValues(alpha: 0.15),
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

  Widget _buildCustomerPlaceholder(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.wrench,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Customer Portal Coming Soon',
              style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your customer self-service hub is currently under active development.\n\n'
              'Once released, you will be able to track live vehicle service status, approve quote estimates, view maintenance history logs, and process invoices directly from this portal.',
              style: AppTypography.bodyLarge.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.info, color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Need assistance? Contact shop administration.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
