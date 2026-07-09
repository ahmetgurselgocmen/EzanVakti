/// Simple localization support for Turkish and English
class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static const Map<String, Map<String, String>> _translations = {
    'tr': {
      // App
      'appTitle': 'Ezan Vakti',
      'selectLocation': 'Konumunuzu seçin',
      'orSelectCity': 'veya şehir seçin',
      'gpsLocate': '📍 GPS ile Konum Belirle',
      'gpsLocating': 'Konum Alınıyor...',
      'searchCityCountry': 'Şehir veya ülke ara...',
      'all': 'Tümü',
      'cityNotFound': 'Şehir bulunamadı',

      'notificationSettings': 'Bildirim Ayarları',
      // Prayer Names
      'fajr': 'İmsak',
      'sunrise': 'Güneş',
      'dhuhr': 'Öğle',
      'asr': 'İkindi',
      'maghrib': 'Akşam',
      'isha': 'Yatsı',
      'calculationMethod': 'Hesaplama Metodu',
      'calculationCountry': 'Bulunduğunuz Ülke/Bölge',
      'language': 'Dil',
      'fontSize': 'Yazı Boyutu',

      // Home
      'nextPrayer': 'Sonraki Vakit',
      'prayerTimeEntered': 'vakti girdi',

      // Location
      'selectLocationTitle': 'Konum Seçin',
      'locationPermissionDenied': 'Konum izni verilmedi',
      'locationFailed': 'Konum alınamadı',
      'myLocation': 'Konumum',

      // Settings
      'settings': 'Ayarlar',
      // Daily Content
      'dailyVerse': 'Günün Ayeti',
      'verseContent': 'Şüphesiz namaz, müminlere belirli vakitlere bağlı olarak farz kılınmıştır.',
      'verseSource': 'Nisâ Suresi, 103',
      'save': 'Kaydet',
      'theme': 'Tema',
      'darkTheme': 'Koyu Tema',
      'lightTheme': 'Açık Tema',
      'systemTheme': 'Sistem',
      'notifications': 'Bildirimler',
      'notificationsEnabled': 'Ezan Bildirimleri',
      'appearance': 'Görünüm',
      'prayerSettings': 'Namaz Ayarları',
      'general': 'Genel',
      'about': 'Hakkında',
      'version': 'Versiyon',
      'appDescription': 'Dünya genelinde namaz vakitleri',

      // Bottom Nav & New Features
      'navHome': 'Ana Sayfa',
      'navZikirmatik': 'Zikirmatik',
      'navEsma': 'Esmaül Hüsna',
      'navOthers': 'Diğer',
      'navSettings': 'Ayarlar',
      'reset': 'Sıfırla',
      'zikirmatikTitle': 'Dijital Tesbih',
      'dhikr_subhanallah': 'Sübhânallah',
      'dhikr_alhamdulillah': 'Elhamdülillâh',
      'dhikr_allahuakbar': 'Allahu Ekber',
      'dhikr_lailahaillallah': 'Lâ ilâhe illallah',
      'dhikr_estagfirullah': 'Estağfirullah',
      'dhikr_salavat': 'Allahümme salli alâ Muhammed',

      // Regions
      'Türkiye': 'Türkiye',
      'Ortadoğu': 'Ortadoğu',
      'Avrupa': 'Avrupa',
      'Afrika': 'Afrika',
      'Güney Asya': 'Güney Asya',
      'Güneydoğu Asya': 'Güneydoğu Asya',
      'Orta Asya': 'Orta Asya',
      'Amerika': 'Amerika',
      'Okyanusya': 'Okyanusya',

      // Hijri Months TR
      'muharram': 'Muharrem',
      'safar': 'Safer',
      'rabiAlAwwal': 'Rebiülevvel',
      'rabiAlThani': 'Rebiülahir',
      'jumadaAlAwwal': 'Cemaziyelevvel',
      'jumadaAlThani': 'Cemaziyelahir',
      'rajab': 'Recep',
      'shaban': 'Şaban',
      'ramadan': 'Ramazan',
      'shawwal': 'Şevval',
      'dhuAlQidah': 'Zilkade',
      'dhuAlHijjah': 'Zilhicce',
      'navQuran': 'Kur\'an-ı Kerim',
      'navQibla': 'Kıble Pusulası',
      'navHadith': 'Hadis-i Şerif',
      'quranTitle': 'Kur\'an-ı Kerim',
      'surahs': 'Sureler',
      'qiblaTitle': 'Kıble Pusulası',
      'qiblaDesc': 'Ok Kabe\'yi gösterdiğinde cihaz titrer.',
      'hadithTitle': '40 Hadis',

      // Onboarding
      'onboardingWelcome': 'Hoş Geldiniz',
      'onboardingWelcomeDesc': 'Ezan Vakti ile namaz vakitlerini takip edin, Kur\'an-ı Kerim okuyun ve dini günleri kaçırmayın.',
      'onboardingLanguage': 'Dil Seçimi',
      'onboardingLanguageDesc': 'Uygulamada kullanmak istediğiniz dili seçin.',
      'onboardingMethod': 'Hesaplama Metodu',
      'onboardingMethodDesc': 'Namaz vakitlerinin doğru hesaplanması için bulunduğunuz ülke/bölgeyi seçin.',
      'onboardingLocation': 'Konum Seçimi',
      'onboardingLocationDesc': 'Namaz vakitleri için konumunuzu belirleyin.',
      'onboardingNext': 'İleri',
      'onboardingBack': 'Geri',
      'onboardingStart': 'Başla',
      'onboardingSkip': 'Atla',

      // Religious Calendar
      'religiousCalendar': 'Dini Takvim',
      'religiousDays': 'Dini Günler',
      'daysLeft': 'Gün Kaldı',
      'today': 'Bugün',

      // Location Settings
      'locationSettings': 'Konum',
      'currentLocation': 'Mevcut Konum',
      'changeLocation': 'Konum Değiştir',

      // Live Stream
      'liveStream': 'Canlı Yayın',

      // Support
      'support': 'Destek',
      'supportEmail': 'E-posta Adresiniz',
      'supportSubject': 'Konu',
      'supportMessage': 'Mesajınız',
      'supportSend': 'Gönder',
      'supportEmptyError': 'Lütfen tüm alanları doldurun',
      'supportEmailHint': 'Örn: adiniz@email.com',
      'supportSubjectHint': 'Örn: Uygulama hakkında önerim',
      'supportMessageHint': 'Mesajınızı buraya yazın...',
      'supportSuccessMessage': 'Geri bildiriminiz için teşekkür ederiz!',
      'error': 'Hata',
      'success': 'Başarılı',
      'ok': 'Tamam',
    },
    'en': {
      // App
      'appTitle': 'Prayer Times',
      'selectLocation': 'Select your location',
      'orSelectCity': 'or select a city',
      'gpsLocate': '📍 Detect via GPS',
      'gpsLocating': 'Getting Location...',
      'searchCityCountry': 'Search city or country...',
      'all': 'All',
      'cityNotFound': 'City not found',

      'notificationSettings': 'Notification Settings',
      // Prayer Names
      'fajr': 'Fajr',
      'sunrise': 'Sunrise',
      'dhuhr': 'Dhuhr',
      'asr': 'Asr',
      'maghrib': 'Maghrib',
      'isha': 'Isha',
      'calculationMethod': 'Calculation Method',
      'calculationCountry': 'Country / Region',
      'language': 'Language',
      'fontSize': 'Font Size',

      // Home
      'nextPrayer': 'Next Prayer',
      'prayerTimeEntered': 'time has entered',

      // Location
      'selectLocationTitle': 'Select Location',
      'locationPermissionDenied': 'Location permission denied',
      'locationFailed': 'Could not get location',
      'myLocation': 'My Location',

      // Settings
      'settings': 'Settings',
      // Daily Content
      'dailyVerse': 'Verse of the Day',
      'verseContent': 'Indeed, prayer has been decreed upon the believers a decree of specified times.',
      'verseSource': 'Surah An-Nisa, 103',
      'save': 'Save',
      'theme': 'Theme',
      'darkTheme': 'Dark Theme',
      'lightTheme': 'Light Theme',
      'systemTheme': 'System',
      'notifications': 'Notifications',
      'notificationsEnabled': 'Adhan Notifications',
      'appearance': 'Appearance',
      'prayerSettings': 'Prayer Settings',
      'general': 'General',
      'about': 'About',
      'version': 'Version',
      'appDescription': 'Global prayer times',

      // Bottom Nav & New Features
      'navHome': 'Home',
      'navZikirmatik': 'Tasbih',
      'navEsma': '99 Names',
      'navOthers': 'Others',
      'navSettings': 'Settings',
      'reset': 'Reset',
      'zikirmatikTitle': 'Digital Tasbih',
      'dhikr_subhanallah': 'Subhanallah',
      'dhikr_alhamdulillah': 'Alhamdulillah',
      'dhikr_allahuakbar': 'Allahu Akbar',
      'dhikr_lailahaillallah': 'La ilaha illallah',
      'dhikr_estagfirullah': 'Astaghfirullah',
      'dhikr_salavat': 'Allahumma salli ala Muhammad',

      // Regions
      'Türkiye': 'Turkey',
      'Ortadoğu': 'Middle East',
      'Avrupa': 'Europe',
      'Afrika': 'Africa',
      'Güney Asya': 'South Asia',
      'Güneydoğu Asya': 'Southeast Asia',
      'Orta Asya': 'Central Asia',
      'Amerika': 'Americas',
      'Okyanusya': 'Oceania',

      // Hijri Months EN
      'muharram': 'Muharram',
      'safar': 'Safar',
      'rabiAlAwwal': 'Rabi al-Awwal',
      'rabiAlThani': 'Rabi al-Thani',
      'jumadaAlAwwal': 'Jumada al-Awwal',
      'jumadaAlThani': 'Jumada al-Thani',
      'rajab': 'Rajab',
      'shaban': 'Sha\'ban',
      'ramadan': 'Ramadan',
      'shawwal': 'Shawwal',
      'dhuAlQidah': 'Dhu al-Qi\'dah',
      'dhuAlHijjah': 'Dhu al-Hijjah',
      'navQuran': 'Holy Quran',
      'navQibla': 'Qibla Compass',
      'navHadith': 'Hadith Shareef',
      'quranTitle': 'Holy Quran',
      'surahs': 'Surahs',
      'qiblaTitle': 'Qibla Compass',
      'qiblaDesc': 'Device vibrates when the arrow points to Kaaba.',
      'hadithTitle': '40 Hadith',

      // Onboarding
      'onboardingWelcome': 'Welcome',
      'onboardingWelcomeDesc': 'Track prayer times, read the Holy Quran, and never miss religious days with Prayer Times.',
      'onboardingLanguage': 'Language Selection',
      'onboardingLanguageDesc': 'Choose the language you want to use in the app.',
      'onboardingMethod': 'Calculation Method',
      'onboardingMethodDesc': 'Select your country/region for accurate prayer time calculations.',
      'onboardingLocation': 'Location Selection',
      'onboardingLocationDesc': 'Set your location for prayer times.',
      'onboardingNext': 'Next',
      'onboardingBack': 'Back',
      'onboardingStart': 'Start',
      'onboardingSkip': 'Skip',

      // Religious Calendar
      'religiousCalendar': 'Religious Calendar',
      'religiousDays': 'Religious Days',
      'daysLeft': 'Days Left',
      'today': 'Today',

      // Location Settings
      'locationSettings': 'Location',
      'currentLocation': 'Current Location',
      'changeLocation': 'Change Location',

      // Live Stream
      'liveStream': 'Live Stream',

      // Support
      'support': 'Support',
      'supportEmail': 'Your Email',
      'supportSubject': 'Subject',
      'supportMessage': 'Your Message',
      'supportSend': 'Send',
      'supportEmptyError': 'Please fill all fields',
      'supportEmailHint': 'e.g. yourname@email.com',
      'supportSubjectHint': 'e.g. Suggestion for the app',
      'supportMessageHint': 'Write your message here...',
      'supportSuccessMessage': 'Thank you for your feedback!',
      'error': 'Error',
      'success': 'Success',
      'ok': 'OK',
    },
  };

  String t(String key) {
    return _translations[languageCode]?[key] ??
        _translations['en']?[key] ??
        key;
  }

  /// Get localized prayer name
  String prayerName(String prayerKey) {
    return t(prayerKey);
  }

  static List<String> get supportedLanguages => ['tr', 'en'];

  static String languageDisplayName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }
}
