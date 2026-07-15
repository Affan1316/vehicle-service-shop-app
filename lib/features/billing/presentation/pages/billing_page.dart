import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/invoice.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';
import '../widgets/create_invoice_dialog.dart';
import '../widgets/collect_payment_dialog.dart';
import '../widgets/collect_deposit_dialog.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTab = 'UNPAID';

  @override
  void initState() {
    super.initState();
    context.read<BillingBloc>().add(const FetchInvoices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'issued':
        return Colors.indigoAccent;
      case 'paid':
        return AppColors.successBorder;
      case 'disputed':
        return Colors.orangeAccent;
      case 'voided':
        return AppColors.textDisabled;
      case 'credited':
        return Colors.tealAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAdvisor = authState is Authenticated &&
        (authState.user.role == 'manager' || authState.user.role == 'advisor');

    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        backgroundColor: AppColors.bgDefault,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Invoices & Payments',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textPrimary),
            onPressed: () => context.read<BillingBloc>().add(const FetchInvoices(forceRefresh: true)),
          ),
        ],
      ),
      body: BlocConsumer<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state is BillingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.dangerBorder),
            );
          } else if (state is BillingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.successBorder),
            );
          }
        },
        builder: (context, state) {
          if (state is BillingLoading || state is BillingInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is InvoicesLoaded) {
            final invoices = state.invoices;

            // Summary Metrics
            double collectedRevenue = 0.0;
            double outstandingBalance = 0.0;
            int pendingInvoicesCount = 0;

            for (var inv in invoices) {
              final outstanding = inv.totalBalance;
              final paidAmount = inv.amountDue - outstanding;
              collectedRevenue += paidAmount;
              if (inv.status.toLowerCase() == 'issued' || inv.status.toLowerCase() == 'disputed') {
                outstandingBalance += outstanding;
                pendingInvoicesCount++;
              }
            }

            // Filters
            final filteredInvoices = invoices.where((inv) {
              final matchesSearch = (inv.customerName ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  inv.workOrderNumber!.toLowerCase().contains(_searchQuery.toLowerCase());

              final status = inv.status.toLowerCase();
              bool matchesTab = false;
              if (_selectedTab == 'UNPAID') {
                matchesTab = (status == 'issued' || status == 'disputed');
              } else if (_selectedTab == 'PAID') {
                matchesTab = (status == 'paid');
              } else {
                matchesTab = true;
              }

              return matchesSearch && matchesTab;
            }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<BillingBloc>().add(const FetchInvoices(forceRefresh: true));
              },
              color: AppColors.primary,
              backgroundColor: AppColors.bgSurface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricsRow(collectedRevenue, outstandingBalance, pendingInvoicesCount),
                    const SizedBox(height: 32),
                    if (isAdvisor) ...[
                      _buildQuickActionsRow(context),
                      const SizedBox(height: 32),
                    ],
                    _buildSearchAndTabs(),
                    const SizedBox(height: 24),
                    if (filteredInvoices.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.fileWarning, size: 48, color: AppColors.textDisabled),
                              const SizedBox(height: 16),
                              Text(
                                'No Invoices Found',
                                style: AppTypography.headingMedium.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredInvoices.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final invoice = filteredInvoices[index];
                          return _buildInvoiceCard(invoice, isAdvisor);
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Text(
              'Failed to load billing history.',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.dangerText),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsRow(double collected, double outstanding, int pending) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width >= 768 ? 3 : 1;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: width >= 768 ? 1.8 : 3.0,
          children: [
            _buildMetricCard('COLLECTED REVENUE', '\$${collected.toStringAsFixed(2)}', AppColors.successBorder),
            _buildMetricCard('OUTSTANDING BALANCE', '\$${outstanding.toStringAsFixed(2)}', Colors.indigoAccent),
            _buildMetricCard('PENDING INVOICES', pending.toString(), Colors.orangeAccent),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.displayMedium.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BILLING OPERATIVE ACTIONS',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => _showCreateInvoiceDialog(context),
              icon: const Icon(LucideIcons.filePlus, size: 16, color: AppColors.primary),
              label: Text(
                'Generate Invoice',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.purpleAccent),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => _showCollectDepositDialog(context),
              icon: const Icon(LucideIcons.wallet, size: 16, color: Colors.purpleAccent),
              label: Text(
                'Collect Deposit',
                style: AppTypography.bodyMedium.copyWith(color: Colors.purpleAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndTabs() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by client or work order ID...',
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
              prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildTabButton('UNPAID', 'Issued / Disputed'),
            const SizedBox(width: 8),
            _buildTabButton('PAID', 'Completed payments'),
            const SizedBox(width: 8),
            _buildTabButton('ALL', 'Full history'),
          ],
        ),
      ],
    );
  }

  Widget _buildTabButton(String tabKey, String tooltip) {
    final isSelected = _selectedTab == tabKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderDefault),
        ),
        child: Text(
          tabKey,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice, bool isAdvisor) {
    final statusColor = _getStatusColor(invoice.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.workOrderNumber ?? 'Unknown Work Order',
                      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CLIENT: ${invoice.customerName}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withOpacity(0.5), width: 0.5),
                ),
                child: Text(
                  invoice.status.toUpperCase(),
                  style: AppTypography.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.borderDefault, height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL BILLED',
                    style: AppTypography.monospace.copyWith(
                      color: AppColors.textDisabled,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${invoice.amountDue.toStringAsFixed(2)}',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'OUTSTANDING BALANCE',
                    style: AppTypography.monospace.copyWith(
                      color: AppColors.textDisabled,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${invoice.totalBalance.toStringAsFixed(2)}',
                    style: AppTypography.bodyLarge.copyWith(
                      color: invoice.totalBalance > 0 ? Colors.orangeAccent : AppColors.successBorder,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Issued At: ${_formatDate(invoice.issuedAt)}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textDisabled),
          ),
          if (isAdvisor && (invoice.status == 'issued' || invoice.status == 'disputed')) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderDefault, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (invoice.status == 'issued') ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orangeAccent),
                    ),
                    onPressed: () {
                      context.read<BillingBloc>().add(
                            UpdateInvoiceStatusEvent(
                              invoiceId: invoice.invoiceId,
                              status: 'disputed',
                            ),
                          );
                    },
                    icon: const Icon(LucideIcons.helpCircle, size: 14, color: Colors.orangeAccent),
                    label: const Text('Dispute', style: TextStyle(color: Colors.orangeAccent)),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successBorder,
                  ),
                  onPressed: () => _showCollectPaymentDialog(context, invoice),
                  icon: const Icon(LucideIcons.dollarSign, size: 14, color: AppColors.bgDefault),
                  label: const Text('Collect Payment', style: TextStyle(color: AppColors.bgDefault)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    final billingBloc = context.read<BillingBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CreateInvoiceDialog(
          onSubmit: ({
            required String workOrderId,
            required String customerId,
            required double amountDue,
          }) {
            billingBloc.add(
              CreateInvoiceEvent(
                workOrderId: workOrderId,
                customerId: customerId,
                amountDue: amountDue,
              ),
            );
          },
        );
      },
    );
  }

  void _showCollectDepositDialog(BuildContext context) {
    final billingBloc = context.read<BillingBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CollectDepositDialog(
          onSubmit: ({
            required String quoteId,
            required String customerId,
            String? workOrderId,
            required double amount,
          }) {
            billingBloc.add(
              RecordDepositEvent(
                quoteId: quoteId,
                customerId: customerId,
                workOrderId: workOrderId,
                amount: amount,
              ),
            );
          },
        );
      },
    );
  }

  void _showCollectPaymentDialog(BuildContext context, Invoice invoice) {
    final billingBloc = context.read<BillingBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CollectPaymentDialog(
          invoice: invoice,
          onSubmit: ({
            required String invoiceId,
            required double amount,
            required String method,
          }) {
            billingBloc.add(
              RecordPaymentEvent(
                invoiceId: invoiceId,
                amount: amount,
                method: method,
              ),
            );
          },
        );
      },
    );
  }
}
