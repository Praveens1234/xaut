import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/services/gold_price_service.dart';

class ConnectionStatusBar extends StatelessWidget {
  final PriceFeedStatus status;

  const ConnectionStatusBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String message;
    Color color;
    IconData icon;

    switch (status) {
      case PriceFeedStatus.connecting:
        message = 'Connecting to price feed...';
        color = AppTheme.goldPrimary;
        icon = Icons.wifi_find_rounded;
        break;
      case PriceFeedStatus.reconnecting:
        message = 'Reconnecting... Price data may be delayed';
        color = AppTheme.goldSecondary;
        icon = Icons.wifi_find_rounded;
        break;
      case PriceFeedStatus.disconnected:
        message = 'Offline — showing cached data';
        color = AppTheme.priceDown;
        icon = Icons.wifi_off_rounded;
        break;
      case PriceFeedStatus.error:
        message = 'Feed error — retrying automatically';
        color = AppTheme.priceDown;
        icon = Icons.error_outline_rounded;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (status == PriceFeedStatus.connecting ||
              status == PriceFeedStatus.reconnecting)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}
