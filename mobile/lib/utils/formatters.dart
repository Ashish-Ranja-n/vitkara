import 'package:intl/intl.dart';

/// Centralized currency formatter helpers
NumberFormat _inrFmt() => NumberFormat.currency(locale: 'en_IN', symbol: '₹');

String formatINRFromPaise(int paise) {
  // paise is integer (₹1 = 100 paise). Convert to rupees as double for formatting.
  return _inrFmt().format(paise / 100.0);
}

/// Returns a short display for an index like 1.25 -> ~1.25x
String formatIndex(double index) {
  return "~${index.toStringAsFixed(2)}x";
}
