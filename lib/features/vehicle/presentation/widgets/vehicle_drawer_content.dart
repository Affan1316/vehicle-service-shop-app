import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/vehicle_detail/vehicle_detail_cubit.dart';
import '../bloc/vehicle_detail/vehicle_detail_state.dart';

class VehicleDrawerContent extends StatefulWidget {
  final String vin;
  final VoidCallback onDeleteSuccess;
  final VoidCallback onUpdateSuccess;

  const VehicleDrawerContent({
    required this.vin,
    required this.onDeleteSuccess,
    required this.onUpdateSuccess,
    super.key,
  });

  @override
  State<VehicleDrawerContent> createState() => _VehicleDrawerContentState();
}

class _VehicleDrawerContentState extends State<VehicleDrawerContent> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _mileageController;

  @override
  void initState() {
    super.initState();
    context.read<VehicleDetailCubit>().loadVehicle(widget.vin);
  }

  void _initializeControllers(String make, String model, int year, int mileage) {
    _makeController = TextEditingController(text: make);
    _modelController = TextEditingController(text: model);
    _yearController = TextEditingController(text: year.toString());
    _mileageController = TextEditingController(text: mileage.toString());
  }

  @override
  void dispose() {
    if (_isEditing) {
      _makeController.dispose();
      _modelController.dispose();
      _yearController.dispose();
      _mileageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine user roles
    final authState = context.read<AuthBloc>().state;
    final isManager = authState is Authenticated && authState.user.role == 'manager';
    final isAdvisor = authState is Authenticated &&
        (authState.user.role == 'manager' || authState.user.role == 'advisor');

    return Container(
      width: MediaQuery.of(context).size.width >= 768 ? 400 : double.infinity,
      height: double.infinity,
      color: AppColors.bgSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: BlocConsumer<VehicleDetailCubit, VehicleDetailState>(
        listener: (context, state) {
          if (state is VehicleDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vehicle deleted successfully'),
                backgroundColor: AppColors.successBorder,
              ),
            );
            widget.onDeleteSuccess();
            Navigator.pop(context);
          } else if (state is VehicleDetailLoaded && _isEditing) {
            // After successful update, toggle editing off
            setState(() => _isEditing = false);
            widget.onUpdateSuccess();
          } else if (state is VehicleDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.dangerBorder,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VehicleDetailLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is VehicleDetailLoaded) {
            final vehicle = state.vehicle;
            final customer = state.customer;

            if (!_isEditing) {
              _initializeControllers(
                vehicle.make,
                vehicle.model,
                vehicle.year,
                vehicle.currentMileage,
              );
            }

            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'VEHICLE DETAILS',
                        style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VIN: ${vehicle.vin}',
                    style: AppTypography.monospace.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: AppColors.borderDefault),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _isEditing
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTextField(
                                  label: 'Make',
                                  controller: _makeController,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'Make is required' : null,
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Model',
                                  controller: _modelController,
                                  validator: (v) =>
                                      v == null || v.trim().isEmpty ? 'Model is required' : null,
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Year',
                                  controller: _yearController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return 'Year is required';
                                    final val = int.tryParse(v);
                                    if (val == null || val < 1900 || val > 2100) {
                                      return 'Enter valid year';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  label: 'Current Mileage',
                                  controller: _mileageController,
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Mileage is required';
                                    }
                                    final val = int.tryParse(v);
                                    if (val == null || val < 0) {
                                      return 'Enter valid mileage';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: AppButton(
                                        text: 'Cancel',
                                        onPressed: () => setState(() => _isEditing = false),
                                        isSecondary: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: AppButton(
                                        text: 'Save',
                                        onPressed: () {
                                          if (_formKey.currentState?.validate() ?? false) {
                                            context.read<VehicleDetailCubit>().updateVehicle(
                                                  vehicle.vin,
                                                  make: _makeController.text.trim(),
                                                  model: _modelController.text.trim(),
                                                  year: int.parse(_yearController.text.trim()),
                                                  currentMileage: int.parse(
                                                      _mileageController.text.trim()),
                                                );
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailItem('MAKE', vehicle.make),
                                const SizedBox(height: 16),
                                _buildDetailItem('MODEL', vehicle.model),
                                const SizedBox(height: 16),
                                _buildDetailItem('YEAR', vehicle.year.toString()),
                                const SizedBox(height: 16),
                                _buildDetailItem(
                                  'CURRENT MILEAGE',
                                  '${vehicle.currentMileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} mi',
                                ),
                                const SizedBox(height: 24),
                                Divider(color: AppColors.borderDefault),
                                const SizedBox(height: 16),
                                Text(
                                  'OWNER',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context); // Close drawer
                                    context.push('/customers/${customer.id}');
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.person, color: AppColors.primary, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            customer.name,
                                            style: AppTypography.bodyLarge.copyWith(
                                              color: AppColors.primary,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                if (isAdvisor) ...[
                                  AppButton(
                                    text: 'Edit Vehicle Details',
                                    onPressed: () => setState(() => _isEditing = true),
                                    isSecondary: true,
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (isManager)
                                  AppButton(
                                    text: 'Delete Vehicle',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          backgroundColor: AppColors.bgSurface,
                                          title: Text(
                                            'Delete Vehicle',
                                            style: AppTypography.headingMedium
                                                .copyWith(color: AppColors.textPrimary),
                                          ),
                                          content: Text(
                                            'Are you sure you want to delete this vehicle permanently? This action cannot be undone.',
                                            style: AppTypography.bodyLarge
                                                .copyWith(color: AppColors.textSecondary),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(dialogContext),
                                              child: Text('Cancel',
                                                  style: TextStyle(color: AppColors.textSecondary)),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.dangerBorder),
                                              onPressed: () {
                                                Navigator.pop(dialogContext); // Close modal
                                                context
                                                    .read<VehicleDetailCubit>()
                                                    .deleteVehicle(vehicle.vin);
                                              },
                                              child: Text('Delete',
                                                  style: TextStyle(color: AppColors.textPrimary)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is VehicleDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.dangerText),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<VehicleDetailCubit>().loadVehicle(widget.vin),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
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
