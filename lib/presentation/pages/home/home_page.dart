import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../bloc/alert/alert_bloc.dart';
import '../../bloc/price/price_bloc.dart';
import '../../widgets/common/gold_shimmer.dart';
import '../../widgets/price/bid_ask_widget.dart';
import '../../widgets/price/connection_status_bar.dart';
import '../../widgets/price/live_price_card.dart';
import '../../widgets/price/mini_chart.dart';
import '../../widgets/price/price_stats_row.dart';
import '../alerts/create_alert_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: SafeArea(
          child: BlocBuilder<PriceBloc, PriceState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildAppBar(context, state),
                  if (state is PriceLoaded)
                    _buildConnectionStatus(context, state),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        if (state is PriceLoading || state is PriceInitial)
                          const GoldShimmer()
                        else if (state is PriceLoaded) ...[
                          LivePriceCard(price: state.price)
                              .animate()
                              .fadeIn(duration: 400.ms),
                          const SizedBox(height: 12),
                          BidAskWidget(price: state.price),
                          const SizedBox(height: 12),
                          PriceStatsRow(price: state.price),
                          const SizedBox(height: 16),
                          MiniChart(ticks: state.ticks),
                          const SizedBox(height: 16),
                          _buildQuickAlertButton(context, state),
                        ] else if (state is PriceError)
                          _buildErrorState(context, state.message),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, PriceState state) {
    return SliverAppBar(
      backgroundColor: AppTheme.darkBg,
      floating: true,
      snap: true,
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.goldPrimary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.4)),
            ),
            child: const Icon(
              Icons.currency_exchange_rounded,
              color: AppTheme.goldPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'XAUT',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'XAU/USD Gold Tracker',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9898B8),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        if (state is PriceLoaded)
          _buildLiveIndicator(state)
        else
          const SizedBox(width: 8),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF9898B8)),
          onPressed: () =>
              context.read<PriceBloc>().add(const RestartPriceFeed()),
          tooltip: 'Restart Feed',
        ),
      ],
    );
  }

  Widget _buildLiveIndicator(PriceLoaded state) {
    final isConnected = state.isConnected;
    final isConnecting = state.isConnecting;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.priceUp.withOpacity(0.12)
            : isConnecting
                ? AppTheme.goldPrimary.withOpacity(0.12)
                : AppTheme.priceDown.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConnected
              ? AppTheme.priceUp.withOpacity(0.3)
              : isConnecting
                  ? AppTheme.goldPrimary.withOpacity(0.3)
                  : AppTheme.priceDown.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isConnecting)
            SizedBox(
              width: 6,
              height: 6,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppTheme.goldPrimary,
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isConnected ? AppTheme.priceUp : AppTheme.priceDown,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 600.ms)
                .then()
                .fadeOut(duration: 600.ms),
          const SizedBox(width: 5),
          Text(
            isConnected
                ? 'LIVE'
                : isConnecting
                    ? 'CONNECTING'
                    : 'OFFLINE',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isConnected
                  ? AppTheme.priceUp
                  : isConnecting
                      ? AppTheme.goldPrimary
                      : AppTheme.priceDown,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, PriceLoaded state) {
    if (state.isConnected) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: ConnectionStatusBar(status: state.feedStatus),
    );
  }

  Widget _buildQuickAlertButton(BuildContext context, PriceLoaded state) {
    return GestureDetector(
      onTap: () => _showCreateAlert(context, state.price.mid),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.goldPrimary.withOpacity(0.12),
              AppTheme.goldSecondary.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.goldPrimary.withOpacity(0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_alert_rounded,
              color: AppTheme.goldPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Set Price Alert',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.goldPrimary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              color: AppTheme.priceDown.withOpacity(0.6), size: 48),
          const SizedBox(height: 16),
          Text(
            'Connection Error',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.dmSans(
              color: const Color(0xFF9898B8),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                context.read<PriceBloc>().add(const RestartPriceFeed()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showCreateAlert(BuildContext context, double currentPrice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AlertBloc>(),
        child: CreateAlertSheet(suggestedPrice: currentPrice),
      ),
    );
  }
}
