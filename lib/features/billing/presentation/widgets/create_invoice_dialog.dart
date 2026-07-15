import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../../../job/domain/entities/work_order.dart';
import '../../../job/domain/usecases/get_work_orders.dart';

class CreateInvoiceDialog extends StatefulWidget {
  final Function({
    required String workOrderId,
    required String customerId,
    required double amountDue,
  }) onSubmit;

  const CreateInvoiceDialog({required this.onSubmit, super.key});

  @override
  State<CreateInvoiceDialog> createState() => _CreateInvoiceDialogState();
}

class _CreateInvoiceDialogState extends State<CreateInvoiceDialog> {
  List<WorkOrder> _completedOrders = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedWorkOrderId;
  String? _selectedCustomerId;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkOrders();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkOrders() async {
    try {
      final res = await sl<GetWorkOrdersUseCase>().call(limit: 100);
      res.fold(
        (failure) => setState(() => _errorMessage = failure.message),
        (orders) {
          setState(() {
            _completedOrders = orders.where((o) => o.status.toLowerCase() == 'completed').toList();
          });
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Generate Work Order Invoice',
        style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
      ),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : _errorMessage != null
              ? Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))
              : _completedOrders.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No completed work orders awaiting invoicing.',
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        AppButton(text: 'Close', onPressed: () => Navigator.pop(context)),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Completed Job',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedWorkOrderId,
                          dropdownColor: AppColors.bgSurface,
                          isExpanded: true,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Select work order...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                          items: _completedOrders.map((o) {
                            return DropdownMenuItem<String>(
                              value: o.workOrderId,
                              child: Text('WO-${o.workOrderId.substring(0, 5).toUpperCase()}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            final selected = _completedOrders.firstWhere((o) => o.workOrderId == val);
                            setState(() {
                              _selectedWorkOrderId = val;
                              _selectedCustomerId = selected.customerId;
                              double total = 0.0;
                              for (var item in selected.lineItems) {
                                total += item.price;
                              }
                              _amountController.text = total > 0 ? total.toStringAsFixed(2) : '';
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Total Amount Due (\$)',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
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
                                text: 'Generate',
                                onPressed: (_selectedWorkOrderId == null || _amountController.text.isEmpty)
                                    ? null
                                    : () {
                                        widget.onSubmit(
                                          workOrderId: _selectedWorkOrderId!,
                                          customerId: _selectedCustomerId!,
                                          amountDue: double.parse(_amountController.text.trim()),
                                        );
                                        Navigator.pop(context);
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
    );
  }
}
