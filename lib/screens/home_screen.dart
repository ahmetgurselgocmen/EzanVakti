import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:hijri/hijri_calendar.dart';
import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';
import '../services/adhan_audio_service.dart';
import '../services/weather_service.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/time_service.dart';
import '../theme/app_colors.dart';
import '../widgets/layouts/classic_home_layout.dart';
import '../widgets/layouts/modern_home_layout.dart';
import '../widgets/layouts/minimal_home_layout.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const HomeScreen({super.key, this.initialData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<PrayerTimeInfo> _prayerTimes = [];
  PrayerTimeInfo? _nextPrayer;
  Duration _remainingTime = Duration.zero;
  Timer? _timer;

  // Prayer times loading state
  bool _isPrayerTimesLoading = true;

  String _cityName = 'İstanbul';
  String _countryName = 'Türkiye';
  String _districtName = '';
  double _latitude = 41.0082;
  double _longitude = 28.9784;
  double? _temperature;
  CalculationMethodType _method = CalculationMethodType.turkiye;
  final Map<PrayerType, bool> _notificationSettings = {
    PrayerType.fajr: true,
    PrayerType.sunrise: false,
    PrayerType.dhuhr: true,
    PrayerType.asr: true,
    PrayerType.maghrib: true,
    PrayerType.isha: true,
  };

  String _dailyAyahText = '';
  String _dailyAyahSource = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.initialData != null) {
      _applyInitialData(widget.initialData!);
    }
    _loadSettings();
    appSettings.addListener(_onSettingsChanged);
    AdhanAudioService.isPlayingNotifier.addListener(_onAdhanStatusChanged);
    _requestMandatoryPermissions();
  }

  Future<void> _requestMandatoryPermissions() async {
    // We delay slightly to not interrupt the initial render
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Notification Permission
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Exact Alarm Permission (for Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    // Battery Optimization (critical for background updates)
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    appSettings.removeListener(_onSettingsChanged);
    AdhanAudioService.isPlayingNotifier.removeListener(_onAdhanStatusChanged);
    super.dispose();
  }

  void _onAdhanStatusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onSettingsChanged() {
    if (mounted) {
      _loadSettings();
      setState(() {});
      _updateHomeWidget(_nextPrayer);
    }
  }

  AppLocalizations get l10n => appSettings.l10n;

  void _applyInitialData(Map<String, dynamic> data) {
    _cityName = data['cityName'] ?? _cityName;
    _countryName = data['countryName'] ?? _countryName;
    _districtName = data['district'] ?? '';
    _latitude = data['latitude'] ?? _latitude;
    _longitude = data['longitude'] ?? _longitude;
    // Save immediately so next launch skips welcome
    _saveSettings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchPrayerTimes();
      if (_nextPrayer != null) {
        NotificationService.updateCountdownNotification(
          targetTime: _nextPrayer!.time,
          prayerName: l10n.prayerName(_nextPrayer!.type.name),
          allPrayerTimes: _prayerTimes,
        );
      }
    } else if (state == AppLifecycleState.paused) {
      // Update persistent notification when app goes to background
      if (_nextPrayer != null) {
        NotificationService.updateCountdownNotification(
          targetTime: _nextPrayer!.time,
          prayerName: l10n.prayerName(_nextPrayer!.type.name),
          allPrayerTimes: _prayerTimes,
        );
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cityName = prefs.getString('cityName') ?? 'İstanbul';
      _countryName = prefs.getString('countryName') ?? 'Türkiye';
      _districtName = prefs.getString('districtName') ?? '';
      _latitude = prefs.getDouble('latitude') ?? 41.0082;
      _longitude = prefs.getDouble('longitude') ?? 28.9784;
      final methodStr = prefs.getString('method') ?? 'turkiye';
      _method = PrayerTimeService.getMethodFromString(methodStr);

      // Load notification settings
      for (final type in PrayerType.values) {
        _notificationSettings[type] =
            prefs.getBool('notif_${type.name}') ?? (type != PrayerType.sunrise);
      }
    });
    _fetchPrayerTimes();
    _fetchWeather();
    _fetchDailyAyah();
  }

  Future<void> _fetchDailyAyah() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = TimeService.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);
      final lastDate = prefs.getString('ayah_date');

      if (lastDate == todayStr) {
        if (mounted) {
          setState(() {
            _dailyAyahText = prefs.getString('ayah_text') ?? '';
            _dailyAyahSource = prefs.getString('ayah_source') ?? '';
          });
        }
        return;
      }

      int dayOfYear = int.parse(DateFormat('D').format(now));
      int ayahNumber = (dayOfYear % 6236) + 1;

      final url = Uri.parse('https://api.alquran.cloud/v1/ayah/$ayahNumber/tr.diyanet');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final text = data['text'];
        final surahName = data['surah']['englishName']; 
        final numberInSurah = data['numberInSurah'];
        final source = '$surahName Suresi, $numberInSurah. Ayet';

        await prefs.setString('ayah_date', todayStr);
        await prefs.setString('ayah_text', text);
        await prefs.setString('ayah_source', source);

        if (mounted) {
          setState(() {
            _dailyAyahText = text;
            _dailyAyahSource = source;
          });
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _fetchWeather() async {
    final temp = await WeatherService.getCurrentTemperature(
      _latitude,
      _longitude,
    );
    if (mounted) {
      setState(() {
        _temperature = temp;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cityName', _cityName);
    await prefs.setString('countryName', _countryName);
    await prefs.setString('districtName', _districtName);
    await prefs.setDouble('latitude', _latitude);
    await prefs.setDouble('longitude', _longitude);
    await prefs.setString('method', _method.name);

    for (final entry in _notificationSettings.entries) {
      await prefs.setBool('notif_${entry.key.name}', entry.value);
    }
  }

  Future<void> _fetchPrayerTimes({bool isTomorrow = false}) async {
    if (!mounted) return;
    setState(() => _isPrayerTimesLoading = true);

    final targetDate = isTomorrow ? TimeService.now().add(const Duration(days: 1)) : TimeService.now();

    final result = await PrayerTimeService.getApiPrayerTimes(
      latitude: _latitude,
      longitude: _longitude,
      method: _method,
      date: targetDate,
      notificationSettings: _notificationSettings,
    );

    if (!mounted) return;

    // Compute next prayer from the result
    final now = TimeService.now();
    PrayerTimeInfo? next;
    Duration remaining = Duration.zero;
    bool allPassed = true;

    for (final p in result.times) {
      if (p.time.isAfter(now)) {
        next = p;
        remaining = p.time.difference(now);
        allPassed = false;
        break;
      }
    }

    // If all past, fetch tomorrow's full list instead of just fallback next prayer
    if (allPassed && !isTomorrow) {
      _fetchPrayerTimes(isTomorrow: true);
      return;
    }

    // Safety fallback
    if (next == null) {
      final tomorrow = PrayerTimeService.getNextPrayer(
        latitude: _latitude,
        longitude: _longitude,
        method: _method,
        useHanafi: false,
      );
      next = tomorrow.prayer;
      remaining = tomorrow.remaining;
    }

    setState(() {
      _prayerTimes = result.times;
      _isPrayerTimesLoading = false;
      _nextPrayer = next;
      _remainingTime = remaining;
    });

    if (next != null) {
      NotificationService.updateCountdownNotification(
        targetTime: next.time,
        prayerName: l10n.prayerName(next.type.name),
        allPrayerTimes: _prayerTimes,
      );
    }

    // Schedule notifications with fresh times
    NotificationService.schedulePrayerNotifications(
      prayerTimes: result.times,
      notificationSettings: _notificationSettings,
    );

    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final now = TimeService.now();
      
      PrayerTimeInfo? next;
      Duration remaining = Duration.zero;
      for (final p in _prayerTimes) {
        if (p.time.isAfter(now)) {
          next = p;
          remaining = p.time.difference(now);
          break;
        }
      }

      if (next == null && _prayerTimes.isNotEmpty) {
        // All loaded prayers have passed (Yatsı passed). Fetch tomorrow's times!
        _fetchPrayerTimes();
        return;
      }

      if (next == null) return;

      final currentNext = next;
      final hasChanged = _nextPrayer != null && _nextPrayer != currentNext;

      setState(() {
        _nextPrayer = currentNext;
        _remainingTime = remaining;
      });

      // At midnight re-fetch for the new day (just in case)
      if (now.hour == 0 && now.minute == 0 && now.second == 0) {
        _fetchPrayerTimes();
        return;
      }

      if (hasChanged) {
        // Prayer has changed, update notification
        NotificationService.updateCountdownNotification(
          targetTime: currentNext.time,
          prayerName: l10n.prayerName(currentNext.type.name),
          allPrayerTimes: _prayerTimes,
        );
      }

      // Check if any prayer time just passed (within 15-second window for cold boot)
      for (final p in _prayerTimes) {
        final diff = now.difference(p.time).inSeconds;
        if (diff >= 0 && diff < 15) {
          if (_notificationSettings[p.type] == true &&
              !AdhanAudioService.isPlaying) {
            AdhanAudioService.playAdhan(l10n.prayerName(p.type.name));
          }
        }
      }
      
      // Update Home Widget and Persistent Notification every minute
      if (remaining.inSeconds % 60 == 0) {
        _updateHomeWidget(currentNext);
        NotificationService.updateCountdownNotification(
          targetTime: currentNext.time,
          prayerName: l10n.prayerName(currentNext.type.name),
          allPrayerTimes: _prayerTimes,
        );
      }
    });
  }

  Future<void> _updateHomeWidget(PrayerTimeInfo? next) async {
    if (next == null) return;
    try {
      await HomeWidget.saveWidgetData<String>(
        'next_prayer',
        'Sıradaki Vakit: ${l10n.prayerName(next.type.name)}',
      );
      // VERY IMPORTANT: Convert to device time for Android Widget Chronometer
      await HomeWidget.saveWidgetData<int>(
        'target_time_millis',
        TimeService.toDeviceTime(next.time).millisecondsSinceEpoch,
      );
      await HomeWidget.saveWidgetData<int>(
        'widget_theme_index',
        appSettings.themeIndex,
      );
      await HomeWidget.updateWidget(
        name: 'PrayerWidgetProvider',
        iOSName: 'PrayerWidgetProvider',
      );
    } catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bannerAdWidget = const CustomBannerAd();

    Widget selectedLayout;
    switch (appSettings.themeIndex) {
      case 1:
        selectedLayout = ModernHomeLayout(
          prayerTimes: _prayerTimes,
          nextPrayer: _nextPrayer,
          remainingTime: _remainingTime,
          isPrayerTimesLoading: _isPrayerTimesLoading,
          cityName: _cityName,
          districtName: _districtName,
          countryName: _countryName,
          temperature: _temperature,
          hijriDate: _getHijriDate(),
          formattedDate: _getFormattedDate(),
          l10n: l10n,
          bannerAd: bannerAdWidget,
        );
        break;
      case 2:
        selectedLayout = MinimalHomeLayout(
          prayerTimes: _prayerTimes,
          nextPrayer: _nextPrayer,
          remainingTime: _remainingTime,
          isPrayerTimesLoading: _isPrayerTimesLoading,
          cityName: _cityName,
          districtName: _districtName,
          countryName: _countryName,
          temperature: _temperature,
          hijriDate: _getHijriDate(),
          formattedDate: _getFormattedDate(),
          l10n: l10n,
          bannerAd: bannerAdWidget,
        );
        break;
      case 0:
      default:
        selectedLayout = ClassicHomeLayout(
          prayerTimes: _prayerTimes,
          nextPrayer: _nextPrayer,
          remainingTime: _remainingTime,
          isPrayerTimesLoading: _isPrayerTimesLoading,
          cityName: _cityName,
          districtName: _districtName,
          countryName: _countryName,
          temperature: _temperature,
          hijriDate: _getHijriDate(),
          formattedDate: _getFormattedDate(),
          l10n: l10n,
          bannerAd: bannerAdWidget,
          dailyAyahText: _dailyAyahText,
          dailyAyahSource: _dailyAyahSource,
        );
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: selectedLayout,
          ),
          if (AdhanAudioService.isPlaying)
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.65),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mosque,
                            size: 100,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Ezan Okunuyor...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${AdhanAudioService.currentPrayerName} Vakti',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                            ),
                            icon: const Icon(Icons.volume_off),
                            label: const Text(
                              'Ezanı Durdur',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () async {
                              await AdhanAudioService.stopAdhan();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final displayDate = _prayerTimes.isNotEmpty ? _prayerTimes.first.time : TimeService.now();
    final dateFormat = DateFormat(
      'd MMMM yyyy, EEEE',
      appSettings.languageCode == 'tr' ? 'tr_TR' : 'en_US',
    );
    try {
      return dateFormat.format(displayDate);
    } catch (_) {
      return DateFormat('d MMMM yyyy, EEEE').format(displayDate);
    }
  }

  String _getHijriDate() {
    final displayDate = _prayerTimes.isNotEmpty ? _prayerTimes.first.time : TimeService.now();
    final hijri = HijriCalendar.fromDate(displayDate);
    final monthName = l10n.t(_getHijriMonthName(hijri.hMonth));
    return '${hijri.hDay} $monthName ${hijri.hYear}';
  }

  String _getHijriMonthName(int month) {
    switch (month) {
      case 1: return 'muharram';
      case 2: return 'safar';
      case 3: return 'rabiAlAwwal';
      case 4: return 'rabiAlThani';
      case 5: return 'jumadaAlAwwal';
      case 6: return 'jumadaAlThani';
      case 7: return 'rajab';
      case 8: return 'shaban';
      case 9: return 'ramadan';
      case 10: return 'shawwal';
      case 11: return 'dhuAlQidah';
      case 12: return 'dhuAlHijjah';
      default: return '';
    }
  }
}
