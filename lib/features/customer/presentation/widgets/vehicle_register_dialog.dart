import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';

class VehicleRegisterDialog extends StatefulWidget {
  final String customerId;
  final VoidCallback onSuccess;

  const VehicleRegisterDialog({
    required this.customerId,
    required this.onSuccess,
    super.key,
  });

  @override
  State<VehicleRegisterDialog> createState() => _VehicleRegisterDialogState();
}

class _VehicleRegisterDialogState extends State<VehicleRegisterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _vinController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void dispose() {
    _vinController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<VehicleBloc>().add(
            RegisterVehicleEvent(
              vin: _vinController.text.trim().toUpperCase(),
              customerId: widget.customerId,
              make: _makeController.text.trim(),
              model: _modelController.text.trim(),
              year: int.parse(_yearController.text),
              currentMileage: int.parse(_mileageController.text),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state is VehicleOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.successBorder),
          );
          widget.onSuccess();
          Navigator.pop(context);
        } else if (state is VehicleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.dangerBorder),
          );
        }
      },
      child: AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text(
          'Register New Vehicle',
          style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'VIN (Vehicle Identification Number)',
                  hint: 'Enter 17-character VIN',
                  controller: _vinController,
                  validator: (value) {
                    if (value == null || value.trim().length != 17) {
                      return 'VIN must be exactly 17 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Make',
                  hint: 'e.g., Toyota',
                  controller: _makeController,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Make is required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Model',
                  hint: 'e.g., Corolla',
                  controller: _modelController,
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Model is required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Year',
                  hint: 'e.g., 2022',
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Year is required';
                    }
                    final year = int.tryParse(value);
                    if (year == null || year < 1900 || year > 2100) {
                      return 'Enter a valid year between 1900 and 2100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Current Mileage',
                  hint: 'e.g., 45000',
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mileage is required';
                    }
                    final mileage = int.tryParse(value);
                    if (mileage == null || mileage < 0) {
                      return 'Enter a valid mileage';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          BlocBuilder<VehicleBloc, VehicleState>(
            builder: (context, state) {
              final isLoading = state is VehicleLoading;
              return ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: AppColors.textPrimary, strokeWidth: 2),
                      )
                    : Text('Register', style: TextStyle(color: AppColors.textPrimary)),
              );
            },
          ),
        ],
      ),
    );
  }
}
