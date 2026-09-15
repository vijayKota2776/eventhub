import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppCurrency {
  usd('USD', '\$', 1.0),
  inr('INR', '₹', 83.50),
  eur('EUR', '€', 0.92),
  gbp('GBP', '£', 0.78);

  final String code;
  final String symbol;
  final double rateFromUsd;

  const AppCurrency(this.code, this.symbol, this.rateFromUsd);
}

class CurrencyNotifier extends Notifier<AppCurrency> {
  @override
  AppCurrency build() => AppCurrency.usd;

  void setCurrency(AppCurrency currency) {
    state = currency;
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, AppCurrency>(() {
  return CurrencyNotifier();
});

class CurrencyHelper {
  static double convertFromUsd(double amountUsd, AppCurrency currency) {
    return amountUsd * currency.rateFromUsd;
  }

  static String format(double amountUsd, AppCurrency currency) {
    final converted = convertFromUsd(amountUsd, currency);
    if (currency == AppCurrency.inr) {
      // INR formatting with no decimals if integer
      return '${currency.symbol}${converted.toStringAsFixed(converted % 1 == 0 ? 0 : 2)}';
    }
    return '${currency.symbol}${converted.toStringAsFixed(2)}';
  }
}
