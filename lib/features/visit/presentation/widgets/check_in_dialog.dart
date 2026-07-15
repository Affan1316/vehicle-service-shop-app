import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/domain/usecases/get_customers_usecase.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle/domain/usecases/get_vehicles_usecase.dart';
import '../../../resource/domain/entities/bay.dart';
import '../../../resource/domain/usecases/get_bays_usecase.dart';
import '../../../resource/domain/usecases/update_bay_usecase.dart';

class CheckInDialog extends StatefulWidget {
  final Function({
    required String vehicleId,
    required String customerId,
  }) onSubmit;

  const CheckInDialog({required this.onSubmit, super.key});

  @override
  State<CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<CheckInDialog> {
  final _formKey = GlobalKey<FormState>();
  
  List<Customer> _customers = [];
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];
  List<Bay> _bays = [];

  String? _selectedCustomerId;
  String? _selectedVehicleId;
  String? _selectedBayId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final customersRes = await sl<GetCustomersUseCase>().call(limit: 100);
      final vehiclesRes = await sl<GetVehiclesUseCase>().call(limit: 100);
      final baysRes = await sl<GetBaysUseCase>().call(limit: 100);

      customersRes.fold(
        (failure) => setState(() => _errorMessage = failure.message),
        (customers) {
          _customers = customers;
        },
      );

      vehiclesRes.fold(
        (failure) => setState(() => _errorMessage = failure.message),
        (vehicles) {
          _vehicles = vehicles;
        },
      );

      baysRes.fold(
        (failure) => null, // Non-blocking
        (bays) {
          _bays = bays.where((b) => b.status == 'available').toList();
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onCustomerChanged(String? customerId) {
    if (customerId == null) return;
    setState(() {
      _selectedCustomerId = customerId;
      _selectedVehicleId = null;
      _filteredVehicles = _vehicles.where((v) => v.customerId == customerId).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Vehicle Check-In',
        style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
      ),
      content: _isLoading
          ? const SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : _errorMessage != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _errorMessage!,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.dangerText),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Close',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Customer',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCustomerId,
                        dropdownColor: AppColors.bgSurface,
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Choose a customer...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                        items: _customers.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.name),
                          );
                        }).toList(),
                        onChanged: _onCustomerChanged,
                        validator: (value) =>
                            value == null ? 'Customer is required' : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Select Vehicle',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedVehicleId,
                        dropdownColor: AppColors.bgSurface,
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: _selectedCustomerId == null
                              ? 'Select customer first...'
                              : 'Choose a vehicle...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                        items: _filteredVehicles.map((v) {
                          return DropdownMenuItem<String>(
                            value: v.vin,
                            child: Text('${v.year} ${v.make} ${v.model}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedVehicleId = val);
                        },
                        validator: (value) =>
                            value == null ? 'Vehicle is required' : null,
                      ),
                      if (_selectedCustomerId != null && _filteredVehicles.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'This customer has no vehicles registered.',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.dangerText,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        'Select Service Bay (Optional)',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedBayId,
                        dropdownColor: AppColors.bgSurface,
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: _bays.isEmpty
                              ? 'No available bays'
                              : 'Choose a physical bay for check-in...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                        items: _bays.map((b) {
                          return DropdownMenuItem<String>(
                            value: b.bayId,
                            child: Text('${b.bayType} (ID: ${b.bayId.substring(0, 5).toUpperCase()})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => _selectedBayId = val);
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Cancel',
                              onPressed: () => Navigator.pop(context),
                              isSecondary: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Check In',
                              onPressed: (_selectedCustomerId == null ||
                                      _selectedVehicleId == null)
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ?? false) {
                                        final nav = Navigator.of(context);
                                        if (_selectedBayId != null) {
                                          await sl<UpdateBayUseCase>().call(
                                            _selectedBayId!,
                                            status: 'held',
                                          );
                                        }
                                        widget.onSubmit(
                                          vehicleId: _selectedVehicleId!,
                                          customerId: _selectedCustomerId!,
                                        );
                                        nav.pop();
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
