import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../bloc/vehicle_detail/vehicle_detail_cubit.dart';
import '../bloc/vehicle_list/vehicle_list_bloc.dart';
import '../bloc/vehicle_list/vehicle_list_event.dart';
import '../bloc/vehicle_list/vehicle_list_state.dart';
import '../widgets/vehicle_drawer_content.dart';

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedVin;

  @override
  void initState() {
    super.initState();
    context.read<VehicleListBloc>().add(const FetchVehiclesList());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Vehicle Directory',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.refreshCw, color: AppColors.textPrimary),
            onPressed: () =>
                context.read<VehicleListBloc>().add(const FetchVehiclesList()),
          ),
        ],
      ),
      endDrawer: _selectedVin == null
          ? null
          : Drawer(
              backgroundColor: AppColors.bgSurface,
              width: MediaQuery.of(context).size.width >= 768
                  ? 400
                  : MediaQuery.of(context).size.width,
              child: BlocProvider<VehicleDetailCubit>(
                create: (context) => sl<VehicleDetailCubit>(),
                child: VehicleDrawerContent(
                  vin: _selectedVin!,
                  onDeleteSuccess: () {
                    context.read<VehicleListBloc>().add(const FetchVehiclesList());
                  },
                  onUpdateSuccess: () {
                    context.read<VehicleListBloc>().add(const FetchVehiclesList());
                  },
                ),
              ),
            ),
      body: BlocConsumer<VehicleListBloc, VehicleListState>(
        listener: (context, state) {
          if (state is VehicleListError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.dangerBorder,
              ),
            );
          }
        },
        builder: (context, state) {
          List<dynamic> vehicles = [];
          bool isLoading = false;

          if (state is VehicleListLoading) {
            isLoading = true;
          } else if (state is VehicleListLoaded) {
            vehicles = state.vehicles;
          }

          final filteredVehicles = vehicles.where((v) {
            final query = _searchQuery.toLowerCase();
            return v.vin.toLowerCase().contains(query) ||
                v.make.toLowerCase().contains(query) ||
                v.model.toLowerCase().contains(query) ||
                v.year.toString().contains(query);
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Search Vehicles',
                  hint: 'Search by VIN, make, model or year...',
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
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (filteredVehicles.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No vehicles found in inventory',
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredVehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = filteredVehicles[index];

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
                              setState(() => _selectedVin = vehicle.vin);
                              _scaffoldKey.currentState?.openEndDrawer();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.car,
                                      color: AppColors.primary, size: 28),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                          style: AppTypography.headingSmall
                                              .copyWith(color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'VIN: ${vehicle.vin}',
                                          style: AppTypography.monospace.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${vehicle.currentMileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} mi',
                                        style: AppTypography.bodyLarge
                                            .copyWith(color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.successBg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'ACTIVE',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: AppColors.successText,
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
}
