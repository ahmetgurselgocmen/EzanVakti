import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import '../../services/prayer_time_service.dart';
import '../../services/time_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../data/religious_days_data.dart';
import '../../screens/religious_days_screen.dart';
import '../../services/ad_service.dart';

class ModernHomeLayout extends StatelessWidget {
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

  const ModernHomeLayout({
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
  Color get _cardBgColor => AppColors.cardColor;

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
        children: [
          _buildHeader(),
          _buildCircularCountdown(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: bannerAd,
          ),
          _buildHorizontalPrayerList(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: CustomBannerAd(),
          ),
          _buildInfoCards(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                districtName.isNotEmpty ? districtName : cityName,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$formattedDate • $hijriDate',
                style: TextStyle(
                  color: _textColor.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (temperature != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cardBgColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${temperature!.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: _goldColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircularCountdown() {
    double targetProgress = 1.0;
    if (nextPrayer != null) {
      final totalSeconds = 6 * 3600; 
      final remSeconds = remainingTime.inSeconds;
      targetProgress = (remSeconds / totalSeconds).clamp(0.0, 1.0);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 230,
            height: 230,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: targetProgress),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: _textColor.withValues(alpha: 0.1),
                  color: _goldColor,
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nextPrayer != null ? l10n.prayerName(nextPrayer!.type.name) : '-',
                style: TextStyle(
                  color: _goldColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final durationStr = _formatDuration(remainingTime);
                  final lastColonIndex = durationStr.lastIndexOf(':');
                  final hoursMinutes = durationStr.substring(0, lastColonIndex + 1);
                  final seconds = durationStr.substring(lastColonIndex + 1);
                  
                  return RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 48,
                        fontWeight: FontWeight.w200,
                        fontFamily: 'monospace',
                      ),
                      children: [
                        TextSpan(text: hoursMinutes),
                        TextSpan(
                          text: seconds,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('nextPrayer'),
                style: TextStyle(
                  color: _textColor.withValues(alpha: 0.5),
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalPrayerList() {
    if (isPrayerTimesLoading) {
      return SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: _cardBgColor,
              highlightColor: _cardBgColor.withValues(alpha: 0.3),
              child: Container(
                width: 90,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            );
          },
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: prayerTimes.length,
          itemBuilder: (context, index) {
            final prayer = prayerTimes[index];
            final isNext = prayer.isNext;
            final isPast = prayer.time.isBefore(TimeService.now()) && !isNext;

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 500),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isNext ? _goldColor : _cardBgColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isNext ? [
                        BoxShadow(
                          color: _goldColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          prayer.type.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.prayerName(prayer.type.name),
                          style: TextStyle(
                            color: isNext ? Colors.white : (isPast ? _textColor.withValues(alpha: 0.4) : _textColor),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prayer.formattedTime,
                          style: TextStyle(
                            color: isNext ? Colors.white : (isPast ? _textColor.withValues(alpha: 0.4) : _textColor),
                            fontSize: 16,
                            fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final upcomingDays = ReligiousDaysData.upcomingDays;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          if (upcomingDays.isNotEmpty)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReligiousDaysScreen()));
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardBgColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.calendar_month, color: _goldColor),
                      const SizedBox(height: 12),
                      Text(
                        upcomingDays.first.name,
                        style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        upcomingDays.first.daysRemaining == 0 
                            ? l10n.t('today') 
                            : '${upcomingDays.first.daysRemaining} ${l10n.t('daysLeft')}',
                        style: TextStyle(color: _goldColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBgColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.menu_book, color: _goldColor),
                  const SizedBox(height: 12),
                  Text(
                    '"${l10n.t('verseContent')}"',
                    style: TextStyle(
                      color: _textColor.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
