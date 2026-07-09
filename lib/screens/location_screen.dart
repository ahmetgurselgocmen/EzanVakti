import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/cities_data.dart';
import '../services/location_service.dart';
import '../main.dart';
import '../widgets/dynamic_background.dart';
import '../theme/app_colors.dart';

class LocationScreen extends StatefulWidget {
  final double currentLatitude;
  final double currentLongitude;

  const LocationScreen({
    super.key,
    required this.currentLatitude,
    required this.currentLongitude,
  });

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<City> _filteredCities = CitiesData.allCities;
  bool _isLoadingGPS = false;
  String _selectedRegion = 'Tümü';
  late AnimationController _animationController;

  List<String> get _regions => ['Tümü', ...CitiesData.regions];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
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

  void _selectCity(City city) {
    Navigator.pop(context, {
      'cityName': city.name,
      'countryName': city.country,
      'latitude': city.latitude,
      'longitude': city.longitude,
    });
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

    Navigator.pop(context, {
      'cityName': finalCityName,
      'countryName': result.country ?? '',
      'district': result.district ?? '',
      'latitude': finalLat,
      'longitude': finalLng,
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    _buildGPSButton(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _RegionHeaderDelegate(
                child: _buildRegionFilter(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            _buildCityList(),
            const SliverToBoxAdapter(child: SizedBox(height: 32)), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      title: Text(
        appSettings.languageCode == 'tr' ? 'Konum Seçin' : 'Select Location',
        style: TextStyle(
          color: AppColors.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      pinned: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: AppColors.background.withValues(alpha: 0.3),
          ),
        ),
      ),
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
                      color: AppColors.cardColor,
                    ),
                  )
                else
                  Icon(Icons.my_location, color: AppColors.cardColor, size: 24),
                const SizedBox(width: 16),
                Text(
                  _isLoadingGPS
                      ? (appSettings.languageCode == 'tr' ? 'Konum Alınıyor...' : 'Locating...')
                      : (appSettings.languageCode == 'tr' ? 'Otomatik Konum Bul' : 'Auto Detect Location'),
                  style: TextStyle(
                    color: AppColors.cardColor,
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

  Widget _buildDivider() {
    return Row(
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
            appSettings.languageCode == 'tr' ? 'veya şehir ara' : 'or search city',
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
              hintText: appSettings.languageCode == 'tr' ? 'Örn: İstanbul, Ankara...' : 'e.g. Istanbul, Ankara...',
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
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          color: AppColors.background.withValues(alpha: 0.5),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _regions.length,
            itemBuilder: (context, index) {
              final region = _regions[index];
              final isSelected = region == _selectedRegion;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: GestureDetector(
                    onTap: () => _selectRegion(region),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCityList() {
    if (_filteredCities.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_off_rounded, size: 64, color: AppColors.textColor.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text(
                appSettings.languageCode == 'tr' ? 'Şehir bulunamadı' : 'City not found',
                style: TextStyle(color: AppColors.textColor.withValues(alpha: 0.5), fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          childCount: _filteredCities.length,
        ),
      ),
    );
  }
}

class _RegionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _RegionHeaderDelegate({required this.child});

  @override
  double get minExtent => 50.0;

  @override
  double get maxExtent => 50.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
