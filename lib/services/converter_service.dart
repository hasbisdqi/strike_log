import 'dart:convert';
import 'package:http/http.dart' as http;

class ConverterService {
  // Exchange rates fallback jika offline
  static final Map<String, double> _cachedRatesToIdr = {
    'IDR': 1.0,
    'USD': 16250.0,
    'JPY': 105.0,
    'EUR': 17400.0,
  };

  /// Ambil kurs terbaru online dari open exchange API atau pakai cached rates
  static Future<Map<String, double>> fetchLatestRates() async {
    try {
      final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final resp = await http.get(url).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final rates = data['rates'] as Map<String, dynamic>;
        final usdToIdr = (rates['IDR'] as num).toDouble();
        final usdToJpy = (rates['JPY'] as num).toDouble();
        final usdToEur = (rates['EUR'] as num).toDouble();

        _cachedRatesToIdr['USD'] = usdToIdr;
        _cachedRatesToIdr['JPY'] = usdToIdr / usdToJpy;
        _cachedRatesToIdr['EUR'] = usdToIdr / usdToEur;
      }
    } catch (_) {}
    return _cachedRatesToIdr;
  }

  /// Konversi antar mata uang (IDR, USD, JPY, EUR)
  static double convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    Map<String, double>? rates,
  }) {
    final activeRates = rates ?? _cachedRatesToIdr;
    final fromRate = activeRates[fromCurrency] ?? 1.0;
    final toRate = activeRates[toCurrency] ?? 1.0;

    // Convert to IDR first, then to target currency
    final inIdr = amount * fromRate;
    return inIdr / toRate;
  }

  /// Konversi waktu tangkapan ke berbagai zona waktu:
  /// WIB (UTC+7), WITA (UTC+8), WIT (UTC+9), London GMT (UTC+0)
  static DateTime convertTimeZone(DateTime baseTimeUtc, String targetZone) {
    switch (targetZone) {
      case 'WIB (UTC+7)':
        return baseTimeUtc.toUtc().add(const Duration(hours: 7));
      case 'WITA (UTC+8)':
        return baseTimeUtc.toUtc().add(const Duration(hours: 8));
      case 'WIT (UTC+9)':
        return baseTimeUtc.toUtc().add(const Duration(hours: 9));
      case 'London GMT (UTC+0)':
        return baseTimeUtc.toUtc();
      default:
        return baseTimeUtc;
    }
  }
}
