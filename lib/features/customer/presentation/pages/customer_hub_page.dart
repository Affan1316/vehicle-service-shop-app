import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/input/app_button.dart';
import '../../../../core/widgets/input/app_text_field.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../bloc/vehicle_bloc.dart';
import '../widgets/vehicle_register_dialog.dart';
import '../../../../core/di/injection_container.dart';
import '../../../quote/presentation/bloc/quote_bloc.dart';
import '../../../quote/presentation/bloc/quote_event.dart';
import '../../../quote/presentation/widgets/create_quote_dialog.dart';

class CustomerHubPage extends StatefulWidget {
  final String customerId;

  const CustomerHubPage({required this.customerId, super.key});

  @override
  State<CustomerHubPage> createState() => _CustomerHubPageState();
}

class _CustomerHubPageState extends State<CustomerHubPage> {
  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    context.read<CustomerBloc>().add(FetchCustomerDetails(widget.customerId));
  }

  void _showEditProfileDialog(dynamic customer) {
    final customerBloc = context.read<CustomerBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController(text: customer.name);
        final addressController = TextEditingController(text: customer.billingAddress ?? '');
        String customerType = customer.customerType;
        bool taxExempt = customer.taxExempt;

        return BlocProvider.value(
          value: customerBloc,
          child: StatefulBuilder(
            builder: (builderContext, setState) {
              return AlertDialog(
                backgroundColor: AppColors.bgSurface,
                title: Text(
                  'Edit Profile',
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
                        builderContext.read<CustomerBloc>().add(
                              UpdateCustomer(
                                id: customer.id,
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
                    child: Text('Save Changes', style: TextStyle(color: AppColors.textPrimary)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showAddVehicleDialog() {
    final vehicleBloc = context.read<VehicleBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return VehicleRegisterDialog(
          vehicleBloc: vehicleBloc,
          customerId: widget.customerId,
          onSuccess: _loadDetails,
        );
      },
    );
  }

  Color _getTimelineColor(String type) {
    switch (type) {
      case 'payment':
        return AppColors.successBorder;
      case 'work_order':
        return AppColors.primary;
      case 'check_in':
        return AppColors.infoBorder;
      case 'quote':
        return AppColors.warningBorder;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTimelineIcon(String type) {
    switch (type) {
      case 'payment':
        return LucideIcons.dollarSign;
      case 'work_order':
        return LucideIcons.wrench;
      case 'check_in':
        return LucideIcons.logIn;
      case 'quote':
        return LucideIcons.fileText;
      default:
        return LucideIcons.calendar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        backgroundColor: AppColors.bgDefault,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Customer Hub',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.successBorder),
            );
            _loadDetails();
          } else if (state is CustomerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.dangerBorder),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is CustomerDetailsLoaded) {
            final customer = state.customer;
            final vehicles = state.vehicles;
            final events = state.timelineEvents;
            final isFleet = customer.customerType == 'fleet';

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;

                final identityWidget = Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isFleet ? AppColors.infoBg : AppColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isFleet ? 'FLEET' : 'INDIVIDUAL',
                              style: AppTypography.bodySmall.copyWith(
                                color: isFleet ? AppColors.infoText : AppColors.successText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (customer.taxExempt) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.warningBg,
                                borderRadius: BorderRadius.circular(6),
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
                      const SizedBox(height: 24),
                      Divider(color: AppColors.borderDefault),
                      const SizedBox(height: 16),
                      Text(
                        'BILLING DETAILS',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        customer.billingAddress ?? 'No address registered',
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Edit Profile',
                        onPressed: () => _showEditProfileDialog(customer),
                        isSecondary: true,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Register Vehicle',
                        onPressed: _showAddVehicleDialog,
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'Create Estimate/Quote',
                        isSecondary: true,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return CreateQuoteDialog(
                                initialCustomerId: customer.id,
                                onSubmit: ({
                                  required String customerId,
                                  required String vehicleId,
                                  String? visitId,
                                  required double totalAmount,
                                  required DateTime validUntil,
                                }) {
                                  sl<QuoteBloc>().add(
                                    CreateQuoteEvent(
                                      customerId: customerId,
                                      vehicleId: vehicleId,
                                      visitId: visitId,
                                      totalAmount: totalAmount,
                                      validUntil: validUntil,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );

                final rightColumnContent = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Vehicles Sub-Section
                    Text(
                      'REGISTERED VEHICLES',
                      style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    if (vehicles.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderDefault),
                        ),
                        child: Center(
                          child: Text(
                            'No vehicles registered to this customer.',
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: vehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = vehicles[index];
                            return Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.bgSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderDefault),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(LucideIcons.car, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                          style: AppTypography.headingSmall.copyWith(
                                            color: AppColors.textPrimary,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'VIN: ${vehicle.vin}',
                                    style: AppTypography.monospace.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${vehicle.currentMileage.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} mi',
                                        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 32),
                    // Timeline History Section
                    Text(
                      'HISTORY TIMELINE',
                      style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final color = _getTimelineColor(event.type);
                        final icon = _getTimelineIcon(event.type);

                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSurface,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: color, width: 2),
                                    ),
                                    child: Icon(icon, size: 16, color: color),
                                  ),
                                  if (index != events.length - 1)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        color: AppColors.borderDefault,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 24.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSurface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.borderDefault),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Container(
                                              width: 4,
                                              color: color,
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            event.title,
                                                            style: AppTypography.bodyLarge.copyWith(
                                                              color: AppColors.textPrimary,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          '${event.date.month}/${event.date.day}/${event.date.year}',
                                                          style: AppTypography.bodySmall.copyWith(
                                                            color: AppColors.textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      event.description,
                                                      style: AppTypography.bodyMedium.copyWith(
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                    if (event.amount != null) ...[
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        event.amount!,
                                                        style: AppTypography.monospace.copyWith(
                                                          color: AppColors.textPrimary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );

                if (isWide) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: SingleChildScrollView(child: identityWidget),
                        ),
                        const SizedBox(width: 28),
                        Expanded(
                          child: SingleChildScrollView(child: rightColumnContent),
                        ),
                      ],
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          identityWidget,
                          const SizedBox(height: 24),
                          rightColumnContent,
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          } else if (state is CustomerError) {
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
                    onPressed: _loadDetails,
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
}
