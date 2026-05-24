import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/price_model.dart';

class LivePriceCard extends StatefulWidget {
  final PriceModel price;

  const LivePriceCard({super.key, required this.price});

  @override
  State<LivePriceCard> createState() => _LivePriceCardState();
}

class _LivePriceCardState extends State<LivePriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  PriceModel? _prevPrice;
  Color _flashColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.transparent,
    ).animate(_flashController);
  }

  @override
  void didUpdateWidget(LivePriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_prevPrice != null && _prevPrice!.mid != widget.price.mid) {
      final isUp = widget.price.mid > _prevPrice!.mid;
      _triggerFlash(isUp);
    }
    _prevPrice = widget.price;
  }

  void _triggerFlash(bool isUp) {
    _flashColor = isUp
        ? AppTheme.priceUp.withOpacity(0.15)
        : AppTheme.priceDown.withOpacity(0.15);
    _flashAnimation = ColorTween(
      begin: _flashColor,
      end: Colors.transparent,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    ));
    _flashController.forward(from: 0);
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.price;
    final isUp = price.isUp;

    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: _flashAnimation.value ?? AppTheme.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUp
                  ? AppTheme.priceUp.withOpacity(0.25)
                  : AppTheme.priceDown.withOpacity(0.25),
              width: 1,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.darkCard,
                AppTheme.darkCard.withOpacity(0.95),
              ],
            ),
          ),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(price),
            const SizedBox(height: 16),
            _buildMainPrice(price, isUp),
            const SizedBox(height: 12),
            _buildChangeRow(price, isUp),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PriceModel price) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.goldPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
          ),
          child: Text(
            'XAU/USD',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.goldPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Gold Spot',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: const Color(0xFF9898B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          FormatUtils.formatTime(price.timestamp),
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            color: const Color(0xFF9898B8),
          ),
        ),
      ],
    );
  }

  Widget _buildMainPrice(PriceModel price, bool isUp) {
    final priceStr = FormatUtils.formatPrice(price.mid);
    final parts = priceStr.split('.');
    final whole = parts[0];
    final decimal = parts.length > 1 ? '.${parts[1]}' : '.00';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$',
          style: GoogleFonts.spaceMono(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9898B8),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          whole,
          style: GoogleFonts.spaceMono(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            decimal,
            style: GoogleFonts.spaceMono(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isUp ? AppTheme.priceUp : AppTheme.priceDown,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isUp ? AppTheme.priceUp : AppTheme.priceDown,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeRow(PriceModel price, bool isUp) {
    final color = isUp ? AppTheme.priceUp : AppTheme.priceDown;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: color,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${FormatUtils.formatChange(price.change)} (${FormatUtils.formatPercent(price.changePercent)})',
                style: GoogleFonts.spaceMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Today',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: const Color(0xFF5A5A7A),
          ),
        ),
        const Spacer(),
        if (!price.isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'SIMULATED',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5A5A7A),
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}
