import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

/// Global app settings provider for theme, language, etc.
class AppSettingsProvider extends ChangeNotifier {
  String _languageCode = 'tr';
  double _textScaleFactor = 1.0;
  late AppLocalizations _localizations;

  bool _isPro = false;
  int _themeIndex = 0;

  AppSettingsProvider() {
    _localizations = AppLocalizations(_languageCode);
    _loadSettings();
  }

  String get languageCode => _languageCode;
  double get textScaleFactor => _textScaleFactor;
  AppLocalizations get l10n => _localizations;
  bool get isPro => _isPro;
  int get themeIndex => _themeIndex;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _languageCode = prefs.getString('languageCode') ?? 'tr';
    _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
    _isPro = prefs.getBool('isPro') ?? false;
    _themeIndex = prefs.getInt('themeIndex') ?? 0;
    _localizations = AppLocalizations(_languageCode);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    _localizations = AppLocalizations(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double scale) async {
    _textScaleFactor = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('textScaleFactor', scale);
    notifyListeners();
  }

  Future<void> setPro(bool status) async {
    _isPro = status;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPro', status);
    notifyListeners();
  }

  Future<void> setThemeIndex(int index) async {
    _themeIndex = index;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeIndex', index);
    notifyListeners();
  }

  void notifySettingsChanged() {
    notifyListeners();
  }
}
