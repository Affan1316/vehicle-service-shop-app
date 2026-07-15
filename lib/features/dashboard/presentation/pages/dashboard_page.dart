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
import '../../../../core/di/injection_container.dart';
import '../../../quote/domain/usecases/get_quotes.dart';
import '../../../quote/domain/usecases/update_quote.dart';
import '../../../billing/domain/usecases/get_invoices.dart';
import '../../../vehicle/domain/usecases/get_vehicles_by_customer_usecase.dart';
import '../../../visit/domain/usecases/get_visits_usecase.dart';
import '../../../quote/domain/entities/quote.dart';
import '../../../billing/domain/entities/invoice.dart';
import '../../../vehicle/domain/entities/vehicle.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isCustomerDataLoading = true;
  bool _hasAttemptedLoad = false;
  List<Vehicle> _customerVehicles = [];
  List<Visit> _customerVisits = [];
  List<Quote> _customerQuotes = [];
  List<Invoice> _customerInvoices = [];
  String? _customerDataError;

  Future<void> _loadCustomerData(String customerId) async {
    setState(() {
      _isCustomerDataLoading = true;
      _customerDataError = null;
    });

    try {
      final vehiclesRes = await sl<GetVehiclesByCustomerUseCase>().call(customerId);
      vehiclesRes.fold(
        (failure) => throw Exception(failure.message),
        (vehicles) => _customerVehicles = vehicles,
      );

      final visitsRes = await sl<GetVisitsUseCase>().call(limit: 100);
      visitsRes.fold(
        (failure) => throw Exception(failure.message),
        (visits) {
          _customerVisits = visits.where((v) => v.customerId == customerId).toList();
        },
      );

      final quotesRes = await sl<GetQuotesUseCase>().call(limit: 100);
      quotesRes.fold(
        (failure) => throw Exception(failure.message),
        (quotes) {
          _customerQuotes = quotes.where((q) => q.customerId == customerId).toList();
        },
      );

      final invoicesRes = await sl<GetInvoicesUseCase>().call(limit: 100);
      invoicesRes.fold(
        (failure) => throw Exception(failure.message),
        (invoices) {
          _customerInvoices = invoices.where((inv) => inv.customerId == customerId).toList();
        },
      );
    } catch (e) {
      _customerDataError = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isCustomerDataLoading = false;
        });
      }
    }
  }

  Future<void> _updateQuoteStatus(String quoteId, String status) async {
    final res = await sl<UpdateQuoteUseCase>().call(quoteId, status: status);
    res.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quote: ${failure.message}'), backgroundColor: AppColors.dangerBorder),
        );
      },
      (updatedQuote) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quote marked as $status!'), backgroundColor: AppColors.successBorder),
        );
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated && authState.user.customerId != null) {
          _loadCustomerData(authState.user.customerId!);
        }
      },
    );
  }

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
                if (role == 'customer') {
                  final custId = (authState as Authenticated).user.customerId;
                  if (custId != null) {
                    await _loadCustomerData(custId);
                  }
                  return;
                }
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
                    if (role == 'customer') ...[
                      Builder(builder: (context) {
                        final custId = (authState as Authenticated).user.customerId;
                        if (custId != null && !_hasAttemptedLoad) {
                          _hasAttemptedLoad = true;
                          Future.microtask(() => _loadCustomerData(custId));
                        }
                        return _buildCustomerDashboard(context);
                      }),
                    ] else ...[
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
          () => context.push('/work-orders'),
        ),
        _buildShortcutCard(
          'Tech Job Cards',
          'Track your repair tasks progress',
          LucideIcons.wrench,
          () => context.push('/work-orders'),
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
        _buildShortcutCard(
          'Quotes & Estimates',
          'Create & issue quotes',
          LucideIcons.fileText,
          () => context.push('/quotes'),
        ),
        _buildShortcutCard(
          'Billing & Payments',
          'Manage invoices and payments',
          LucideIcons.receipt,
          () => context.push('/billing'),
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
          'Service Job Cards',
          'Active shop floor dispatch',
          LucideIcons.wrench,
          () => context.push('/work-orders'),
        ),
        _buildShortcutCard(
          'Quotes & Estimates',
          'Create & issue quotes',
          LucideIcons.fileText,
          () => context.push('/quotes'),
        ),
        _buildShortcutCard(
          'Billing & Payments',
          'Manage invoices and payments',
          LucideIcons.receipt,
          () => context.push('/billing'),
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

  Widget _buildCustomerDashboard(BuildContext context) {
    if (_isCustomerDataLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 64.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_customerDataError != null) {
      return Center(
        child: Text(
          'Failed to load customer profile: $_customerDataError',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    final activeVisits = _customerVisits.where((v) => v.status.toLowerCase() != 'completed' && v.status.toLowerCase() != 'closed').toList();
    final activeVisit = activeVisits.isNotEmpty ? activeVisits.first : null;

    final pendingQuotes = _customerQuotes.where((q) => q.status.toLowerCase() == 'issued').toList();

    final unpaidInvoices = _customerInvoices.where((i) => i.status.toLowerCase() == 'issued' || i.status.toLowerCase() == 'disputed').toList();
    double outstandingSum = 0.0;
    for (var inv in unpaidInvoices) {
      outstandingSum += inv.totalBalance;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomerOverviewMetrics(
          vehiclesCount: _customerVehicles.length,
          activeVisitsCount: activeVisits.length,
          pendingQuotesCount: pendingQuotes.length,
          outstandingBalance: outstandingSum,
        ),
        const SizedBox(height: 32),
        _buildCustomerServiceProgressSection(activeVisit),
        const SizedBox(height: 32),
        _buildCustomerQuotesSection(pendingQuotes),
        const SizedBox(height: 32),
        _buildCustomerBillingSection(_customerInvoices),
        const SizedBox(height: 32),
        _buildCustomerUpcomingSection(),
      ],
    );
  }

  Widget _buildCustomerOverviewMetrics({
    required int vehiclesCount,
    required int activeVisitsCount,
    required int pendingQuotesCount,
    required double outstandingBalance,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width >= 768 ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: width >= 768 ? 1.6 : 1.3,
          children: [
            _buildCustomerMetricCard('OWNED FLEET', '$vehiclesCount Vehicles', LucideIcons.car, Colors.tealAccent),
            _buildCustomerMetricCard('ACTIVE VISITS', '$activeVisitsCount Active', LucideIcons.clipboardClock, AppColors.primary),
            _buildCustomerMetricCard('PENDING ESTIMATES', '$pendingQuotesCount Review', LucideIcons.fileText, Colors.purpleAccent),
            _buildCustomerMetricCard('BALANCE DUE', '\$${outstandingBalance.toStringAsFixed(2)}', LucideIcons.receipt, Colors.orangeAccent),
          ],
        );
      },
    );
  }

  Widget _buildCustomerMetricCard(String label, String value, IconData icon, Color color) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.monospace.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headingMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerServiceProgressSection(Visit? activeVisit) {
    if (activeVisit == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          children: [
            Icon(LucideIcons.checkCircle2, size: 36, color: AppColors.successBorder),
            const SizedBox(height: 12),
            Text(
              'All Clear!',
              style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'No active vehicle service in progress at this time.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final double progress = _getStatusProgressValue(activeVisit.status);
    final statusColor = _getStatusColor(activeVisit.status);

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
                'LIVE SERVICE TRACKER',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatStatusLabel(activeVisit.status),
                  style: AppTypography.monospace.copyWith(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            activeVisit.vehicleName ?? 'Your Vehicle',
            style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Intake', progress >= 0.2),
              _buildStepLabel('Diagnose', progress >= 0.4),
              _buildStepLabel('Quote', progress >= 0.6),
              _buildStepLabel('Service', progress >= 0.8),
              _buildStepLabel('Ready', progress >= 0.95),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, bool isDone) {
    return Text(
      label,
      style: AppTypography.bodySmall.copyWith(
        color: isDone ? AppColors.textPrimary : AppColors.textDisabled,
        fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildCustomerQuotesSection(List<Quote> quotes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESTIMATES & QUOTES AWAITING APPROVAL',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        if (quotes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Text(
              'No estimates awaiting your approval.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quotes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return Container(
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
                        Text(
                          'Quote ID: ${quote.quoteId.substring(0, 5).toUpperCase()}',
                          style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${quote.totalAmount.toStringAsFixed(2)}',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expires on: ${quote.validUntil.year}-${quote.validUntil.month.toString().padLeft(2, '0')}-${quote.validUntil.day.toString().padLeft(2, '0')}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.dangerBorder),
                          ),
                          onPressed: () => _updateQuoteStatus(quote.quoteId, 'declined'),
                          child: const Text('Decline', style: TextStyle(color: AppColors.dangerText)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successBorder,
                          ),
                          onPressed: () => _updateQuoteStatus(quote.quoteId, 'approved'),
                          child: const Text('Approve Estimate', style: TextStyle(color: AppColors.bgDefault)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCustomerBillingSection(List<Invoice> invoices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MAINTENANCE & INVOICES HISTORY',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        if (invoices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: Text(
              'No invoices logged yet.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invoices.length > 3 ? 3 : invoices.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              final isPaid = invoice.status.toLowerCase() == 'paid';
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice: WO-${invoice.workOrderId.substring(0, 5).toUpperCase()}',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Issued: ${invoice.issuedAt.year}-${invoice.issuedAt.month.toString().padLeft(2, '0')}-${invoice.issuedAt.day.toString().padLeft(2, '0')}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textDisabled),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${invoice.amountDue.toStringAsFixed(2)}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isPaid ? AppColors.successBorder : Colors.orangeAccent).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            invoice.status.toUpperCase(),
                            style: TextStyle(
                              color: isPaid ? AppColors.successBorder : Colors.orangeAccent,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCustomerUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPCOMING CUSTOMER PORTAL ENHANCEMENTS',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final int crossAxisCount = width >= 768 ? 3 : 1;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: width >= 768 ? 1.6 : 3.0,
              children: [
                _buildUpcomingCard(
                  'Online Bill Pay',
                  'Secure checkout using credit card, Apple Pay, or Google Pay directly from this portal.',
                  LucideIcons.creditCard,
                ),
                _buildUpcomingCard(
                  'Book Appointments',
                  'Schedule visits, choose a diagnostic service bay, and assign your preferred advisor.',
                  LucideIcons.calendar,
                ),
                _buildUpcomingCard(
                  'Direct Technician Chat',
                  'Exchange diagnostic media and chat in real-time with the technician working on your car.',
                  LucideIcons.messageSquare,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildUpcomingCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textDisabled),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.bodyMedium.copyWith(
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
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textDisabled, fontSize: 11),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
