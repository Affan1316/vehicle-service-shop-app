import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../../domain/entities/invoice.dart';

class CollectPaymentDialog extends StatefulWidget {
  final Invoice invoice;
  final Function({
    required String invoiceId,
    required double amount,
    required String method,
  }) onSubmit;

  const CollectPaymentDialog({
    required this.invoice,
    required this.onSubmit,
    super.key,
  });

  @override
  State<CollectPaymentDialog> createState() => _CollectPaymentDialogState();
}

class _CollectPaymentDialogState extends State<CollectPaymentDialog> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'credit_card';

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.invoice.totalBalance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Record Payment',
        style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INVOICE REFERENCE',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.invoice.workOrderNumber} • ${widget.invoice.customerName}',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Payment Amount (\$)',
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Method',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              dropdownColor: AppColors.bgSurface,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'check', child: Text('Check')),
                DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMethod = val);
                }
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
                    text: 'Record Payment',
                    onPressed: _amountController.text.isEmpty
                        ? null
                        : () {
                            widget.onSubmit(
                              invoiceId: widget.invoice.invoiceId,
                              amount: double.parse(_amountController.text.trim()),
                              method: _selectedMethod,
                            );
                            Navigator.pop(context);
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
