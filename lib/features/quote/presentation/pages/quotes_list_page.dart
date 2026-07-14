import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/quote.dart';
import '../bloc/quote_bloc.dart';
import '../bloc/quote_event.dart';
import '../bloc/quote_state.dart';
import '../widgets/create_quote_dialog.dart';

class QuotesListPage extends StatefulWidget {
  const QuotesListPage({super.key});

  @override
  State<QuotesListPage> createState() => _QuotesListPageState();
}

class _QuotesListPageState extends State<QuotesListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    context.read<QuoteBloc>().add(const FetchQuotes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.blueGrey;
      case 'issued':
        return Colors.indigoAccent;
      case 'approved':
        return AppColors.successBorder;
      case 'declined':
        return Colors.redAccent;
      case 'expired':
        return AppColors.textDisabled;
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
          'Quotes & Estimates',
          style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textPrimary),
            onPressed: () => context.read<QuoteBloc>().add(const FetchQuotes(forceRefresh: true)),
          ),
        ],
      ),
      floatingActionButton: isAdvisor
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.plus, color: AppColors.bgDefault),
              label: Text(
                'New Quote',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.bgDefault,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _showCreateQuoteDialog(context),
            )
          : null,
      body: BlocConsumer<QuoteBloc, QuoteState>(
        listener: (context, state) {
          if (state is QuoteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.dangerBorder),
            );
          } else if (state is QuoteOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.successBorder),
            );
          }
        },
        builder: (context, state) {
          if (state is QuoteLoading || state is QuoteInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is QuotesLoaded) {
            final quotes = state.quotes;

            // Filter logic
            final filteredQuotes = quotes.where((q) {
              final customer = (q.customerName ?? '').toLowerCase();
              final vehicle = (q.vehicleName ?? '').toLowerCase();
              final vin = q.vehicleId.toLowerCase();
              final matchesSearch = customer.contains(_searchQuery.toLowerCase()) ||
                  vehicle.contains(_searchQuery.toLowerCase()) ||
                  vin.contains(_searchQuery.toLowerCase());

              final matchesStatus = _selectedStatusFilter == 'ALL' ||
                  q.status.toUpperCase() == _selectedStatusFilter;

              return matchesSearch && matchesStatus;
            }).toList();

            // Stats counts
            final total = quotes.length;
            final drafted = quotes.where((q) => q.status == 'draft').length;
            final issued = quotes.where((q) => q.status == 'issued').length;
            final approved = quotes.where((q) => q.status == 'approved').length;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuoteBloc>().add(const FetchQuotes(forceRefresh: true));
              },
              color: AppColors.primary,
              backgroundColor: AppColors.bgSurface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricsRow(total, drafted, issued, approved),
                    const SizedBox(height: 32),
                    _buildSearchAndFilters(),
                    const SizedBox(height: 24),
                    if (filteredQuotes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.fileQuestion, size: 48, color: AppColors.textDisabled),
                              const SizedBox(height: 16),
                              Text(
                                'No Quotes Found',
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
                        itemCount: filteredQuotes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final quote = filteredQuotes[index];
                          return _buildQuoteCard(quote, isAdvisor);
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Text(
              'Failed to load quotes.',
              style: AppTypography.bodyLarge.copyWith(color: AppColors.dangerText),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricsRow(int total, int drafted, int issued, int approved) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int crossAxisCount = width >= 768 ? 4 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: width >= 768 ? 1.6 : 2.2,
          children: [
            _buildMetricCard('TOTAL ESTIMATES', total.toString(), Colors.blueAccent),
            _buildMetricCard('DRAFTS', drafted.toString(), Colors.blueGrey),
            _buildMetricCard('PENDING REVIEW', issued.toString(), Colors.indigoAccent),
            _buildMetricCard('APPROVED', approved.toString(), AppColors.successBorder),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
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
                hintText: 'Search quotes by customer, model, or VIN...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textDisabled),
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatusFilter,
              dropdownColor: AppColors.bgSurface,
              icon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary, size: 16),
              items: <String>['ALL', 'DRAFT', 'ISSUED', 'APPROVED', 'DECLINED', 'EXPIRED']
                  .map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newVal) {
                if (newVal != null) {
                  setState(() {
                    _selectedStatusFilter = newVal;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteCard(Quote quote, bool isAdvisor) {
    final statusColor = _getStatusColor(quote.status);

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
                      quote.vehicleName ?? 'Unknown Vehicle',
                      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CLIENT: ${quote.customerName}',
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
                  quote.status.toUpperCase(),
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
                    'ESTIMATED AMOUNT',
                    style: AppTypography.monospace.copyWith(
                      color: AppColors.textDisabled,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${quote.totalAmount.toStringAsFixed(2)}',
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
                    'VALID UNTIL',
                    style: AppTypography.monospace.copyWith(
                      color: AppColors.textDisabled,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(quote.validUntil),
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (quote.declineReason != null && quote.declineReason!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Text(
                'Decline Reason: ${quote.declineReason}',
                style: AppTypography.bodySmall.copyWith(color: Colors.redAccent),
              ),
            ),
          ],
          if (isAdvisor && quote.status != 'expired') ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderDefault, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionsForStatus(context, quote),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildActionsForStatus(BuildContext context, Quote quote) {
    final List<Widget> actions = [];

    if (quote.status == 'draft') {
      actions.add(
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary),
          ),
          onPressed: () {
            context.read<QuoteBloc>().add(
                  UpdateQuoteStatusEvent(
                    quoteId: quote.quoteId,
                    status: 'issued',
                    issuedAt: DateTime.now(),
                  ),
                );
          },
          icon: const Icon(LucideIcons.send, size: 14, color: AppColors.primary),
          label: Text('Issue Estimate', style: const TextStyle(color: AppColors.primary)),
        ),
      );
    }

    if (quote.status == 'issued') {
      actions.add(
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
          ),
          onPressed: () => _showDeclineReasonDialog(context, quote.quoteId),
          icon: const Icon(LucideIcons.x, size: 14, color: Colors.redAccent),
          label: const Text('Decline', style: TextStyle(color: Colors.redAccent)),
        ),
      );
      actions.add(const SizedBox(width: 12));
      actions.add(
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successBorder,
          ),
          onPressed: () {
            context.read<QuoteBloc>().add(
                  UpdateQuoteStatusEvent(
                    quoteId: quote.quoteId,
                    status: 'approved',
                  ),
                );
          },
          icon: const Icon(LucideIcons.check, size: 14, color: AppColors.bgDefault),
          label: const Text('Approve', style: TextStyle(color: AppColors.bgDefault)),
        ),
      );
    }

    return actions;
  }

  void _showDeclineReasonDialog(BuildContext context, String quoteId) {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.bgSurface,
          title: Text(
            'Decline Quote Estimate',
            style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: reasonController,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Reason for declining',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Reason required' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<QuoteBloc>().add(
                        UpdateQuoteStatusEvent(
                          quoteId: quoteId,
                          status: 'declined',
                          declineReason: reasonController.text.trim(),
                        ),
                      );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Confirm Decline', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCreateQuoteDialog(BuildContext context) {
    final quoteBloc = context.read<QuoteBloc>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return CreateQuoteDialog(
          onSubmit: ({
            required String customerId,
            required String vehicleId,
            String? visitId,
            required double totalAmount,
            required DateTime validUntil,
          }) {
            quoteBloc.add(
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
  }
}
