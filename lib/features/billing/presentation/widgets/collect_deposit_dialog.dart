import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../../../quote/domain/entities/quote.dart';
import '../../../quote/domain/usecases/get_quotes.dart';

class CollectDepositDialog extends StatefulWidget {
  final Function({
    required String quoteId,
    required String customerId,
    String? workOrderId,
    required double amount,
  }) onSubmit;

  const CollectDepositDialog({required this.onSubmit, super.key});

  @override
  State<CollectDepositDialog> createState() => _CollectDepositDialogState();
}

class _CollectDepositDialogState extends State<CollectDepositDialog> {
  List<Quote> _approvedQuotes = [];
  bool _isLoading = true;
  String? _errorMessage;

  String? _selectedQuoteId;
  String? _selectedCustomerId;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApprovedQuotes();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadApprovedQuotes() async {
    try {
      final res = await sl<GetQuotesUseCase>().call(limit: 100);
      res.fold(
        (failure) => setState(() => _errorMessage = failure.message),
        (quotes) {
          setState(() {
            _approvedQuotes = quotes.where((q) => q.status.toLowerCase() == 'approved').toList();
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
        'Collect Pre-payment Deposit',
        style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
      ),
      content: _isLoading
          ? const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          : _errorMessage != null
              ? Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))
              : _approvedQuotes.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No approved quotes awaiting deposit collection.',
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
                          'Select Approved Quote',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedQuoteId,
                          dropdownColor: AppColors.bgSurface,
                          isExpanded: true,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Select quote...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                          items: _approvedQuotes.map((q) {
                            return DropdownMenuItem<String>(
                              value: q.quoteId,
                              child: Text('Quote ID: ${q.quoteId.substring(0, 5).toUpperCase()} (\$${q.totalAmount.toStringAsFixed(2)})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            final selected = _approvedQuotes.firstWhere((q) => q.quoteId == val);
                            setState(() {
                              _selectedQuoteId = val;
                              _selectedCustomerId = selected.customerId;
                              _amountController.text = (selected.totalAmount * 0.1).toStringAsFixed(2);
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Deposit Amount (\$)',
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
                                text: 'Collect',
                                onPressed: (_selectedQuoteId == null || _amountController.text.isEmpty)
                                    ? null
                                    : () {
                                        widget.onSubmit(
                                          quoteId: _selectedQuoteId!,
                                          customerId: _selectedCustomerId!,
                                          amount: double.parse(_amountController.text.trim()),
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
