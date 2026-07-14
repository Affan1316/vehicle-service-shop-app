import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../../../../core/network/api_client.dart';

class CreateJobCardDialog extends StatefulWidget {
  final Map<String, String> customerNames;
  final Map<String, String> vehicleNames;
  final Function({
    required String quoteId,
    required String vehicleId,
    required String customerId,
    required double authorizedAmount,
  }) onSubmit;

  const CreateJobCardDialog({
    required this.customerNames,
    required this.vehicleNames,
    required this.onSubmit,
    super.key,
  });

  @override
  State<CreateJobCardDialog> createState() => _CreateJobCardDialogState();
}

class _CreateJobCardDialogState extends State<CreateJobCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  List<Map<String, dynamic>> _quotes = [];
  Map<String, dynamic>? _selectedQuote;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    try {
      final response = await sl<ApiClient>().get('/quotes', queryParameters: {'limit': 100});
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>;
      
      setState(() {
        _quotes = items.map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load quotes: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onQuoteChanged(Map<String, dynamic>? quote) {
    if (quote == null) return;
    setState(() {
      _selectedQuote = quote;
      final rawAmount = quote['total_amount'];
      double parsedAmount = 0.0;
      if (rawAmount is num) {
        parsedAmount = rawAmount.toDouble();
      } else if (rawAmount is String) {
        parsedAmount = double.tryParse(rawAmount) ?? 0.0;
      }
      _amountController.text = parsedAmount.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Create Service Job Card',
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
                          'Select Approved Quote',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Map<String, dynamic>>(
                          value: _selectedQuote,
                          dropdownColor: AppColors.bgSurface,
                          isExpanded: true,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Choose a quote...',
                            hintStyle: TextStyle(color: AppColors.textSecondary),
                          ),
                          items: _quotes.map((q) {
                            final quoteId = q['quote_id'] as String;
                            final shortId = quoteId.substring(0, 8);
                            final custId = q['customer_id'] as String;
                            final clientName = widget.customerNames[custId] ?? 'Unknown Client';
                            
                            final rawAmount = q['total_amount'];
                            double parsedAmount = 0.0;
                            if (rawAmount is num) {
                              parsedAmount = rawAmount.toDouble();
                            } else if (rawAmount is String) {
                              parsedAmount = double.tryParse(rawAmount) ?? 0.0;
                            }

                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: q,
                              child: Text(
                                'Quote #$shortId ($clientName) - \$${parsedAmount.toStringAsFixed(2)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _onQuoteChanged,
                          validator: (value) =>
                              value == null ? 'Quote selection is required' : null,
                        ),
                        const SizedBox(height: 20),
                        if (_selectedQuote != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.bgDefault,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderDefault),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.customerNames[_selectedQuote!['customer_id']] ?? 'Unknown Client',
                                        style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.directions_car, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.vehicleNames[_selectedQuote!['vehicle_id']] ?? _selectedQuote!['vehicle_id'] as String,
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        AppTextField(
                          label: 'Authorized Limit Amount (\$)',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Authorized limit is required';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount < 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
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
                                text: 'Generate',
                                onPressed: _selectedQuote == null
                                    ? null
                                    : () {
                                        if (_formKey.currentState?.validate() ?? false) {
                                          widget.onSubmit(
                                            quoteId: _selectedQuote!['quote_id'] as String,
                                            vehicleId: _selectedQuote!['vehicle_id'] as String,
                                            customerId: _selectedQuote!['customer_id'] as String,
                                            authorizedAmount: double.parse(_amountController.text.trim()),
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
