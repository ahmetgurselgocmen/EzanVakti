import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/ad_service.dart';
import '../main.dart';
import '../widgets/dynamic_background.dart';
import 'zikirmatik_screen.dart';
import 'esma_screen.dart';
import 'quran_screen.dart';
import 'qibla_screen.dart';
import 'hadith_screen.dart';
import 'religious_days_screen.dart';
import 'live_stream_screen.dart';
import 'nearby_mosques_screen.dart';
import 'quran_radio_screen.dart';
import 'ask_hodja_screen.dart';
import 'pro_membership_screen.dart';
import 'support_screen.dart';

class OthersScreen extends StatefulWidget {
  const OthersScreen({super.key});

  @override
  State<OthersScreen> createState() => _OthersScreenState();
}

class _OthersScreenState extends State<OthersScreen> {
  @override
  void initState() {
    super.initState();
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
    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    appSettings.l10n.t('navOthers'),
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: [
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.l10n.t('liveStream'),
                        icon: Icons.live_tv,
                        color: const Color(0xFFE53935),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LiveStreamScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.l10n.t('navZikirmatik'),
                        icon: Icons.touch_app,
                        color: const Color(0xFF4ECDC4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ZikirmatikScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.l10n.t('navEsma'),
                        icon: Icons.menu_book,
                        color: const Color(0xFFF4C430),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EsmaScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.l10n.t('navQuran'),
                        icon: Icons.menu_book_sharp,
                        color: const Color(0xFF4A90E2),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QuranScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.l10n.t('navQibla'),
                        icon: Icons.explore,
                        color: const Color(0xFFE27C3E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QiblaScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.l10n.t('navHadith'),
                        icon: Icons.format_quote,
                        color: const Color(0xFF8B4256),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HadithScreen()),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.languageCode == 'tr'
                            ? 'Dini Günler'
                            : 'Religious Days',
                        icon: Icons.calendar_month,
                        color: const Color(0xFF6B4D57),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReligiousDaysScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.languageCode == 'tr'
                            ? 'Yakındaki Camiler'
                            : 'Nearby Mosques',
                        icon: Icons.mosque_outlined,
                        color: const Color(0xFF50A7C2),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NearbyMosquesScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.languageCode == 'tr'
                            ? "Kur'an Radyo"
                            : "Quran Radio",
                        icon: Icons.radio,
                        color: const Color(0xFF9C27B0), // Purple theme for radio
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const QuranRadioScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.languageCode == 'tr'
                            ? 'Hocaya Soru Sor'
                            : 'Ask a Question',
                        icon: Icons.question_answer_rounded,
                        color: const Color(0xFF2E7D32), // Green theme
                        onTap: () {
                          if (appSettings.isPro) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AskHodjaScreen(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProMembershipScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.languageCode == 'tr'
                            ? 'PRO Üyelik'
                            : 'PRO Membership',
                        icon: Icons.workspace_premium,
                        color: const Color(0xFFFFC107), // Golden theme for PRO
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProMembershipScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        context: context,
                        title: appSettings.languageCode == 'tr'
                            ? 'Destek'
                            : 'Support',
                        icon: Icons.support_agent_rounded,
                        color: const Color(0xFF1976D2), // Blue theme for support
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SupportScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const CustomBannerAd(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.5), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.8),
                      color.withValues(alpha: 0.5),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textColor.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
