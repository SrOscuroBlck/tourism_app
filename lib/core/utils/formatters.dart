// lib/core/utils/formatters.dart
import 'package:intl/intl.dart';

class Formatters {
  static String formatDate(DateTime date, {String pattern = 'yyyy-MM-dd'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime dateTime, {String pattern = 'yyyy-MM-dd HH:mm'}) {
    return DateFormat(pattern).format(dateTime);
  }

  static String formatNumber(num number, {String locale = 'en_US'}) {
    return NumberFormat.decimalPattern(locale).format(number);
  }

  static String formatCurrency(num amount, {String locale = 'en_US', String symbol = '\$'}) {
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(amount);
  }

  static String formatPercentage(double value, {int fractionDigits = 0}) {
    final formatter = NumberFormat.percentPattern()..minimumFractionDigits = fractionDigits;
    return formatter.format(value);
  }
}
