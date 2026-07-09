import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'time_service.dart';

/// Handles caching of API-fetched prayer times
class PrayerCacheService {
  static const _prefix = 'prayer_api_cache_';

  /// Cache key based on date + rounded coordinates (1 decimal = ~11km grid)
  static String _cacheKey(DateTime date, double lat, double lon) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final latR = lat.toStringAsFixed(1);
    final lonR = lon.toStringAsFixed(1);
    return '$_prefix${dateStr}_${latR}_$lonR';
  }

  /// Save prayer times map {prayerKey: "HH:mm"} for given date/location
  static Future<void> save(
    DateTime date,
    double lat,
    double lon,
    Map<String, String> timings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(date, lat, lon);
    await prefs.setString(key, json.encode(timings));
    // Clean old entries (keep only last 3 days)
    await _cleanup(prefs, date);
  }

  /// Load cached prayer times map for given date/location. Returns null if not found.
  static Future<Map<String, String>?> load(
    DateTime date,
    double lat,
    double lon,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _cacheKey(date, lat, lon);
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return null;
    }
  }

  /// Remove cache entries older than 3 days
  static Future<void> _cleanup(SharedPreferences prefs, DateTime today) async {
    final cutoff = today.subtract(const Duration(days: 3));
    final keysToRemove = prefs
        .getKeys()
        .where((k) => k.startsWith(_prefix))
        .where((k) {
          try {
            // Key format: prayer_api_cache_YYYY-MM-DD_lat_lon
            final dateStr = k.replaceFirst(_prefix, '').split('_').first;
            final parts = dateStr.split('-');
            if (parts.length != 3) return true;
            final date = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
            return date.isBefore(cutoff);
          } catch (_) {
            return true;
          }
        })
        .toList();
    for (final k in keysToRemove) {
      await prefs.remove(k);
    }
  }

  /// Check if there is cached data for today's date at the given location
  static Future<bool> hasTodayCache(double lat, double lon) async {
    final today = TimeService.now();
    final cached = await load(today, lat, lon);
    return cached != null;
  }
}
