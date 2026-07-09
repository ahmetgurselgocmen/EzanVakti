import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/notification_service.dart';
import 'services/time_service.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'providers/app_settings_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

// Global settings provider
final appSettings = AppSettingsProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      final GoogleMapsFlutterPlatform mapsImplementation =
          GoogleMapsFlutterPlatform.instance;
      if (mapsImplementation is GoogleMapsFlutterAndroid) {
        mapsImplementation.useAndroidViewSurface = true;
      }
    } catch (_) {}
  }

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await MobileAds.instance.initialize();

  await initializeDateFormatting('tr_TR', null);
  await TimeService.syncWithInternet();
  await NotificationService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final hasCity = prefs.containsKey('cityName');

  runApp(EzanVaktiApp(showWelcome: !hasCity));
}

class EzanVaktiApp extends StatefulWidget {
  final bool showWelcome;

  const EzanVaktiApp({super.key, required this.showWelcome});

  @override
  State<EzanVaktiApp> createState() => _EzanVaktiAppState();
}

class _EzanVaktiAppState extends State<EzanVaktiApp> {
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(appSettings.textScaleFactor),
          ),
          child: child!,
        );
      },
      title: appSettings.l10n.t('appTitle'),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: widget.showWelcome ? const WelcomeScreen() : const MainScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/welcome':
            return MaterialPageRoute(
              builder: (_) => const WelcomeScreen(),
            );
          case '/home':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => MainScreen(initialData: args),
            );
          default:
            return null;
        }
      },
    );
  }
}
