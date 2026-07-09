import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<double?> getCurrentTemperature(double lat, double lon) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m');
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['current'] != null && data['current']['temperature_2m'] != null) {
          return (data['current']['temperature_2m'] as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      // API call failed, fail silently so UI doesn't crash
      return null;
    }
  }
}
