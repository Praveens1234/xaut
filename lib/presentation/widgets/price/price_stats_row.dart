import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/price_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';

class PriceStatsRow extends StatelessWidget {
  final PriceModel price;

  const PriceStatsRow({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          Expanded(child: _StatItem(label: 'OPEN', value: FormatUtils.formatPrice(price.open))),
          _Divider(),
          Expanded(child: _StatItem(label: 'HIGH', value: FormatUtils.formatPrice(price.high), color: AppTheme.priceUp)),
          _Divider(),
          Expanded(child: _StatItem(label: 'LOW', value: FormatUtils.formatPrice(price.low), color: AppTheme.priceDown)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppTheme.darkBorder,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5A5A7A),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color ?? Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
