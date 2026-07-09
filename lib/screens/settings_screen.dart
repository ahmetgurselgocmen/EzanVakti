import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/prayer_time_service.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import 'location_screen.dart';
import '../widgets/dynamic_background.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _cityName = '';
  String _countryName = '';
  final Map<PrayerType, bool> _notificationSettings = {};
  bool _persistentEnabled = true;
  bool _autoDetectLocation = false; // Mock state for auto-detect

  @override
  void initState() {
    super.initState();
    _loadSettings();
    appSettings.addListener(_onSettingsChanged);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString('cityName') ?? '';
    final country = prefs.getString('countryName') ?? '';
    
    final notifs = <PrayerType, bool>{};
    for (final type in PrayerType.values) {
      notifs[type] = prefs.getBool('notif_${type.name}') ?? (type != PrayerType.sunrise);
    }

    final persistentEnabled = await NotificationService.isPersistentNotificationEnabled();

    if (mounted) {
      setState(() {
        _cityName = city;
        _countryName = country;
        _notificationSettings.addAll(notifs);
        _persistentEnabled = persistentEnabled;
      });
    }
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  AppLocalizations get l10n => appSettings.l10n;

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
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildEzanAlertsCard(),
                        const SizedBox(height: 20),
                        _buildLocationCard(),
                        const SizedBox(height: 20),
                        _buildPreferencesCard(),
                        const SizedBox(height: 32),
                      ],
                    ),
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

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          l10n.t('navSettings'),
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCardHeader({required IconData icon, required String title, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.primaryColor, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEzanAlertsCard() {
    final isTr = appSettings.languageCode == 'tr';
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.notifications_active_outlined,
            title: isTr ? 'Ezan Bildirimleri' : 'Ezan Alerts',
          ),
          ...PrayerType.values.map((type) {
            final isEnabled = _notificationSettings[type] ?? true;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.prayerName(type.name),
                            style: TextStyle(
                              color: AppColors.textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isTr ? 'Tam Ezan' : 'Full Adhan',
                            style: TextStyle(
                              color: AppColors.textColor.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      CupertinoSwitch(
                        activeTrackColor: AppColors.primaryColor,
                        value: isEnabled,
                        onChanged: (val) async {
                          setState(() {
                            _notificationSettings[type] = val;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('notif_${type.name}', val);
                          appSettings.notifySettingsChanged();
                        },
                      ),
                    ],
                  ),
                ),
                if (type != PrayerType.isha)
                  Divider(color: AppColors.borderColor.withValues(alpha: 0.3), height: 1, indent: 20, endIndent: 20),
              ],
            );
          }),
          Divider(color: AppColors.borderColor.withValues(alpha: 0.3), height: 1, indent: 20, endIndent: 20),
          // Persistent Notification toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Sabit Bildirim' : 'Persistent Notification',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTr ? 'Bildirim çubuğunda göster' : 'Show in status bar',
                      style: TextStyle(
                        color: AppColors.textColor.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                CupertinoSwitch(
                  activeTrackColor: AppColors.primaryColor,
                  value: _persistentEnabled,
                  onChanged: (val) async {
                    setState(() {
                      _persistentEnabled = val;
                    });
                    await NotificationService.setPersistentNotificationEnabled(val);
                    appSettings.notifySettingsChanged();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final isTr = appSettings.languageCode == 'tr';
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.location_on_outlined,
            title: isTr ? 'Konum' : 'Location',
            iconColor: AppColors.primaryColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTr ? 'Otomatik Konum (GPS)' : 'Auto-detect Location (GPS)',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _cityName.isNotEmpty
                          ? (isTr ? 'Şu an: $_cityName, $_countryName' : 'Currently: $_cityName, $_countryName')
                          : (isTr ? 'Konum bulunamadı' : 'Location not found'),
                      style: TextStyle(
                        color: AppColors.textColor.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                CupertinoSwitch(
                  activeTrackColor: AppColors.primaryColor,
                  value: _autoDetectLocation,
                  onChanged: (val) {
                    setState(() {
                      _autoDetectLocation = val;
                    });
                  },
                ),
              ],
            ),
          ),
          Divider(color: AppColors.borderColor.withValues(alpha: 0.3), height: 1, indent: 20, endIndent: 20),
          InkWell(
            onTap: _onChangeLocationTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isTr ? 'Manuel Konum' : 'Manual Location',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTr ? 'Vakitler için sabit şehir seç' : 'Set a fixed city for times',
                        style: TextStyle(
                          color: AppColors.textColor.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textColor.withValues(alpha: 0.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    final isTr = appSettings.languageCode == 'tr';
    final languageName = AppLocalizations.languageDisplayName(appSettings.languageCode);

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            icon: Icons.tune_rounded,
            title: isTr ? 'Tercihler' : 'Preferences',
            iconColor: AppColors.primaryColor,
          ),
          InkWell(
            onTap: () {}, // Theme is currently global dynamic, placeholder action
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, color: AppColors.textColor.withValues(alpha: 0.6), size: 20),
                  const SizedBox(width: 16),
                  Text(
                    isTr ? 'Tema' : 'Theme',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isTr ? 'Sistem Varsayılanı' : 'System Default',
                    style: TextStyle(
                      color: AppColors.textColor.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: AppColors.textColor.withValues(alpha: 0.3), size: 20),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.borderColor.withValues(alpha: 0.3), height: 1, indent: 56, endIndent: 20),
          InkWell(
            onTap: _showLanguagePicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.language_outlined, color: AppColors.textColor.withValues(alpha: 0.6), size: 20),
                  const SizedBox(width: 16),
                  Text(
                    isTr ? 'Dil' : 'Language',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    languageName,
                    style: TextStyle(
                      color: AppColors.textColor.withValues(alpha: 0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: AppColors.textColor.withValues(alpha: 0.3), size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onChangeLocationTap() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('latitude') ?? 41.0082;
    final lng = prefs.getDouble('longitude') ?? 28.9784;
    if (!mounted) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationScreen(
          currentLatitude: lat,
          currentLongitude: lng,
        ),
      ),
    );
    if (result != null) {
      await prefs.setString('cityName', result['cityName'] ?? '');
      await prefs.setString('countryName', result['countryName'] ?? '');
      await prefs.setString('districtName', result['district'] ?? '');
      await prefs.setDouble('latitude', result['latitude'] ?? lat);
      await prefs.setDouble('longitude', result['longitude'] ?? lng);
      setState(() {
        _cityName = result['cityName'] ?? '';
        _countryName = result['countryName'] ?? '';
      });
      appSettings.notifySettingsChanged();
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderColor.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(l10n.t('language'), style: TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...AppLocalizations.supportedLanguages.map((code) {
                final isSelected = appSettings.languageCode == code;
                return ListTile(
                  leading: isSelected ? Icon(Icons.check_circle, color: AppColors.primaryColor) : const Icon(Icons.circle_outlined, color: Colors.transparent),
                  title: Text(AppLocalizations.languageDisplayName(code), style: TextStyle(color: AppColors.textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  onTap: () {
                    appSettings.setLanguage(code);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
