import 'package:hijri/hijri_calendar.dart';
import '../services/time_service.dart';

class ReligiousDay {
  final String name;
  final DateTime date;

  const ReligiousDay({
    required this.name,
    required this.date,
  });

  int get daysRemaining {
    final now = TimeService.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    return eventDay.difference(today).inDays;
  }
}

class ReligiousDaysData {
  static List<ReligiousDay> get upcomingDays {
    final List<ReligiousDay> allDays = [];
    final currentHijriYear = HijriCalendar.fromDate(TimeService.now()).hYear;
    
    // Generate for current and next Hijri year to cover upcoming days
    for (int year = currentHijriYear; year <= currentHijriYear + 1; year++) {
      allDays.addAll(_generateForYear(year));
    }
    
    // Filter past days and sort
    return allDays.where((day) => day.daysRemaining >= 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<ReligiousDay> getDaysForGregorianYear(int year) {
    final List<ReligiousDay> allDays = [];
    final startHijriYear = HijriCalendar.fromDate(DateTime(year, 1, 1)).hYear;
    
    // Generate for previous, current, and next Hijri year to cover all overlapping dates
    for (int hYear = startHijriYear - 1; hYear <= startHijriYear + 2; hYear++) {
      allDays.addAll(_generateForYear(hYear));
    }
    
    // Filter by the requested Gregorian year and sort
    return allDays.where((day) => day.date.year == year).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static List<ReligiousDay> _generateForYear(int year) {
    final hijri = HijriCalendar();
    
    DateTime getGregorian(int month, int day) {
      return hijri.hijriToGregorian(year, month, day);
    }
    
    // Regaib Kandili is the first Thursday of Rajab
    DateTime getRegaib() {
      DateTime rajab1 = getGregorian(7, 1);
      int diff = (DateTime.thursday - rajab1.weekday + 7) % 7;
      return rajab1.add(Duration(days: diff));
    }

    return [
      ReligiousDay(name: "Hicri Yılbaşı", date: getGregorian(1, 1)),
      ReligiousDay(name: "Aşure Günü", date: getGregorian(1, 10)),
      ReligiousDay(name: "Mevlid Kandili", date: getGregorian(3, 12)),
      ReligiousDay(name: "Regaib Kandili", date: getRegaib()),
      ReligiousDay(name: "Miraç Kandili", date: getGregorian(7, 27)),
      ReligiousDay(name: "Berat Kandili", date: getGregorian(8, 15)),
      ReligiousDay(name: "Ramazan Başlangıcı", date: getGregorian(9, 1)),
      ReligiousDay(name: "Kadir Gecesi", date: getGregorian(9, 27)),
      ReligiousDay(name: "Ramazan Bayramı (1. Gün)", date: getGregorian(10, 1)),
      ReligiousDay(name: "Kurban Bayramı (1. Gün)", date: getGregorian(12, 10)),
    ];
  }
}
