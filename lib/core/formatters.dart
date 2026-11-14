import 'constants.dart';

/// Quy doi USD -> VND va lam tron den hang nghin.
/// Vi du: 9.99 USD -> 249.750 -> 250.000
int usdToVnd(num usd) => ((usd * kUsdToVnd) / 1000).round() * 1000;

/// Dinh dang so tien kieu Viet Nam: 1250000 -> "1.250.000₫"
String formatVnd(int amount) {
  final digits = amount.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  final sign = amount < 0 ? '-' : '';
  return '$sign$buffer₫';
}
