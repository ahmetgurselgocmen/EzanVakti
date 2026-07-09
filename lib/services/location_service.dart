import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? country;
  final String? district;
  final String? error;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.country,
    this.district,
    this.error,
  });

  String get displayName {
    if (cityName != null && country != null) {
      return '$cityName, $country';
    }
    if (cityName != null) return cityName!;
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }
}

class LocationService {
  /// Check and request location permissions
  static Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current location with city name
  static Future<LocationResult> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        return const LocationResult(
          latitude: 0,
          longitude: 0,
          error: 'Konum izni verilmedi',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      String? cityName;
      String? country;
      String? district;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          cityName = place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea;
          country = place.country;
          district = place.subLocality ?? place.subAdministrativeArea;
        }
      } catch (_) {
        // Geocoding failed, continue with coordinates only
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
        country: country,
        district: district,
      );
    } catch (e) {
      return LocationResult(
        latitude: 0,
        longitude: 0,
        error: 'Konum alınamadı: $e',
      );
    }
  }

  /// Get city name from coordinates
  static Future<String?> getCityName(
      double latitude, double longitude) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea;
      }
    } catch (_) {}
    return null;
  }
}
