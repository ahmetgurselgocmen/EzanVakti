import 'dart:convert';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'prayer_cache_service.dart';
import 'time_service.dart';

/// Prayer time names in Turkish
enum PrayerType {
  fajr('İmsak', '🌑'),
  sunrise('Güneş', '☀️'),
  dhuhr('Öğle', '🕛'),
  asr('İkindi', '🌤'),
  maghrib('Akşam', '🌅'),
  isha('Yatsı', '🌙');

  final String turkishName;
  final String icon;
  const PrayerType(this.turkishName, this.icon);
}

/// Represents a single prayer time
class PrayerTimeInfo {
  final PrayerType type;
  final DateTime time;
  final bool isNext;
  final bool isNotificationEnabled;

  const PrayerTimeInfo({
    required this.type,
    required this.time,
    this.isNext = false,
    this.isNotificationEnabled = true,
  });

  String get formattedTime => DateFormat('HH:mm').format(time);

  PrayerTimeInfo copyWith({
    PrayerType? type,
    DateTime? time,
    bool? isNext,
    bool? isNotificationEnabled,
  }) {
    return PrayerTimeInfo(
      type: type ?? this.type,
      time: time ?? this.time,
      isNext: isNext ?? this.isNext,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
    );
  }
}

/// Available calculation methods (Mapped to Countries)
enum CalculationMethodType {
  turkiye('Türkiye (Diyanet)'),
  ummAlQura('Suudi Arabistan / Körfez'),
  egyptian('Mısır / Afrika'),
  northAmerica('Amerika / Kanada (ISNA)'),
  muslimWorldLeague('Avrupa (MWL)'),
  karachi('Asya / Pakistan (Karaçi)'),
  dubai('BAE / Dubai'),
  qatar('Katar'),
  kuwait('Kuveyt'),
  singapore('Singapur / Malezya'),
  tehran('İran (Tahran)'),
  france('Fransa'),
  russia('Rusya'),
  moonsightingCommittee('Moonsighting Committee');

  final String displayName;
  const CalculationMethodType(this.displayName);

  /// Aladhan API method ID — https://aladhan.com/prayer-times-api#GetTimings
  int get aladhanMethodId {
    switch (this) {
      case CalculationMethodType.karachi:             return 1;
      case CalculationMethodType.northAmerica:        return 2;
      case CalculationMethodType.muslimWorldLeague:   return 3;
      case CalculationMethodType.ummAlQura:           return 4;
      case CalculationMethodType.egyptian:            return 5;
      case CalculationMethodType.tehran:              return 7;
      case CalculationMethodType.kuwait:              return 9;
      case CalculationMethodType.qatar:               return 10;
      case CalculationMethodType.singapore:           return 11;
      case CalculationMethodType.france:              return 12;
      case CalculationMethodType.turkiye:             return 13;
      case CalculationMethodType.russia:              return 14;
      case CalculationMethodType.moonsightingCommittee: return 15;
      case CalculationMethodType.dubai:              return 16;
    }
  }
}

class PrayerTimeService {
  /// Get calculation parameters for the selected method
  static CalculationParameters _getCalculationParams(
      CalculationMethodType method) {
    switch (method) {
      case CalculationMethodType.turkiye:
        return CalculationMethodParameters.turkiye();
      case CalculationMethodType.muslimWorldLeague:
        return CalculationMethodParameters.muslimWorldLeague();
      case CalculationMethodType.egyptian:
        return CalculationMethodParameters.egyptian();
      case CalculationMethodType.ummAlQura:
        return CalculationMethodParameters.ummAlQura();
      case CalculationMethodType.karachi:
        return CalculationMethodParameters.karachi();
      case CalculationMethodType.northAmerica:
        return CalculationMethodParameters.northAmerica();
      case CalculationMethodType.dubai:
        return CalculationMethodParameters.dubai();
      case CalculationMethodType.qatar:
        return CalculationMethodParameters.qatar();
      case CalculationMethodType.kuwait:
        return CalculationMethodParameters.kuwait();
      case CalculationMethodType.singapore:
        return CalculationMethodParameters.singapore();
      case CalculationMethodType.france:
        return CalculationMethodParameters.france();
      case CalculationMethodType.russia:
        return CalculationMethodParameters.russia();
      case CalculationMethodType.moonsightingCommittee:
        return CalculationMethodParameters.moonsightingCommittee();
      case CalculationMethodType.tehran:
        return CalculationMethodParameters.tehran();
    }
  }

  /// Calculate prayer times for given coordinates, date and method
  static List<PrayerTimeInfo> getPrayerTimes({
    required double latitude,
    required double longitude,
    required CalculationMethodType method,
    DateTime? date,
    bool useHanafi = false,
    Map<PrayerType, bool>? notificationSettings,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final targetDate = date ?? TimeService.now();
    final params = _getCalculationParams(method);

    if (useHanafi) {
      params.madhab = Madhab.hanafi;
    }

    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: targetDate,
      calculationParameters: params,
    );

    final now = TimeService.now();
    final times = <PrayerTimeInfo>[];

    // Build prayer time list
    final prayerMap = {
      PrayerType.fajr: prayerTimes.fajr,
      PrayerType.sunrise: prayerTimes.sunrise,
      PrayerType.dhuhr: prayerTimes.dhuhr,
      PrayerType.asr: prayerTimes.asr,
      PrayerType.maghrib: prayerTimes.maghrib,
      PrayerType.isha: prayerTimes.isha,
    };

    // Find the next prayer
    PrayerType? nextPrayer;
    for (final entry in prayerMap.entries) {
      if (entry.value.isAfter(now)) {
        nextPrayer = entry.key;
        break;
      }
    }

    for (final entry in prayerMap.entries) {
      final isNotifEnabled =
          notificationSettings?[entry.key] ?? true;
      times.add(PrayerTimeInfo(
        type: entry.key,
        time: entry.value,
        isNext: entry.key == nextPrayer,
        isNotificationEnabled: isNotifEnabled,
      ));
    }

    return times;
  }

  /// Get the next prayer and remaining time
  static ({PrayerTimeInfo? prayer, Duration remaining}) getNextPrayer({
    required double latitude,
    required double longitude,
    required CalculationMethodType method,
    bool useHanafi = false,
  }) {
    final times = getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      method: method,
      useHanafi: useHanafi,
    );

    final now = TimeService.now();

    for (final prayer in times) {
      if (prayer.time.isAfter(now)) {
        return (
          prayer: prayer,
          remaining: prayer.time.difference(now),
        );
      }
    }

    // If all prayers have passed, get tomorrow's fajr
    final tomorrowTimes = getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      method: method,
      date: TimeService.now().add(const Duration(days: 1)),
      useHanafi: useHanafi,
    );

    if (tomorrowTimes.isNotEmpty) {
      final fajr = tomorrowTimes.first;
      return (
        prayer: fajr,
        remaining: fajr.time.difference(now),
      );
    }

    return (prayer: null, remaining: Duration.zero);
  }

  /// Get calculation method from string name
  static CalculationMethodType getMethodFromString(String methodName) {
    switch (methodName) {
      case 'turkiye':
        return CalculationMethodType.turkiye;
      case 'egyptian':
        return CalculationMethodType.egyptian;
      case 'ummAlQura':
        return CalculationMethodType.ummAlQura;
      case 'karachi':
        return CalculationMethodType.karachi;
      case 'northAmerica':
        return CalculationMethodType.northAmerica;
      case 'dubai':
        return CalculationMethodType.dubai;
      case 'qatar':
        return CalculationMethodType.qatar;
      case 'kuwait':
        return CalculationMethodType.kuwait;
      case 'singapore':
        return CalculationMethodType.singapore;
      case 'france':
        return CalculationMethodType.france;
      case 'russia':
        return CalculationMethodType.russia;
      case 'moonsightingCommittee':
        return CalculationMethodType.moonsightingCommittee;
      default:
        return CalculationMethodType.muslimWorldLeague;
    }
  }

  /// Get prayer times from Aladhan API with cache + local fallback.
  /// Returns timings and whether they came from the internet.
  static Future<({List<PrayerTimeInfo> times, bool isOnline})> getApiPrayerTimes({
    required double latitude,
    required double longitude,
    required CalculationMethodType method,
    DateTime? date,
    Map<PrayerType, bool>? notificationSettings,
  }) async {
    final targetDate = date ?? TimeService.now();

    // 1. Try to load from same-day cache first
    final cached = await PrayerCacheService.load(targetDate, latitude, longitude);
    if (cached != null) {
      final times = _timingsToList(cached, targetDate, notificationSettings);
      if (times.isNotEmpty) {
        return (times: times, isOnline: true); // It is fresh for targetDate
      }
    }

    // 2. Try Aladhan API
    try {
      final dateStr = DateFormat('dd-MM-yyyy').format(targetDate);
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/timings/$dateStr'
        '?latitude=$latitude&longitude=$longitude'
        '&method=${method.aladhanMethodId}',
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'EzanVaktiApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final status = data['status'] as String?;
        if (status == 'OK') {
          final rawTimings = (data['data']['timings'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v.toString()));

          final tzStr = data['data']['meta']['timezone'] as String?;
          if (tzStr != null) {
            rawTimings['_timezone'] = tzStr;
          }

          // Cache the response
          await PrayerCacheService.save(targetDate, latitude, longitude, rawTimings);

          final times = _timingsToList(rawTimings, targetDate, notificationSettings);
          return (times: times, isOnline: true);
        }
      }
    } catch (e, stack) {
      // Network error — fall through to local calculation
      print('API Error: $e');
      print('API Stacktrace: $stack');
    }

    // 3. Offline fallback — local adhan_dart calculation
    final localTimes = getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      method: method,
      date: targetDate,
      notificationSettings: notificationSettings,
    );
    return (times: localTimes, isOnline: false);
  }

  /// Convert Aladhan API timings map to PrayerTimeInfo list
  static List<PrayerTimeInfo> _timingsToList(
    Map<String, String> timings,
    DateTime date,
    Map<PrayerType, bool>? notificationSettings,
  ) {
    // Ordered map from Aladhan key → PrayerType
    final keyMap = <String, PrayerType>{
      'Fajr':    PrayerType.fajr,
      'Sunrise': PrayerType.sunrise,
      'Dhuhr':   PrayerType.dhuhr,
      'Asr':     PrayerType.asr,
      'Maghrib': PrayerType.maghrib,
      'Isha':    PrayerType.isha,
    };

    final tzStr = timings['_timezone'];
    tz.Location? location;
    if (tzStr != null) {
      try {
        location = tz.getLocation(tzStr);
      } catch (_) {}
    }

    final now = TimeService.now();
    final result = <PrayerTimeInfo>[];
    PrayerType? nextType;

    for (final entry in keyMap.entries) {
      final raw = timings[entry.key];
      if (raw == null) continue;
      // raw can be "HH:mm" or "HH:mm (TZ)" — take only the time part
      final timeParts = raw.trim().split(' ').first.split(':');
      if (timeParts.length < 2) continue;
      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) continue;

      DateTime dt;
      if (location != null) {
        dt = tz.TZDateTime(location, date.year, date.month, date.day, hour, minute);
      } else {
        dt = DateTime(date.year, date.month, date.day, hour, minute);
      }

      if (dt.isAfter(now) && nextType == null) {
        nextType = entry.value;
      }

      result.add(PrayerTimeInfo(
        type: entry.value,
        time: dt,
        isNext: false, // Updated below
        isNotificationEnabled: notificationSettings?[entry.value] ?? true,
      ));
    }

    // Mark next prayer
    return result.map((p) => p.copyWith(isNext: p.type == nextType)).toList();
  }
}
