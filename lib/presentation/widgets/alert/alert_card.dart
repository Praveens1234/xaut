import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = alert.isActive;
    final isTriggered = alert.isTriggered;
    final isAbove = alert.direction == TriggerDirection.crossAbove;

    Color statusColor;
    if (isTriggered) {
      statusColor = AppTheme.goldPrimary;
    } else if (isActive) {
      statusColor = AppTheme.priceUp;
    } else {
      statusColor = const Color(0xFF5A5A7A);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(alert.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.priceDown.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: AppTheme.priceDown),
        ),
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? statusColor.withOpacity(0.2)
                    : AppTheme.darkBorder,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildDirectionIcon(isAbove, statusColor),
                    const SizedBox(width: 12),
                    Expanded(child: _buildPriceInfo(isAbove, statusColor)),
                    _buildStatusChip(isTriggered, isActive),
                    const SizedBox(width: 8),
                    Switch(
                      value: isActive,
                      onChanged: isTriggered ? null : (_) => onToggle(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                if (alert.label.isNotEmpty || isTriggered) ...[
                  const SizedBox(height: 10),
                  _buildBottomRow(isTriggered),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionIcon(bool isAbove, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Icon(
        isAbove ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildPriceInfo(bool isAbove, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '\$${alert.targetPrice.toStringAsFixed(2)}',
              style: GoogleFonts.spaceMono(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${alert.directionIcon} ${isAbove ? 'Cross Above' : 'Cross Below'}',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: const Color(0xFF9898B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _typeChip(alert.alertTypeLabel),
            const SizedBox(width: 6),
            _typeChip(_repeatLabel(alert.repeatMode)),
          ],
        ),
      ],
    );
  }

  Widget _typeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.darkCardElevated,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF5A5A7A),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isTriggered, bool isActive) {
    if (isTriggered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.goldPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'TRIGGERED',
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppTheme.goldPrimary,
            letterSpacing: 0.5,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBottomRow(bool isTriggered) {
    return Row(
      children: [
        if (alert.label.isNotEmpty) ...[
          const Icon(Icons.label_outline_rounded, size: 13, color: Color(0xFF5A5A7A)),
          const SizedBox(width: 4),
          Text(
            alert.label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: const Color(0xFF9898B8),
            ),
          ),
        ],
        const Spacer(),
        if (isTriggered && alert.triggeredAt != null)
          Text(
            'Triggered ${FormatUtils.timeAgo(alert.triggeredAt!)}',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppTheme.goldPrimary.withOpacity(0.7),
            ),
          )
        else
          Text(
            FormatUtils.timeAgo(alert.createdAt),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: const Color(0xFF5A5A7A),
            ),
          ),
      ],
    );
  }

  String _repeatLabel(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.once:
        return 'Once';
      case RepeatMode.everyMinute:
        return 'Every 1m';
      case RepeatMode.every5Minutes:
        return 'Every 5m';
      case RepeatMode.every15Minutes:
        return 'Every 15m';
      case RepeatMode.untilDismissed:
        return 'Repeat';
    }
  }
}
