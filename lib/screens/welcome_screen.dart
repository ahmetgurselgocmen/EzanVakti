import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/cities_data.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import 'package:permission_handler/permission_handler.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 3;

  // Step 2: Language
  String _selectedLanguage = 'tr';

  // Step 3: Calculation method (set to Türkiye default, not shown in onboarding)
  final CalculationMethodType _selectedMethod = CalculationMethodType.turkiye;

  // Step 4: Location
  final TextEditingController _searchController = TextEditingController();
  List<City> _filteredCities = CitiesData.allCities;
  bool _isLoadingGPS = false;
  String _selectedRegion = 'Tümü';
  
  late AnimationController _animationController;

  List<String> get _regions => ['Tümü', ...CitiesData.regions];

  AppLocalizations get l10n => AppLocalizations(_selectedLanguage);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
    _requestMandatoryPermissions();
  }

  Future<void> _requestMandatoryPermissions() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', _selectedLanguage);
    await prefs.setString('method', _selectedMethod.name);
    appSettings.setLanguage(_selectedLanguage);
  }

  void _filterCities(String query) {
    setState(() {
      if (query.isEmpty && _selectedRegion == 'Tümü') {
        _filteredCities = CitiesData.allCities;
      } else if (query.isEmpty) {
        _filteredCities = CitiesData.getCitiesByRegion(_selectedRegion);
      } else {
        _filteredCities = CitiesData.searchCities(query);
        if (_selectedRegion != 'Tümü') {
          _filteredCities = _filteredCities
              .where((c) => c.region == _selectedRegion)
              .toList();
        }
      }
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _selectRegion(String region) {
    setState(() {
      _selectedRegion = region;
    });
    _filterCities(_searchController.text);
  }

  void _selectCity(City city) async {
    await _savePreferences();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cityName', city.name);
    await prefs.setString('countryName', city.country);
    await prefs.setDouble('latitude', city.latitude);
    await prefs.setDouble('longitude', city.longitude);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        'cityName': city.name,
        'countryName': city.country,
        'latitude': city.latitude,
        'longitude': city.longitude,
        'isFirstLaunch': true,
      },
    );
  }

  Future<void> _useGPS() async {
    setState(() => _isLoadingGPS = true);

    final result = await LocationService.getCurrentLocation();

    setState(() => _isLoadingGPS = false);

    if (!mounted) return;

    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    double finalLat = result.latitude;
    double finalLng = result.longitude;
    String finalCityName = result.cityName ?? 'Konumum';

    if (result.cityName != null) {
      // Try to match the city from GPS to our CitiesData database for exact official coordinates
      final normalizedResultCity = result.cityName!.toLowerCase().replaceAll('ı', 'i').replaceAll('ş', 's').replaceAll('ğ', 'g').replaceAll('ü', 'u').replaceAll('ö', 'o').replaceAll('ç', 'c');
      final match = CitiesData.allCities.where((c) {
        final normalizedC = c.name.toLowerCase().replaceAll('ı', 'i').replaceAll('ş', 's').replaceAll('ğ', 'g').replaceAll('ü', 'u').replaceAll('ö', 'o').replaceAll('ç', 'c');
        return normalizedC == normalizedResultCity || c.name.toLowerCase() == result.cityName!.toLowerCase();
      });
      if (match.isNotEmpty) {
        finalLat = match.first.latitude;
        finalLng = match.first.longitude;
        finalCityName = match.first.name;
      }
    }

    await _savePreferences();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cityName', finalCityName);
    await prefs.setString('countryName', result.country ?? '');
    await prefs.setString('districtName', result.district ?? '');
    await prefs.setDouble('latitude', finalLat);
    await prefs.setDouble('longitude', finalLng);
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {
        'cityName': finalCityName,
        'countryName': result.country ?? '',
        'latitude': finalLat,
        'longitude': finalLng,
        'isFirstLaunch': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Step indicator
              _buildStepIndicator(),
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentStep = page);
                    if (page == 2) {
                      _animationController.reset();
                      _animationController.forward();
                    }
                  },
                  children: [
                    _buildWelcomePage(),
                    _buildLanguagePage(),
                    _buildLocationPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryColor
                    : AppColors.textColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ======== STEP 1: Welcome ========
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Logo
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.borderColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text('🕌', style: TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.t('onboardingWelcome'),
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'EZAN VAKTİ',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('onboardingWelcomeDesc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textColor.withValues(alpha: 0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const Spacer(flex: 3),
          _buildNextButton(l10n.t('onboardingNext')),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ======== STEP 2: Language ========
  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.language_rounded, color: AppColors.primaryColor, size: 48),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.t('onboardingLanguage'),
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.t('onboardingLanguageDesc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textColor.withValues(alpha: 0.6),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 48),
          // Language options
          _buildLanguageOption('tr', 'Türkçe', '🇹🇷'),
          const SizedBox(height: 16),
          _buildLanguageOption('en', 'English', '🇬🇧'),
          const Spacer(),
          _buildNavigationButtons(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    final isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.2)
                  : AppColors.cardColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.borderColor.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? AppColors.textColor : AppColors.textColor.withValues(alpha: 0.8),
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: AppColors.primaryColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======== STEP 3: Location ========
  Widget _buildLocationPage() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: AppColors.primaryColor, size: 48),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.t('onboardingLocation'),
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.t('onboardingLocationDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textColor.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildGPSButton(),
        ),
        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSearchBar(),
        ),
        const SizedBox(height: 16),
        _buildRegionFilter(),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCityList(),
          ),
        ),
        // Back button at bottom
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 20, left: 24, right: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _prevPage,
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textColor.withValues(alpha: 0.7)),
              label: Text(
                l10n.t('onboardingBack'),
                style: TextStyle(color: AppColors.textColor.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.textColor.withValues(alpha: 0.0),
                    AppColors.textColor.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.t('orSelectCity'),
              style: TextStyle(
                color: AppColors.textColor.withValues(alpha: 0.5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.textColor.withValues(alpha: 0.2),
                    AppColors.textColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======== Shared Widgets ========
  Widget _buildNextButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _nextPage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastBeforeLocation = _currentStep == 1;
    return Row(
      children: [
        TextButton.icon(
          onPressed: _prevPage,
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textColor.withValues(alpha: 0.7)),
          label: Text(
            l10n.t('onboardingBack'),
            style: TextStyle(color: AppColors.textColor.withValues(alpha: 0.7), fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _nextPage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                isLastBeforeLocation ? l10n.t('onboardingNext') : l10n.t('onboardingNext'),
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGPSButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.7)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoadingGPS ? null : _useGPS,
          borderRadius: BorderRadius.circular(20),
          highlightColor: Colors.white.withValues(alpha: 0.2),
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoadingGPS)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.background,
                    ),
                  )
                else
                  Icon(Icons.my_location, color: AppColors.background, size: 24),
                const SizedBox(width: 16),
                Text(
                  _isLoadingGPS
                      ? l10n.t('gpsLocating')
                      : l10n.t('gpsLocate'),
                  style: TextStyle(
                    color: AppColors.background,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.3)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterCities,
            style: TextStyle(color: AppColors.textColor, fontSize: 16),
            decoration: InputDecoration(
              hintText: l10n.t('searchCityCountry'),
              hintStyle: TextStyle(color: AppColors.textColor.withValues(alpha: 0.3)),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primaryColor.withValues(alpha: 0.8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textColor.withValues(alpha: 0.4), size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _filterCities('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegionFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _regions.length,
        itemBuilder: (context, index) {
          final region = _regions[index];
          final isSelected = region == _selectedRegion;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: GestureDetector(
                onTap: () => _selectRegion(region),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : AppColors.cardColor.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : AppColors.borderColor.withValues(alpha: 0.2),
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        region,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textColor.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCityList() {
    if (_filteredCities.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_rounded, size: 64, color: AppColors.textColor.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              l10n.t('cityNotFound'),
              style: TextStyle(color: AppColors.textColor.withValues(alpha: 0.5), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: _filteredCities.length,
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        final animationInterval = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            (index / _filteredCities.length).clamp(0.0, 1.0),
            ((index + 1) / _filteredCities.length).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        );

        return AnimatedBuilder(
          animation: animationInterval,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - animationInterval.value)),
              child: Opacity(
                opacity: animationInterval.value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Material(
                  color: AppColors.cardColor.withValues(alpha: 0.4),
                  child: InkWell(
                    onTap: () => _selectCity(city),
                    highlightColor: AppColors.primaryColor.withValues(alpha: 0.1),
                    splashColor: AppColors.primaryColor.withValues(alpha: 0.1),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.location_city_rounded,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city.name,
                                  style: TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  city.country,
                                  style: TextStyle(
                                    color: AppColors.textColor.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textColor.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
