import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../main.dart';

class AdService {
  // Canlıya alırken (App Store/Play Store'a yüklerken) bu değeri 'false' yapın.
  static const bool useTestAds = true;

  // TODO: Kendi AdMob hesabınızdan aldığınız gerçek Reklam Birimi Kimliklerini (Ad Unit IDs) buraya girin:
  static const String _realAndroidBannerId = 'ca-app-pub-xxx/xxx'; // Android Banner ID'niz
  static const String _realAndroidInterstitialId = 'ca-app-pub-xxx/xxx'; // Android Geçiş Reklamı ID'niz

  static const String _realIOSBannerId = 'ca-app-pub-xxx/xxx'; // iOS Banner ID'niz
  static const String _realIOSInterstitialId = 'ca-app-pub-xxx/xxx'; // iOS Geçiş Reklamı ID'niz

  static String get bannerAdUnitId {
    if (useTestAds) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Android Test Banner ID
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner ID
      }
    } else {
      if (Platform.isAndroid) {
        return _realAndroidBannerId;
      } else if (Platform.isIOS) {
        return _realIOSBannerId;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    if (useTestAds) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712'; // Android Test Interstitial ID
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910'; // iOS Test Interstitial ID
      }
    } else {
      if (Platform.isAndroid) {
        return _realAndroidInterstitialId;
      } else if (Platform.isIOS) {
        return _realIOSInterstitialId;
      }
    }
    throw UnsupportedError('Unsupported platform');
  }

  static InterstitialAd? _interstitialAd;

  static void showInterstitialAd() {
    if (appSettings.isPro) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
            },
          );
          _interstitialAd?.show();
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }
}

class CustomBannerAd extends StatefulWidget {
  const CustomBannerAd({super.key});

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (appSettings.isPro) return SizedBox.shrink();

    if (_isLoaded && _bannerAd != null) {
      return SafeArea(
        child: Container(
          alignment: Alignment.center,
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }
    return SizedBox(height: 0);
  }
}
