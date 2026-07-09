class City {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;
  final double timezoneOffset;

  const City({
    required this.name,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffset,
  });

  String get displayName => '$name, $country';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is City &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          country == other.country;

  @override
  int get hashCode => name.hashCode ^ country.hashCode;
}

class CitiesData {
  static const List<City> allCities = [
    // ---- TÜRKİYE (81 İL) ----
    City(name: 'Adana', country: 'Türkiye', region: 'Türkiye', latitude: 37.0000, longitude: 35.3213, timezoneOffset: 3),
    City(name: 'Adıyaman', country: 'Türkiye', region: 'Türkiye', latitude: 37.7648, longitude: 38.2786, timezoneOffset: 3),
    City(name: 'Afyonkarahisar', country: 'Türkiye', region: 'Türkiye', latitude: 38.7507, longitude: 30.5567, timezoneOffset: 3),
    City(name: 'Ağrı', country: 'Türkiye', region: 'Türkiye', latitude: 39.7191, longitude: 43.0503, timezoneOffset: 3),
    City(name: 'Amasya', country: 'Türkiye', region: 'Türkiye', latitude: 40.6499, longitude: 35.8353, timezoneOffset: 3),
    City(name: 'Ankara', country: 'Türkiye', region: 'Türkiye', latitude: 39.9334, longitude: 32.8597, timezoneOffset: 3),
    City(name: 'Antalya', country: 'Türkiye', region: 'Türkiye', latitude: 36.8969, longitude: 30.7133, timezoneOffset: 3),
    City(name: 'Artvin', country: 'Türkiye', region: 'Türkiye', latitude: 41.1828, longitude: 41.8183, timezoneOffset: 3),
    City(name: 'Aydın', country: 'Türkiye', region: 'Türkiye', latitude: 37.8380, longitude: 27.8456, timezoneOffset: 3),
    City(name: 'Balıkesir', country: 'Türkiye', region: 'Türkiye', latitude: 39.6484, longitude: 27.8826, timezoneOffset: 3),
    City(name: 'Bilecik', country: 'Türkiye', region: 'Türkiye', latitude: 40.1451, longitude: 29.9798, timezoneOffset: 3),
    City(name: 'Bingöl', country: 'Türkiye', region: 'Türkiye', latitude: 38.8847, longitude: 40.4939, timezoneOffset: 3),
    City(name: 'Bitlis', country: 'Türkiye', region: 'Türkiye', latitude: 38.4006, longitude: 42.1095, timezoneOffset: 3),
    City(name: 'Bolu', country: 'Türkiye', region: 'Türkiye', latitude: 40.7392, longitude: 31.6111, timezoneOffset: 3),
    City(name: 'Burdur', country: 'Türkiye', region: 'Türkiye', latitude: 37.7183, longitude: 30.2823, timezoneOffset: 3),
    City(name: 'Bursa', country: 'Türkiye', region: 'Türkiye', latitude: 40.1885, longitude: 29.0610, timezoneOffset: 3),
    City(name: 'Çanakkale', country: 'Türkiye', region: 'Türkiye', latitude: 40.1553, longitude: 26.4142, timezoneOffset: 3),
    City(name: 'Çankırı', country: 'Türkiye', region: 'Türkiye', latitude: 40.6013, longitude: 33.6134, timezoneOffset: 3),
    City(name: 'Çorum', country: 'Türkiye', region: 'Türkiye', latitude: 40.5499, longitude: 34.9537, timezoneOffset: 3),
    City(name: 'Denizli', country: 'Türkiye', region: 'Türkiye', latitude: 37.7765, longitude: 29.0864, timezoneOffset: 3),
    City(name: 'Diyarbakır', country: 'Türkiye', region: 'Türkiye', latitude: 37.9144, longitude: 40.2306, timezoneOffset: 3),
    City(name: 'Edirne', country: 'Türkiye', region: 'Türkiye', latitude: 41.6771, longitude: 26.5557, timezoneOffset: 3),
    City(name: 'Elazığ', country: 'Türkiye', region: 'Türkiye', latitude: 38.6810, longitude: 39.2264, timezoneOffset: 3),
    City(name: 'Erzincan', country: 'Türkiye', region: 'Türkiye', latitude: 39.7500, longitude: 39.5000, timezoneOffset: 3),
    City(name: 'Erzurum', country: 'Türkiye', region: 'Türkiye', latitude: 39.9055, longitude: 41.2658, timezoneOffset: 3),
    City(name: 'Eskişehir', country: 'Türkiye', region: 'Türkiye', latitude: 39.7767, longitude: 30.5206, timezoneOffset: 3),
    City(name: 'Gaziantep', country: 'Türkiye', region: 'Türkiye', latitude: 37.0662, longitude: 37.3833, timezoneOffset: 3),
    City(name: 'Giresun', country: 'Türkiye', region: 'Türkiye', latitude: 40.9128, longitude: 38.3895, timezoneOffset: 3),
    City(name: 'Gümüşhane', country: 'Türkiye', region: 'Türkiye', latitude: 40.4611, longitude: 39.4811, timezoneOffset: 3),
    City(name: 'Hakkâri', country: 'Türkiye', region: 'Türkiye', latitude: 37.5744, longitude: 43.7408, timezoneOffset: 3),
    City(name: 'Hatay', country: 'Türkiye', region: 'Türkiye', latitude: 36.2000, longitude: 36.1667, timezoneOffset: 3),
    City(name: 'Isparta', country: 'Türkiye', region: 'Türkiye', latitude: 37.7648, longitude: 30.5566, timezoneOffset: 3),
    City(name: 'Mersin', country: 'Türkiye', region: 'Türkiye', latitude: 36.8121, longitude: 34.6415, timezoneOffset: 3),
    City(name: 'İstanbul', country: 'Türkiye', region: 'Türkiye', latitude: 41.0082, longitude: 28.9784, timezoneOffset: 3),
    City(name: 'İzmir', country: 'Türkiye', region: 'Türkiye', latitude: 38.4192, longitude: 27.1287, timezoneOffset: 3),
    City(name: 'Kars', country: 'Türkiye', region: 'Türkiye', latitude: 40.6013, longitude: 43.0975, timezoneOffset: 3),
    City(name: 'Kastamonu', country: 'Türkiye', region: 'Türkiye', latitude: 41.3766, longitude: 33.7765, timezoneOffset: 3),
    City(name: 'Kayseri', country: 'Türkiye', region: 'Türkiye', latitude: 38.7312, longitude: 35.4787, timezoneOffset: 3),
    City(name: 'Kırklareli', country: 'Türkiye', region: 'Türkiye', latitude: 41.7333, longitude: 27.2167, timezoneOffset: 3),
    City(name: 'Kırşehir', country: 'Türkiye', region: 'Türkiye', latitude: 39.1458, longitude: 34.1639, timezoneOffset: 3),
    City(name: 'Kocaeli', country: 'Türkiye', region: 'Türkiye', latitude: 40.8533, longitude: 29.8815, timezoneOffset: 3),
    City(name: 'Konya', country: 'Türkiye', region: 'Türkiye', latitude: 37.8746, longitude: 32.4932, timezoneOffset: 3),
    City(name: 'Kütahya', country: 'Türkiye', region: 'Türkiye', latitude: 39.4167, longitude: 29.9833, timezoneOffset: 3),
    City(name: 'Malatya', country: 'Türkiye', region: 'Türkiye', latitude: 38.3554, longitude: 38.3335, timezoneOffset: 3),
    City(name: 'Manisa', country: 'Türkiye', region: 'Türkiye', latitude: 38.6191, longitude: 27.4289, timezoneOffset: 3),
    City(name: 'Kahramanmaraş', country: 'Türkiye', region: 'Türkiye', latitude: 37.5753, longitude: 36.9228, timezoneOffset: 3),
    City(name: 'Mardin', country: 'Türkiye', region: 'Türkiye', latitude: 37.3131, longitude: 40.7436, timezoneOffset: 3),
    City(name: 'Muğla', country: 'Türkiye', region: 'Türkiye', latitude: 37.2153, longitude: 28.3636, timezoneOffset: 3),
    City(name: 'Muş', country: 'Türkiye', region: 'Türkiye', latitude: 38.7346, longitude: 41.4910, timezoneOffset: 3),
    City(name: 'Nevşehir', country: 'Türkiye', region: 'Türkiye', latitude: 38.6244, longitude: 34.7144, timezoneOffset: 3),
    City(name: 'Niğde', country: 'Türkiye', region: 'Türkiye', latitude: 37.9667, longitude: 34.6833, timezoneOffset: 3),
    City(name: 'Ordu', country: 'Türkiye', region: 'Türkiye', latitude: 40.9862, longitude: 37.8797, timezoneOffset: 3),
    City(name: 'Rize', country: 'Türkiye', region: 'Türkiye', latitude: 41.0201, longitude: 40.5234, timezoneOffset: 3),
    City(name: 'Sakarya', country: 'Türkiye', region: 'Türkiye', latitude: 40.7731, longitude: 30.3948, timezoneOffset: 3),
    City(name: 'Samsun', country: 'Türkiye', region: 'Türkiye', latitude: 41.2867, longitude: 36.3300, timezoneOffset: 3),
    City(name: 'Siirt', country: 'Türkiye', region: 'Türkiye', latitude: 37.9333, longitude: 41.9500, timezoneOffset: 3),
    City(name: 'Sinop', country: 'Türkiye', region: 'Türkiye', latitude: 42.0231, longitude: 35.1531, timezoneOffset: 3),
    City(name: 'Sivas', country: 'Türkiye', region: 'Türkiye', latitude: 39.7477, longitude: 37.0179, timezoneOffset: 3),
    City(name: 'Tekirdağ', country: 'Türkiye', region: 'Türkiye', latitude: 40.9780, longitude: 27.5110, timezoneOffset: 3),
    City(name: 'Tokat', country: 'Türkiye', region: 'Türkiye', latitude: 40.3167, longitude: 36.5500, timezoneOffset: 3),
    City(name: 'Trabzon', country: 'Türkiye', region: 'Türkiye', latitude: 41.0015, longitude: 39.7178, timezoneOffset: 3),
    City(name: 'Tunceli', country: 'Türkiye', region: 'Türkiye', latitude: 39.1079, longitude: 39.5401, timezoneOffset: 3),
    City(name: 'Şanlıurfa', country: 'Türkiye', region: 'Türkiye', latitude: 37.1591, longitude: 38.7969, timezoneOffset: 3),
    City(name: 'Uşak', country: 'Türkiye', region: 'Türkiye', latitude: 38.6823, longitude: 29.4082, timezoneOffset: 3),
    City(name: 'Van', country: 'Türkiye', region: 'Türkiye', latitude: 38.4891, longitude: 43.3832, timezoneOffset: 3),
    City(name: 'Yozgat', country: 'Türkiye', region: 'Türkiye', latitude: 39.8181, longitude: 34.8147, timezoneOffset: 3),
    City(name: 'Zonguldak', country: 'Türkiye', region: 'Türkiye', latitude: 41.4564, longitude: 31.7762, timezoneOffset: 3),
    City(name: 'Aksaray', country: 'Türkiye', region: 'Türkiye', latitude: 38.3687, longitude: 34.0370, timezoneOffset: 3),
    City(name: 'Bayburt', country: 'Türkiye', region: 'Türkiye', latitude: 40.2552, longitude: 40.2249, timezoneOffset: 3),
    City(name: 'Karaman', country: 'Türkiye', region: 'Türkiye', latitude: 37.1811, longitude: 33.2222, timezoneOffset: 3),
    City(name: 'Kırıkkale', country: 'Türkiye', region: 'Türkiye', latitude: 39.8468, longitude: 33.5153, timezoneOffset: 3),
    City(name: 'Batman', country: 'Türkiye', region: 'Türkiye', latitude: 37.8812, longitude: 41.1351, timezoneOffset: 3),
    City(name: 'Şırnak', country: 'Türkiye', region: 'Türkiye', latitude: 37.5228, longitude: 42.4594, timezoneOffset: 3),
    City(name: 'Bartın', country: 'Türkiye', region: 'Türkiye', latitude: 41.6344, longitude: 32.3375, timezoneOffset: 3),
    City(name: 'Ardahan', country: 'Türkiye', region: 'Türkiye', latitude: 41.1105, longitude: 42.7022, timezoneOffset: 3),
    City(name: 'Iğdır', country: 'Türkiye', region: 'Türkiye', latitude: 39.9237, longitude: 44.0450, timezoneOffset: 3),
    City(name: 'Yalova', country: 'Türkiye', region: 'Türkiye', latitude: 40.6500, longitude: 29.2667, timezoneOffset: 3),
    City(name: 'Karabük', country: 'Türkiye', region: 'Türkiye', latitude: 41.2061, longitude: 32.6228, timezoneOffset: 3),
    City(name: 'Kilis', country: 'Türkiye', region: 'Türkiye', latitude: 36.7184, longitude: 37.1147, timezoneOffset: 3),
    City(name: 'Osmaniye', country: 'Türkiye', region: 'Türkiye', latitude: 37.0742, longitude: 36.2475, timezoneOffset: 3),
    City(name: 'Düzce', country: 'Türkiye', region: 'Türkiye', latitude: 40.8438, longitude: 31.1565, timezoneOffset: 3),

    // ---- ORTADOĞU ----
    City(name: 'Mekke', country: 'Suudi Arabistan', region: 'Ortadoğu', latitude: 21.3891, longitude: 39.8579, timezoneOffset: 3),
    City(name: 'Medine', country: 'Suudi Arabistan', region: 'Ortadoğu', latitude: 24.5247, longitude: 39.5692, timezoneOffset: 3),
    City(name: 'Riyad', country: 'Suudi Arabistan', region: 'Ortadoğu', latitude: 24.7136, longitude: 46.6753, timezoneOffset: 3),
    City(name: 'Cidde', country: 'Suudi Arabistan', region: 'Ortadoğu', latitude: 21.4858, longitude: 39.1925, timezoneOffset: 3),
    City(name: 'Dubai', country: 'BAE', region: 'Ortadoğu', latitude: 25.2048, longitude: 55.2708, timezoneOffset: 4),
    City(name: 'Abu Dabi', country: 'BAE', region: 'Ortadoğu', latitude: 24.4539, longitude: 54.3773, timezoneOffset: 4),
    City(name: 'Doha', country: 'Katar', region: 'Ortadoğu', latitude: 25.2854, longitude: 51.5310, timezoneOffset: 3),
    City(name: 'Kuveyt', country: 'Kuveyt', region: 'Ortadoğu', latitude: 29.3759, longitude: 47.9774, timezoneOffset: 3),
    City(name: 'Bağdat', country: 'Irak', region: 'Ortadoğu', latitude: 33.3152, longitude: 44.3661, timezoneOffset: 3),
    City(name: 'Erbil', country: 'Irak', region: 'Ortadoğu', latitude: 36.1911, longitude: 44.0092, timezoneOffset: 3),
    City(name: 'Tahran', country: 'İran', region: 'Ortadoğu', latitude: 35.6892, longitude: 51.3890, timezoneOffset: 3.5),
    City(name: 'Tebriz', country: 'İran', region: 'Ortadoğu', latitude: 38.0773, longitude: 46.2939, timezoneOffset: 3.5),
    City(name: 'Amman', country: 'Ürdün', region: 'Ortadoğu', latitude: 31.9454, longitude: 35.9284, timezoneOffset: 3),
    City(name: 'Beyrut', country: 'Lübnan', region: 'Ortadoğu', latitude: 33.8938, longitude: 35.5018, timezoneOffset: 3),
    City(name: 'Kudüs', country: 'Filistin', region: 'Ortadoğu', latitude: 31.7683, longitude: 35.2137, timezoneOffset: 3),
    City(name: 'Şam', country: 'Suriye', region: 'Ortadoğu', latitude: 33.5138, longitude: 36.2765, timezoneOffset: 3),
    City(name: 'Halep', country: 'Suriye', region: 'Ortadoğu', latitude: 36.2021, longitude: 37.1343, timezoneOffset: 3),
    City(name: 'Muskat', country: 'Umman', region: 'Ortadoğu', latitude: 23.5880, longitude: 58.3829, timezoneOffset: 4),
    City(name: 'Sana', country: 'Yemen', region: 'Ortadoğu', latitude: 15.3694, longitude: 44.1910, timezoneOffset: 3),

    // ---- AVRUPA ----
    City(name: 'Londra', country: 'İngiltere', region: 'Avrupa', latitude: 51.5074, longitude: -0.1278, timezoneOffset: 0),
    City(name: 'Berlin', country: 'Almanya', region: 'Avrupa', latitude: 52.5200, longitude: 13.4050, timezoneOffset: 1),
    City(name: 'Paris', country: 'Fransa', region: 'Avrupa', latitude: 48.8566, longitude: 2.3522, timezoneOffset: 1),
    City(name: 'Amsterdam', country: 'Hollanda', region: 'Avrupa', latitude: 52.3676, longitude: 4.9041, timezoneOffset: 1),
    City(name: 'Brüksel', country: 'Belçika', region: 'Avrupa', latitude: 50.8503, longitude: 4.3517, timezoneOffset: 1),
    City(name: 'Viyana', country: 'Avusturya', region: 'Avrupa', latitude: 48.2082, longitude: 16.3738, timezoneOffset: 1),
    City(name: 'Strazburg', country: 'Fransa', region: 'Avrupa', latitude: 48.5734, longitude: 7.7521, timezoneOffset: 1),
    City(name: 'Stockholm', country: 'İsveç', region: 'Avrupa', latitude: 59.3293, longitude: 18.0686, timezoneOffset: 1),
    City(name: 'Oslo', country: 'Norveç', region: 'Avrupa', latitude: 59.9139, longitude: 10.7522, timezoneOffset: 1),
    City(name: 'Kopenhag', country: 'Danimarka', region: 'Avrupa', latitude: 55.6761, longitude: 12.5683, timezoneOffset: 1),
    City(name: 'Roma', country: 'İtalya', region: 'Avrupa', latitude: 41.9028, longitude: 12.4964, timezoneOffset: 1),
    City(name: 'Madrid', country: 'İspanya', region: 'Avrupa', latitude: 40.4168, longitude: -3.7038, timezoneOffset: 1),
    City(name: 'Saraybosna', country: 'Bosna Hersek', region: 'Avrupa', latitude: 43.8563, longitude: 18.4131, timezoneOffset: 1),
    City(name: 'Sofya', country: 'Bulgaristan', region: 'Avrupa', latitude: 42.6977, longitude: 23.3219, timezoneOffset: 2),
    City(name: 'Atina', country: 'Yunanistan', region: 'Avrupa', latitude: 37.9838, longitude: 23.7275, timezoneOffset: 2),
    City(name: 'Moskova', country: 'Rusya', region: 'Avrupa', latitude: 55.7558, longitude: 37.6173, timezoneOffset: 3),
    City(name: 'St. Petersburg', country: 'Rusya', region: 'Avrupa', latitude: 59.9311, longitude: 30.3609, timezoneOffset: 3),
    City(name: 'Kazan', country: 'Rusya', region: 'Avrupa', latitude: 55.7963, longitude: 49.1088, timezoneOffset: 3),
    City(name: 'Kiev', country: 'Ukrayna', region: 'Avrupa', latitude: 50.4501, longitude: 30.5234, timezoneOffset: 2),

    // ---- AFRİKA ----
    City(name: 'Kahire', country: 'Mısır', region: 'Afrika', latitude: 30.0444, longitude: 31.2357, timezoneOffset: 2),
    City(name: 'İskenderiye', country: 'Mısır', region: 'Afrika', latitude: 31.2001, longitude: 29.9187, timezoneOffset: 2),
    City(name: 'Tunus', country: 'Tunus', region: 'Afrika', latitude: 36.8065, longitude: 10.1815, timezoneOffset: 1),
    City(name: 'Cezayir', country: 'Cezayir', region: 'Afrika', latitude: 36.7538, longitude: 3.0588, timezoneOffset: 1),
    City(name: 'Rabat', country: 'Fas', region: 'Afrika', latitude: 34.0209, longitude: -6.8416, timezoneOffset: 1),
    City(name: 'Kazablanka', country: 'Fas', region: 'Afrika', latitude: 33.5731, longitude: -7.5898, timezoneOffset: 1),
    City(name: 'Lagos', country: 'Nijerya', region: 'Afrika', latitude: 6.5244, longitude: 3.3792, timezoneOffset: 1),
    City(name: 'Abuja', country: 'Nijerya', region: 'Afrika', latitude: 9.0765, longitude: 7.3986, timezoneOffset: 1),
    City(name: 'Nairobi', country: 'Kenya', region: 'Afrika', latitude: -1.2921, longitude: 36.8219, timezoneOffset: 3),
    City(name: 'Hartum', country: 'Sudan', region: 'Afrika', latitude: 15.5007, longitude: 32.5599, timezoneOffset: 2),
    City(name: 'Mogadişu', country: 'Somali', region: 'Afrika', latitude: 2.0469, longitude: 45.3182, timezoneOffset: 3),
    City(name: 'Cibuti', country: 'Cibuti', region: 'Afrika', latitude: 11.5721, longitude: 43.1456, timezoneOffset: 3),
    City(name: 'Trablus', country: 'Libya', region: 'Afrika', latitude: 32.8872, longitude: 13.1913, timezoneOffset: 2),

    // ---- GÜNEY & GÜNEYDOĞU ASYA ----
    City(name: 'İslamabad', country: 'Pakistan', region: 'Güney Asya', latitude: 33.6844, longitude: 73.0479, timezoneOffset: 5),
    City(name: 'Karaçi', country: 'Pakistan', region: 'Güney Asya', latitude: 24.8607, longitude: 67.0011, timezoneOffset: 5),
    City(name: 'Lahor', country: 'Pakistan', region: 'Güney Asya', latitude: 31.5204, longitude: 74.3587, timezoneOffset: 5),
    City(name: 'Dakka', country: 'Bangladeş', region: 'Güney Asya', latitude: 23.8103, longitude: 90.4125, timezoneOffset: 6),
    City(name: 'Yeni Delhi', country: 'Hindistan', region: 'Güney Asya', latitude: 28.6139, longitude: 77.2090, timezoneOffset: 5.5),
    City(name: 'Mumbai', country: 'Hindistan', region: 'Güney Asya', latitude: 19.0760, longitude: 72.8777, timezoneOffset: 5.5),
    City(name: 'Kabil', country: 'Afganistan', region: 'Güney Asya', latitude: 34.5553, longitude: 69.2075, timezoneOffset: 4.5),
    City(name: 'Cakarta', country: 'Endonezya', region: 'Güneydoğu Asya', latitude: -6.2088, longitude: 106.8456, timezoneOffset: 7),
    City(name: 'Banda Açe', country: 'Endonezya', region: 'Güneydoğu Asya', latitude: 5.5483, longitude: 95.3238, timezoneOffset: 7),
    City(name: 'Kuala Lumpur', country: 'Malezya', region: 'Güneydoğu Asya', latitude: 3.1390, longitude: 101.6869, timezoneOffset: 8),
    City(name: 'Singapur', country: 'Singapur', region: 'Güneydoğu Asya', latitude: 1.3521, longitude: 103.8198, timezoneOffset: 8),
    City(name: 'Bangkok', country: 'Tayland', region: 'Güneydoğu Asya', latitude: 13.7563, longitude: 100.5018, timezoneOffset: 7),

    // ---- ORTA ASYA ----
    City(name: 'Taşkent', country: 'Özbekistan', region: 'Orta Asya', latitude: 41.2995, longitude: 69.2401, timezoneOffset: 5),
    City(name: 'Semerkant', country: 'Özbekistan', region: 'Orta Asya', latitude: 39.6270, longitude: 66.9750, timezoneOffset: 5),
    City(name: 'Almatı', country: 'Kazakistan', region: 'Orta Asya', latitude: 43.2220, longitude: 76.8512, timezoneOffset: 6),
    City(name: 'Astana', country: 'Kazakistan', region: 'Orta Asya', latitude: 51.1694, longitude: 71.4491, timezoneOffset: 6),
    City(name: 'Bişkek', country: 'Kırgızistan', region: 'Orta Asya', latitude: 42.8746, longitude: 74.5698, timezoneOffset: 6),
    City(name: 'Bakü', country: 'Azerbaycan', region: 'Orta Asya', latitude: 40.4093, longitude: 49.8671, timezoneOffset: 4),
    City(name: 'Aşkabat', country: 'Türkmenistan', region: 'Orta Asya', latitude: 37.9601, longitude: 58.3261, timezoneOffset: 5),
    City(name: 'Duşanbe', country: 'Tacikistan', region: 'Orta Asya', latitude: 38.5598, longitude: 68.7870, timezoneOffset: 5),

    // ---- AMERİKA ----
    City(name: 'New York', country: 'ABD', region: 'Amerika', latitude: 40.7128, longitude: -74.0060, timezoneOffset: -5),
    City(name: 'Los Angeles', country: 'ABD', region: 'Amerika', latitude: 34.0522, longitude: -118.2437, timezoneOffset: -8),
    City(name: 'Chicago', country: 'ABD', region: 'Amerika', latitude: 41.8781, longitude: -87.6298, timezoneOffset: -6),
    City(name: 'Houston', country: 'ABD', region: 'Amerika', latitude: 29.7604, longitude: -95.3698, timezoneOffset: -6),
    City(name: 'Toronto', country: 'Kanada', region: 'Amerika', latitude: 43.6532, longitude: -79.3832, timezoneOffset: -5),
    City(name: 'Montreal', country: 'Kanada', region: 'Amerika', latitude: 45.5017, longitude: -73.5673, timezoneOffset: -5),
    City(name: 'Buenos Aires', country: 'Arjantin', region: 'Amerika', latitude: -34.6037, longitude: -58.3816, timezoneOffset: -3),
    City(name: 'São Paulo', country: 'Brezilya', region: 'Amerika', latitude: -23.5505, longitude: -46.6333, timezoneOffset: -3),

    // ---- OKYANUSYA ----
    City(name: 'Sidney', country: 'Avustralya', region: 'Okyanusya', latitude: -33.8688, longitude: 151.2093, timezoneOffset: 10),
    City(name: 'Melbourne', country: 'Avustralya', region: 'Okyanusya', latitude: -37.8136, longitude: 144.9631, timezoneOffset: 10),
  ];

  static List<String> get regions =>
      allCities.map((c) => c.region).toSet().toList();

  static List<City> getCitiesByRegion(String region) =>
      allCities.where((c) => c.region == region).toList();

  static List<City> searchCities(String query) {
    final lowerQuery = query.toLowerCase();
    return allCities
        .where((c) =>
            c.name.toLowerCase().contains(lowerQuery) ||
            c.country.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Returns a recommended calculation method name for a given region
  static String getRecommendedMethod(String region) {
    switch (region) {
      case 'Türkiye':
        return 'turkiye';
      case 'Ortadoğu':
        return 'ummAlQura';
      case 'Avrupa':
        return 'muslimWorldLeague';
      case 'Afrika':
        return 'egyptian';
      case 'Güney Asya':
        return 'karachi';
      case 'Güneydoğu Asya':
        return 'singapore';
      case 'Orta Asya':
        return 'muslimWorldLeague';
      case 'Amerika':
        return 'northAmerica';
      case 'Okyanusya':
        return 'muslimWorldLeague';
      default:
        return 'muslimWorldLeague';
    }
  }
}
