import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherResult {
  final double temperature;
  final String weatherCodeDescription;
  final double windSpeedKmH;
  final int humidity;
  final String spotCondition;

  WeatherResult({
    required this.temperature,
    required this.weatherCodeDescription,
    required this.windSpeedKmH,
    required this.humidity,
    required this.spotCondition,
  });
}

class WeatherApiService {
  /// Fetch real-time fishing weather from open-meteo free weather API (no auth key required)
  static Future<WeatherResult?> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
      );

      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final current = data['current'] as Map<String, dynamic>;

        final temp = (current['temperature_2m'] as num).toDouble();
        final humidity = (current['relative_humidity_2m'] as num).toInt();
        final wind = (current['wind_speed_10m'] as num).toDouble();
        final code = (current['weather_code'] as num).toInt();

        final conditionStr = _decodeWeatherCode(code);

        String spotVerdict = 'Kondisi Ideal untuk Mancing';
        if (wind > 25.0) {
          spotVerdict = 'Angin Kencang! Waspada ombak perairan.';
        } else if (temp > 34.0) {
          spotVerdict = 'Suhu Terik. Ikan cenderung bersembunyi di palung.';
        }

        return WeatherResult(
          temperature: temp,
          weatherCodeDescription: conditionStr,
          windSpeedKmH: wind,
          humidity: humidity,
          spotCondition: spotVerdict,
        );
      }
    } catch (_) {}
    return null;
  }

  static String _decodeWeatherCode(int code) {
    if (code == 0) return 'Cerah Berawan ☀️';
    if (code >= 1 && code <= 3) return 'Sebagian Berawan ⛅';
    if (code >= 45 && code <= 48) return 'Berkabut / Dingin 🌫️';
    if (code >= 51 && code <= 67) return 'Hujan Ringan 🌧️';
    if (code >= 71 && code <= 77) return 'Hawa Dingin Salju ❄️';
    if (code >= 80 && code <= 82) return 'Hujan Deras ⛈️';
    if (code >= 95) return 'Badai Petir Muara ⚡';
    return 'Berawan Lembab ⛅';
  }
}
