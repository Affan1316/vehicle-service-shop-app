import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/bay.dart';
import '../bloc/bay_bloc.dart';
import '../bloc/bay_event.dart';
import '../bloc/bay_state.dart';

class BayBoardWidget extends StatelessWidget {
  const BayBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BayBloc, BayState>(
      builder: (context, state) {
        if (state is BayLoading) {
          return _buildShell(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        if (state is BayError) {
          return _buildShell(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.circleAlert, color: AppColors.dangerText, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.dangerText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => context.read<BayBloc>().add(const FetchBays()),
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Retry'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is BaysLoaded) {
          return _buildShell(
            child: _buildBayGrid(context, state.bays),
            trailing: _buildSummaryRow(state.bays),
          );
        }

        if (state is BayOperationSuccess) {
          // After a successful update, re-fetch the bay list
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<BayBloc>().add(const FetchBays());
          });
          return _buildShell(
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        return _buildShell(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Text(
                'Loading bay data...',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShell({required Widget child, Widget? trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(LucideIcons.warehouse, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shop Floor — Bay Status',
                        style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Live allocation of physical service bays',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: trailing,
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: AppColors.borderDefault, height: 1),
          const SizedBox(height: 16),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(List<Bay> bays) {
    final available = bays.where((b) => b.status == 'available').length;
    final occupied = bays.where((b) => b.status == 'occupied').length;
    final held = bays.where((b) => b.status == 'held' || b.status == 'confirmed').length;
    final maintenance = bays.where((b) => b.status == 'cleaning' || b.status == 'maintenance').length;

    return Row(
      children: [
        _buildPill('$available Open', AppColors.successBorder),
        const SizedBox(width: 8),
        _buildPill('$occupied In Use', AppColors.dangerBorder),
        const SizedBox(width: 8),
        _buildPill('$held Reserved', AppColors.warningBorder),
        const SizedBox(width: 8),
        _buildPill('$maintenance Offline', AppColors.textSecondary),
      ],
    );
  }

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildBayGrid(BuildContext context, List<Bay> bays) {
    if (bays.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(LucideIcons.warehouse, color: AppColors.textSecondary, size: 40),
              const SizedBox(height: 12),
              Text(
                'No bays configured yet',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 700
            ? 4
            : constraints.maxWidth >= 500
                ? 3
                : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemCount: bays.length,
          itemBuilder: (context, index) {
            return _buildBayCard(context, bays[index]);
          },
        );
      },
    );
  }

  Widget _buildBayCard(BuildContext context, Bay bay) {
    final config = _getBayStatusConfig(bay.status);

    return GestureDetector(
      onTap: () => _showBayActionSheet(context, bay),
      child: Container(
        decoration: BoxDecoration(
          color: config.bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: config.borderColor, width: 1.5),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(config.icon, color: config.iconColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bay.bayType,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: config.pillBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                config.label,
                style: AppTypography.bodySmall.copyWith(
                  color: config.pillTextColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _BayStatusConfig _getBayStatusConfig(String status) {
    switch (status) {
      case 'available':
        return _BayStatusConfig(
          label: 'AVAILABLE',
          icon: LucideIcons.circleCheckBig,
          iconColor: AppColors.successBorder,
          borderColor: AppColors.successBorder.withValues(alpha: 0.4),
          bgColor: AppColors.successBg.withValues(alpha: 0.35),
          pillBg: AppColors.successBg,
          pillTextColor: AppColors.successText,
        );
      case 'occupied':
        return _BayStatusConfig(
          label: 'OCCUPIED',
          icon: LucideIcons.car,
          iconColor: AppColors.dangerBorder,
          borderColor: AppColors.dangerBorder.withValues(alpha: 0.4),
          bgColor: AppColors.dangerBg.withValues(alpha: 0.35),
          pillBg: AppColors.dangerBg,
          pillTextColor: AppColors.dangerText,
        );
      case 'held':
        return _BayStatusConfig(
          label: 'RESERVED',
          icon: LucideIcons.clock,
          iconColor: AppColors.warningBorder,
          borderColor: AppColors.warningBorder.withValues(alpha: 0.4),
          bgColor: AppColors.warningBg.withValues(alpha: 0.35),
          pillBg: AppColors.warningBg,
          pillTextColor: AppColors.warningText,
        );
      case 'confirmed':
        return _BayStatusConfig(
          label: 'CONFIRMED',
          icon: LucideIcons.shieldCheck,
          iconColor: AppColors.infoBorder,
          borderColor: AppColors.infoBorder.withValues(alpha: 0.4),
          bgColor: AppColors.infoBg.withValues(alpha: 0.35),
          pillBg: AppColors.infoBg,
          pillTextColor: AppColors.infoText,
        );
      case 'cleaning':
        return _BayStatusConfig(
          label: 'CLEANING',
          icon: LucideIcons.sparkles,
          iconColor: AppColors.textSecondary,
          borderColor: AppColors.borderDefault,
          bgColor: AppColors.bgElevated.withValues(alpha: 0.5),
          pillBg: AppColors.bgElevated,
          pillTextColor: AppColors.textSecondary,
        );
      case 'maintenance':
        return _BayStatusConfig(
          label: 'MAINTENANCE',
          icon: LucideIcons.wrench,
          iconColor: AppColors.textSecondary,
          borderColor: AppColors.borderDefault,
          bgColor: AppColors.bgElevated.withValues(alpha: 0.5),
          pillBg: AppColors.bgElevated,
          pillTextColor: AppColors.textSecondary,
        );
      default:
        return _BayStatusConfig(
          label: status.toUpperCase(),
          icon: LucideIcons.helpCircle,
          iconColor: AppColors.textSecondary,
          borderColor: AppColors.borderDefault,
          bgColor: AppColors.bgElevated,
          pillBg: AppColors.bgElevated,
          pillTextColor: AppColors.textSecondary,
        );
    }
  }

  void _showBayActionSheet(BuildContext context, Bay bay) {
    final bayBloc = context.read<BayBloc>();
    final statuses = ['available', 'occupied', 'held', 'cleaning', 'maintenance'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderActive,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                bay.bayType,
                style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Bay ID: ${bay.bayId.substring(0, 8).toUpperCase()}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Text(
                'Change Status',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: statuses.map((s) {
                  final isActive = s == bay.status;
                  final config = _getBayStatusConfig(s);
                  return ChoiceChip(
                    selected: isActive,
                    label: Text(config.label),
                    labelStyle: TextStyle(
                      color: isActive ? Colors.white : AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.bgElevated,
                    selectedColor: config.iconColor,
                    side: BorderSide(
                      color: isActive ? config.iconColor : AppColors.borderDefault,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onSelected: isActive
                        ? null
                        : (_) {
                            Navigator.pop(sheetContext);
                            bayBloc.add(UpdateBayAllocation(
                              bayId: bay.bayId,
                              status: s,
                              clearWorkOrder: s == 'available' || s == 'cleaning' || s == 'maintenance',
                            ));
                          },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _BayStatusConfig {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color borderColor;
  final Color bgColor;
  final Color pillBg;
  final Color pillTextColor;

  const _BayStatusConfig({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.borderColor,
    required this.bgColor,
    required this.pillBg,
    required this.pillTextColor,
  });
}
