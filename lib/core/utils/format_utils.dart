import 'package:intl/intl.dart';

class FormatUtils {
  static final _priceFormat = NumberFormat('#,##0.00', 'en_US');
  static final _pricePreciseFormat = NumberFormat('#,##0.000', 'en_US');
  static final _changeFormat = NumberFormat('+#,##0.00;-#,##0.00', 'en_US');
  static final _percentFormat = NumberFormat('+0.00%;-0.00%', 'en_US');
  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _dateFormat = DateFormat('MMM dd, yyyy');
  static final _dateTimeFormat = DateFormat('MMM dd HH:mm');

  static String formatPrice(double price, {int decimals = 2}) {
    if (decimals == 3) return _pricePreciseFormat.format(price);
    return _priceFormat.format(price);
  }

  static String formatChange(double change) {
    return _changeFormat.format(change);
  }

  static String formatPercent(double percent) {
    return _percentFormat.format(percent / 100);
  }

  static String formatTime(DateTime dt) => _timeFormat.format(dt);
  static String formatDate(DateTime dt) => _dateFormat.format(dt);
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  static String formatSpread(double spread) {
    return spread.toStringAsFixed(2);
  }

  static String formatPriceInput(String value) {
    value = value.replaceAll(',', '');
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    return _priceFormat.format(parsed);
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 10) return 'just now';
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return formatDate(dt);
  }

  static String formatVolume(double vol) {
    if (vol >= 1000000) return '${(vol / 1000000).toStringAsFixed(1)}M';
    if (vol >= 1000) return '${(vol / 1000).toStringAsFixed(1)}K';
    return vol.toStringAsFixed(0);
  }
}
