import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(const FetchCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateCustomerDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        final addressController = TextEditingController();
        String customerType = 'individual';
        bool taxExempt = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.bgSurface,
              title: Text(
                'Register New Customer',
                style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Full Name',
                        controller: nameController,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        dropdownColor: AppColors.bgSurface,
                        initialValue: customerType,
                        decoration: const InputDecoration(
                          labelText: 'Customer Type',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.borderDefault),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.borderActive),
                          ),
                        ),
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'individual', child: Text('Individual')),
                          DropdownMenuItem(value: 'fleet', child: Text('Fleet Owner')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => customerType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Billing Address',
                        controller: addressController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax Exempt Status',
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                          ),
                          Switch(
                            value: taxExempt,
                            activeThumbColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() => taxExempt = value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      context.read<CustomerBloc>().add(
                            CreateCustomer(
                              name: nameController.text.trim(),
                              customerType: customerType,
                              billingAddress: addressController.text.trim().isEmpty
                                  ? null
                                  : addressController.text.trim(),
                              taxExempt: taxExempt,
                            ),
                          );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text('Register', style: TextStyle(color: AppColors.textPrimary)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        backgroundColor: AppColors.bgDefault,
        elevation: 0,
        title: Text(
          'Customer Directory',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => context.read<CustomerBloc>().add(const FetchCustomers()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showCreateCustomerDialog,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.successBorder),
            );
            context.read<CustomerBloc>().add(const FetchCustomers());
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.dangerBorder),
            );
          }
        },
        builder: (context, state) {
          List<dynamic> customers = [];
          bool isLoading = false;

          if (state is CustomerLoading) {
            isLoading = true;
          } else if (state is CustomersLoaded) {
            customers = state.customers;
          }

          final filteredCustomers = customers.where((c) {
            final name = c.name.toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                AppTextField(
                  label: 'Search Directory',
                  hint: 'Type customer name to search...',
                  controller: _searchController,
                  prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  validator: (value) => null,
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (filteredCustomers.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No customers found in directory',
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        final isFleet = customer.customerType == 'fleet';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderDefault),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              await context.push('/customers/${customer.id}');
                              if (context.mounted) {
                                context.read<CustomerBloc>().add(const FetchCustomers());
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: AppTypography.headingSmall
                                              .copyWith(color: AppColors.textPrimary),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          customer.billingAddress ?? 'No billing address registered',
                                          style: AppTypography.bodyMedium
                                              .copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isFleet
                                              ? AppColors.infoBg
                                              : AppColors.successBg,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isFleet ? 'FLEET' : 'INDIVIDUAL',
                                          style: AppTypography.bodySmall.copyWith(
                                            color: isFleet
                                                ? AppColors.infoText
                                                : AppColors.successText,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (customer.taxExempt) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.warningBg,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'TAX EXEMPT',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.warningText,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
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
