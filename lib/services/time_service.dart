import 'package:ntp/ntp.dart';
import 'package:flutter/foundation.dart';

class TimeService {
  static Duration _offset = Duration.zero;

  /// Fetch true internet time and calculate offset compared to device time
  static Future<void> syncWithInternet() async {
    try {
      final int offsetInMs = await NTP.getNtpOffset(
        localTime: DateTime.now(),
        lookUpAddress: 'time.google.com',
      );
      _offset = Duration(milliseconds: offsetInMs);
      debugPrint('NTP Time sync successful. Offset: $_offset');
    } catch (e) {
      debugPrint('Failed to sync NTP time: $e');
      _offset = Duration.zero;
    }
  }

  /// Get the current correct time (internet time)
  static DateTime now() {
    return DateTime.now().add(_offset);
  }

  /// Convert a future internet time back to device time (useful for AlarmManager scheduling)
  static DateTime toDeviceTime(DateTime internetTime) {
    return internetTime.subtract(_offset);
  }
}
