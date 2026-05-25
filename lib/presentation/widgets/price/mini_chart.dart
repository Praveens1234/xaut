import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/price_model.dart';

class MiniChart extends StatelessWidget {
  final List<PriceTick> ticks;

  const MiniChart({super.key, required this.ticks});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildHeader(),
          const SizedBox(height: 12),
          Expanded(child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Text(
          'Price Movement',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9898B8),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.darkCardElevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '5 MIN',
            style: GoogleFonts.dmSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A5A7A),
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (ticks.isEmpty) {
      return Center(
        child: Text(
          'Collecting data...',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: const Color(0xFF5A5A7A),
          ),
        ),
      );
    }

    final List<FlSpot> spots = ticks.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.price);
    }).toList();

    final List<double> prices = ticks.map((t) => t.price).toList();
    final double minY = prices.reduce((a, b) => a < b ? a : b) - 0.5;
    final double maxY = prices.reduce((a, b) => a > b ? a : b) + 0.5;
    final bool lastIsUp = ticks.last.isUp;
    final Color lineColor =
        lastIsUp ? AppTheme.priceUp : AppTheme.priceDown;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          horizontalInterval: (maxY - minY) / 4,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppTheme.darkDivider,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(),
          ),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: lineColor,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: <Color>[
                  lineColor.withAlpha(38),
                  lineColor.withAlpha(0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppTheme.darkCardElevated,
            getTooltipItems: (List<LineBarSpot> barSpots) =>
                barSpots.map((LineBarSpot s) {
              return LineTooltipItem(
                '\$${s.y.toStringAsFixed(2)}',
                GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
