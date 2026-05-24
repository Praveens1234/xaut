import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/price_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';

class BidAskWidget extends StatelessWidget {
  final PriceModel price;

  const BidAskWidget({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PriceBox(
            label: 'BID',
            price: price.bid,
            color: AppTheme.priceDown,
            icon: Icons.south_rounded,
          ),
        ),
        const SizedBox(width: 8),
        _SpreadBox(spread: price.spread),
        const SizedBox(width: 8),
        Expanded(
          child: _PriceBox(
            label: 'ASK',
            price: price.ask,
            color: AppTheme.priceUp,
            icon: Icons.north_rounded,
          ),
        ),
      ],
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final double price;
  final Color color;
  final IconData icon;

  const _PriceBox({
    required this.label,
    required this.price,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            FormatUtils.formatPrice(price),
            style: GoogleFonts.spaceMono(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpreadBox extends StatelessWidget {
  final double spread;

  const _SpreadBox({required this.spread});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkCardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          Text(
            'SPREAD',
            style: GoogleFonts.dmSans(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9898B8),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            spread.toStringAsFixed(2),
            style: GoogleFonts.spaceMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9898B8),
            ),
          ),
        ],
      ),
    );
  }
}
