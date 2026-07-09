import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/religious_days_data.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../services/ad_service.dart';
import '../widgets/dynamic_background.dart';
import '../services/time_service.dart';

class ReligiousDaysScreen extends StatefulWidget {
  const ReligiousDaysScreen({super.key});

  @override
  State<ReligiousDaysScreen> createState() => _ReligiousDaysScreenState();
}

class _ReligiousDaysScreenState extends State<ReligiousDaysScreen> {
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = TimeService.now().year;
    appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textColor;
    final cardColor = AppColors.cardColor;
    final borderColor = AppColors.borderColor;
    final daysForYear = ReligiousDaysData.getDaysForGregorianYear(selectedYear);

    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      appSettings.l10n.languageCode == 'tr' ? 'Dini Günler' : 'Religious Days',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: (2030 - (TimeService.now().year - 2) + 1).clamp(1, 100),
                itemBuilder: (context, index) {
                  int year = TimeService.now().year - 2 + index;
                  bool isSelected = year == selectedYear;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedYear = year;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          year.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                physics: const BouncingScrollPhysics(),
                itemCount: daysForYear.length,
                itemBuilder: (context, index) {
                  final day = daysForYear[index];
                  final isVeryClose = day.daysRemaining >= 0 && day.daysRemaining <= 7;
                  final isPassed = day.daysRemaining < 0;

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isVeryClose ? AppColors.primaryColor.withValues(alpha: 0.15) : cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isVeryClose ? AppColors.primaryColor.withValues(alpha: 0.5) : borderColor,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  day.name,
                                  style: TextStyle(
                                    color: isVeryClose ? AppColors.primaryColor : textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  DateFormat('d MMMM yyyy, EEEE', appSettings.languageCode).format(day.date),
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isPassed
                                    ? '${day.daysRemaining.abs()}'
                                    : day.daysRemaining == 0
                                        ? (appSettings.languageCode == 'tr' ? 'Bugün' : 'Today')
                                        : '${day.daysRemaining}',
                                style: TextStyle(
                                  color: isVeryClose ? AppColors.primaryColor : (isPassed ? textColor.withValues(alpha: 0.5) : textColor),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (day.daysRemaining != 0)
                                Text(
                                  isPassed
                                      ? (appSettings.languageCode == 'tr' ? 'Gün Geçti' : 'Days Passed')
                                      : (appSettings.languageCode == 'tr' ? 'Gün Kaldı' : 'Days Left'),
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBannerAd(),
      ),
    );
  }
}
