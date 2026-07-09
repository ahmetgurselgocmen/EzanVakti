import 'package:flutter/material.dart';
import '../widgets/dynamic_background.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import 'youtube_player_screen.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
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

  void _openStream(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubePlayerScreen(videoUrl: url, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textColor;
    final isTr = appSettings.languageCode == 'tr';

    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  SizedBox(width: 4),
                  Text(
                    appSettings.l10n.t('liveStream'),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Info text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                isTr
                    ? 'Harem-i Şerif canlı yayınlarını izleyin'
                    : 'Watch live broadcasts from the Holy Mosques',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 24),
            // Mecca card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildStreamCard(
                title: isTr
                    ? 'Mekke - Harem-i Şerif'
                    : 'Makkah - Masjid al-Haram',
                subtitle: isTr ? 'Kabe Canlı Yayın' : 'Kaaba Live Stream',
                emoji: '🕋',
                gradientColors: [AppColors.cardColor, Color(0xFFE4D5B7)],
                accentColor: AppColors.primaryColor,
                // Official Al Haramain channel - Makkah live
                onTap: () => _openStream(
                    'https://m.youtube.com/@SaudiQuranTv/live',
                    isTr ? 'Mekke - Harem-i Şerif' : 'Makkah - Masjid al-Haram',
                  ),
                liveIndicatorColor: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            // Medina card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _buildStreamCard(
                title: isTr
                    ? 'Medine - Mescid-i Nebevi'
                    : 'Madinah - Masjid an-Nabawi',
                subtitle: isTr
                    ? 'Peygamber Mescidi Canlı Yayın'
                    : 'Prophet\'s Mosque Live Stream',
                emoji: '🕌',
                gradientColors: [AppColors.cardColor, Color(0xFFE4D5B7)],
                accentColor: AppColors.primaryColor,
                // Official Al Haramain channel - Madinah live
                onTap: () => _openStream(
                    'https://m.youtube.com/@SaudiSunnahTv/live',
                    isTr ? 'Medine - Mescid-i Nebevi' : 'Madinah - Masjid an-Nabawi',
                  ),
                liveIndicatorColor: Colors.red,
              ),
            ),
            SizedBox(height: 32),
            // Additional info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.textColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.textColor.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: textColor.withValues(alpha: 0.4),
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isTr
                            ? 'Yayınlar uygulama içerisinde açılır. İnternet bağlantısı ve YouTube platformu gereklidir.'
                            : 'Streams open inside the app via YouTube. Internet connection required.',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.5),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStreamCard({
    required String title,
    required String subtitle,
    required String emoji,
    required List<Color> gradientColors,
    required Color accentColor,
    required VoidCallback onTap,
    required Color liveIndicatorColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Emoji icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(emoji, style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.textColor.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Live indicator + watch button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LIVE badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: liveIndicatorColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: liveIndicatorColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: liveIndicatorColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'CANLI',
                          style: TextStyle(
                            color: liveIndicatorColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Watch button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          color: accentColor,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          appSettings.languageCode == 'tr' ? 'İzle' : 'Watch',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
