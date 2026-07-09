import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/prayer_time_service.dart';
import '../../services/time_service.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../theme/app_colors.dart';
import '../../data/religious_days_data.dart';
import '../../screens/religious_days_screen.dart';
import '../../services/ad_service.dart';

class MinimalHomeLayout extends StatelessWidget {
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

  const MinimalHomeLayout({
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
  });

  Color get _textColor => AppColors.textColor;
  Color get _goldColor => AppColors.primaryColor;

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00:00';
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildMinimalCountdown(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: bannerAd,
          ),
          _buildMinimalPrayerList(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: CustomBannerAd(),
          ),
          _buildMinimalFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            districtName.isNotEmpty ? districtName : cityName,
            style: TextStyle(
              color: _textColor,
              fontSize: 32,
              fontWeight: FontWeight.w200,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$formattedDate\n$hijriDate',
            style: TextStyle(
              color: _textColor.withValues(alpha: 0.5),
              fontSize: 14,
              height: 1.5,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalCountdown() {
    String prayerName = nextPrayer != null ? l10n.prayerName(nextPrayer!.type.name) : '-';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appSettings.languageCode == 'tr'
                ? '$prayerName vaktine'
                : 'until $prayerName',
            style: TextStyle(
              color: _textColor.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final durationStr = _formatDuration(remainingTime);
              final lastColonIndex = durationStr.lastIndexOf(':');
              final hoursMinutes = durationStr.substring(0, lastColonIndex + 1);
              final seconds = durationStr.substring(lastColonIndex + 1);
              
              return RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: _goldColor,
                    fontSize: 56,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'monospace',
                    letterSpacing: -1,
                  ),
                  children: [
                    TextSpan(text: hoursMinutes),
                    TextSpan(
                      text: seconds,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            appSettings.languageCode == 'tr' ? 'kaldı.' : 'remaining.',
            style: TextStyle(
              color: _textColor.withValues(alpha: 0.7),
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalPrayerList() {
    if (isPrayerTimesLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Shimmer.fromColors(
          baseColor: _textColor.withValues(alpha: 0.1),
          highlightColor: _textColor.withValues(alpha: 0.2),
          child: Column(
            children: List.generate(6, (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: AnimationLimiter(
        child: Column(
          children: List.generate(prayerTimes.length, (index) {
            final prayer = prayerTimes[index];
            final isNext = prayer.isNext;
            final isPast = prayer.time.isBefore(TimeService.now()) && !isNext;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              prayer.type.icon,
                              style: TextStyle(
                                fontSize: 20,
                                color: isNext ? _goldColor : (isPast ? _textColor.withValues(alpha: 0.3) : _textColor),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              l10n.prayerName(prayer.type.name),
                              style: TextStyle(
                                color: isNext ? _goldColor : (isPast ? _textColor.withValues(alpha: 0.3) : _textColor),
                                fontSize: 18,
                                fontWeight: isNext ? FontWeight.w600 : FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          prayer.formattedTime,
                          style: TextStyle(
                            color: isNext ? _goldColor : (isPast ? _textColor.withValues(alpha: 0.3) : _textColor),
                            fontSize: 18,
                            fontWeight: isNext ? FontWeight.w600 : FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMinimalFooter(BuildContext context) {
    final upcomingDays = ReligiousDaysData.upcomingDays;
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: _textColor.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          if (upcomingDays.isNotEmpty)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReligiousDaysScreen()));
              },
              child: Text(
                'Yaklaşan: ${upcomingDays.first.name}',
                style: TextStyle(
                  color: _textColor.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            '"${l10n.t('verseContent')}"',
            style: TextStyle(
              color: _textColor.withValues(alpha: 0.6),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
