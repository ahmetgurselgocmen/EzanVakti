import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() async {
  const radius = 3000; // 3 km
  final query = '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,41.0082,28.9784);
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,41.0082,28.9784);
);
out center 30;
''';

  for (final baseUrl in [
    'https://lz4.overpass-api.de/api/interpreter', // Fast mirror 1
    'https://z.overpass-api.de/api/interpreter',   // Fast mirror 2
    'https://overpass-api.de/api/interpreter',     // Main mirror (sometimes 504)
    'https://overpass.osm.ch/api/interpreter',     // Swiss mirror
    'https://overpass.kumi.systems/api/interpreter',
  ]) {
    print('Trying: $baseUrl');
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'User-Agent': 'EzanVaktiApp/1.0 (Flutter)'},
        body: query,
      ).timeout(const Duration(seconds: 20));
      print('Status: ${response.statusCode}');
      if (response.statusCode == 200) break;
    } catch (e) {
      print('Error: $e');
    }
  }
}
