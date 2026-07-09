import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../services/prayer_time_service.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ad_service.dart';

class ClassicHomeLayout extends StatelessWidget {
  final List<PrayerTimeInfo> prayerTimes;
  final PrayerTimeInfo? nextPrayer;
  final Duration remainingTime;
  final bool isPrayerTimesLoading;
  final String cityName;
  final String districtName;
  final String countryName;
  final double? temperature;
  final String hijriDate;
  final String formattedDate;
  final AppLocalizations l10n;
  final Widget bannerAd; 
  final String dailyAyahText;
  final String dailyAyahSource;

  const ClassicHomeLayout({
    super.key,
    required this.prayerTimes,
    required this.nextPrayer,
    required this.remainingTime,
    required this.isPrayerTimesLoading,
    required this.cityName,
    required this.districtName,
    required this.countryName,
    required this.temperature,
    required this.hijriDate,
    required this.formattedDate,
    required this.l10n,
    required this.bannerAd,
    this.dailyAyahText = '',
    this.dailyAyahSource = '',
  });

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1E3D2F),
        image: DecorationImage(
          image: AssetImage('assets/images/home_bg_pattern.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                _buildCountdown(),
                _buildPrayerGrid(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: CustomBannerAd(),
                ),
                _buildDailyVerseCard(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: bannerAd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side: Location
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: const Color(0xFFC9A86A), size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    districtName.isNotEmpty
                        ? '$districtName, $cityName'
                        : '$cityName, ${l10n.t(countryName)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Right side: Date and Temperature
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hijriDate,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              if (temperature != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.thermostat, color: const Color(0xFFC9A86A), size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '${temperature!.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    if (isPrayerTimesLoading || nextPrayer == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.3),
          child: Column(
            children: [
              Container(width: 150, height: 20, color: Colors.white),
              const SizedBox(height: 12),
              Container(width: 250, height: 60, color: Colors.white),
            ],
          ),
        ),
      );
    }

    final prayerName = l10n.prayerName(nextPrayer!.type.name);
    
    String getTurkishDative(String name) {
      switch (name.toLowerCase()) {
        case 'imsak': return "İmsak'a";
        case 'güneş': return "Güneş'e";
        case 'öğle': return "Öğle'ye";
        case 'ikindi': return "İkindi'ye";
        case 'akşam': return "Akşam'a";
        case 'yatsı': return "Yatsı'ya";
        default: return "$name'e";
      }
    }

    final targetText = appSettings.languageCode == 'tr'
        ? "${getTurkishDative(prayerName)} Kalan Süre"
        : 'Time until $prayerName';

    final durationStr = _formatDuration(remainingTime);
    final lastColonIndex = durationStr.lastIndexOf(':');
    final hoursMinutes = durationStr.substring(0, lastColonIndex + 1);
    final seconds = durationStr.substring(lastColonIndex + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            targetText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: const Color(0xFFE4C580),
                fontSize: 56,
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
                shadows: [
                  Shadow(
                    color: const Color(0xFFE4C580).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: Offset.zero,
                  ),
                ],
              ),
              children: [
                TextSpan(text: hoursMinutes),
                TextSpan(
                  text: seconds,
                  style: const TextStyle(fontSize: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerGrid() {
    if (isPrayerTimesLoading || prayerTimes.isEmpty) {
      return const SizedBox(height: 300);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: prayerTimes.length,
        itemBuilder: (context, index) {
          final prayer = prayerTimes[index];
          final isNext = nextPrayer?.type == prayer.type;
          
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 3,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildGridItem(prayer, isNext),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForPrayer(PrayerType type) {
    switch (type) {
      case PrayerType.fajr: return Icons.nightlight_round;
      case PrayerType.sunrise: return Icons.wb_sunny_outlined;
      case PrayerType.dhuhr: return Icons.wb_sunny;
      case PrayerType.asr: return Icons.wb_twilight;
      case PrayerType.maghrib: return Icons.nightlight_outlined;
      case PrayerType.isha: return Icons.star_border;
    }
  }

  Widget _buildGridItem(PrayerTimeInfo prayer, bool isActive) {
    final formattedTime = DateFormat('HH:mm').format(prayer.time);
    final prayerName = l10n.prayerName(prayer.type.name);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isActive
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF3D995), Color(0xFFC7A24A)],
              )
            : null,
        color: isActive ? null : const Color(0xFF264936),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForPrayer(prayer.type),
            color: isActive ? const Color(0xFF5A4415) : const Color(0xFFC9A86A),
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            prayerName,
            style: TextStyle(
              color: isActive ? const Color(0xFF5A4415) : Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formattedTime,
            style: TextStyle(
              color: isActive ? const Color(0xFF3E2D0C) : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyVerseCard() {
    final text = dailyAyahText.isNotEmpty ? dailyAyahText : l10n.t('verseContent');
    final source = dailyAyahSource.isNotEmpty ? dailyAyahSource : l10n.t('verseSource');
    final darkGreen = const Color(0xFF1E3B2E);
    final cardBg = const Color(0xFFF6F2EC);

    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, top: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE5DFD1).withValues(alpha: 0.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dark_mode, color: const Color(0xFFC9A86A), size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Günün Ayeti / Hadisi',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                    style: TextStyle(
                      color: darkGreen,
                      fontSize: 22,
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
                    style: TextStyle(
                      color: darkGreen.withValues(alpha: 0.9),
                      fontSize: 18,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    textDirection: ui.TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '"$text"',
                    style: TextStyle(
                      color: darkGreen.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Kaynak: $source',
                          style: TextStyle(
                            color: darkGreen.withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.favorite_border, color: Color(0xFFB04A4A), size: 18),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: darkGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Share',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
