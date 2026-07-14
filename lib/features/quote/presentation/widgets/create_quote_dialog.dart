import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/domain/usecases/get_customers_usecase.dart';
import '../../../vehicle/domain/entities/vehicle.dart';
import '../../../vehicle/domain/usecases/get_vehicles_usecase.dart';

class CreateQuoteDialog extends StatefulWidget {
  final String? initialCustomerId;
  final String? initialVehicleId;
  final String? initialVisitId;
  final Function({
    required String customerId,
    required String vehicleId,
    String? visitId,
    required double totalAmount,
    required DateTime validUntil,
  }) onSubmit;

  const CreateQuoteDialog({
    this.initialCustomerId,
    this.initialVehicleId,
    this.initialVisitId,
    required this.onSubmit,
    super.key,
  });

  @override
  State<CreateQuoteDialog> createState() => _CreateQuoteDialogState();
}

class _CreateQuoteDialogState extends State<CreateQuoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  List<Customer> _customers = [];
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];

  String? _selectedCustomerId;
  String? _selectedVehicleId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.initialCustomerId;
    _selectedVehicleId = widget.initialVehicleId;
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final customersRes = await sl<GetCustomersUseCase>().call(limit: 100);
      final vehiclesRes = await sl<GetVehiclesUseCase>().call(limit: 100);

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

      if (_selectedCustomerId != null) {
        _filteredVehicles = _vehicles.where((v) => v.customerId == _selectedCustomerId).toList();
      }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.bgDefault,
              surface: AppColors.bgSurface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Draft Quote & Estimate',
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
                  child: SingleChildScrollView(
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
                          isExpanded: true,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Choose a customer...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                          items: _customers.map((c) {
                            return DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(c.name),
                            );
                          }).toList(),
                          onChanged: widget.initialCustomerId != null ? null : _onCustomerChanged,
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
                          isExpanded: true,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: _selectedCustomerId == null
                                ? 'Select customer first...'
                                : 'Choose a vehicle...',
                            hintStyle: const TextStyle(color: AppColors.textSecondary),
                          ),
                          items: _filteredVehicles.map((v) {
                            return DropdownMenuItem<String>(
                              value: v.vin,
                              child: Text('${v.year} ${v.make} ${v.model}'),
                            );
                          }).toList(),
                          onChanged: widget.initialVehicleId != null
                              ? null
                              : (val) => setState(() => _selectedVehicleId = val),
                          validator: (value) =>
                              value == null ? 'Vehicle is required' : null,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Estimated Amount (\$)',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Amount is required';
                            }
                            final amount = double.tryParse(value.trim());
                            if (amount == null || amount < 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VALID UNTIL',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => _selectDate(context),
                              icon: const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                              label: Text(
                                'Change',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
                                text: 'Create Draft',
                                onPressed: (_selectedCustomerId == null ||
                                        _selectedVehicleId == null)
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          widget.onSubmit(
                                            customerId: _selectedCustomerId!,
                                            vehicleId: _selectedVehicleId!,
                                            visitId: widget.initialVisitId,
                                            totalAmount: double.parse(_amountController.text.trim()),
                                            validUntil: _selectedDate,
                                          );
                                          Navigator.pop(context);
                                        }
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
