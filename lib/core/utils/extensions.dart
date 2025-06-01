// lib/core/utils/extensions.dart
import 'package:intl/intl.dart';

extension StringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  bool get isNotEmptyOrNull => !isNullOrEmpty;

  String capitalize() {
    if (this == null || this!.isEmpty) return '';
    return this![0].toUpperCase() + this!.substring(1);
  }
}

extension DateTimeExtensions on DateTime? {
  bool get isNull => this == null;
  bool get isNotNull => this != null;

  String toFormattedString(String pattern) {
    if (this == null) return '';
    return DateFormat(pattern).format(this!);
  }
}

extension NumExtensions on num {
  String toCurrency({String locale = 'en_US', String symbol = '\$'}) {
    final format = NumberFormat.currency(locale: locale, symbol: symbol);
    return format.format(this);
  }
}
