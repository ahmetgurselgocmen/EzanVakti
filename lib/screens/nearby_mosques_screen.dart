import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/dynamic_background.dart';
import '../theme/app_colors.dart';
import '../services/ad_service.dart';
import '../main.dart';

class NearbyMosque {
  final String name;
  final double lat;
  final double lon;
  final double? distanceKm;

  const NearbyMosque({
    required this.name,
    required this.lat,
    required this.lon,
    this.distanceKm,
  });
}

class NearbyMosquesScreen extends StatefulWidget {
  const NearbyMosquesScreen({super.key});

  @override
  State<NearbyMosquesScreen> createState() => _NearbyMosquesScreenState();
}

class _NearbyMosquesScreenState extends State<NearbyMosquesScreen> {
  List<NearbyMosque> _mosques = [];
  bool _isLoading = true;
  String? _errorMessage;
  double? _userLat;
  double? _userLng;
  static Color get _textColor => AppColors.textColor;
  static Color get _goldColor => AppColors.primaryColor;

  @override
  void initState() {
    super.initState();
    appSettings.addListener(_onSettingsChanged);
    _fetchNearbyMosques();
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  bool get _isTr => appSettings.languageCode == 'tr';

  Future<void> _fetchNearbyMosques() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Get location permission & position
      final permission = await Geolocator.checkPermission();
      LocationPermission finalPermission = permission;
      if (permission == LocationPermission.denied) {
        finalPermission = await Geolocator.requestPermission();
      }
      if (finalPermission == LocationPermission.denied ||
          finalPermission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = _isTr
              ? 'Yakındaki camileri görmek için konum iznine ihtiyaç vardır.'
              : 'Location permission is required to find nearby mosques.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _userLat = position.latitude;
      _userLng = position.longitude;

      // 2. Query Overpass API (free OpenStreetMap data)
      // Using GET with encoded query for better compatibility
      const radius = 3000; // 3 km
      final query =
          '''
[out:json][timeout:25];
(
  node["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,${position.latitude},${position.longitude});
  way["amenity"="place_of_worship"]["religion"="muslim"](around:$radius,${position.latitude},${position.longitude});
);
out center 30;
''';

      // Try primary mirror, fall back to alternative
      http.Response? response;
      for (final baseUrl in [
        'https://lz4.overpass-api.de/api/interpreter', // Fast mirror 1
        'https://z.overpass-api.de/api/interpreter', // Fast mirror 2
        'https://overpass-api.de/api/interpreter', // Main mirror (sometimes 504)
        'https://overpass.osm.ch/api/interpreter', // Swiss mirror
        'https://overpass.kumi.systems/api/interpreter',
      ]) {
        try {
          response = await http
              .post(
                Uri.parse(baseUrl),
                headers: {'User-Agent': 'EzanVaktiApp/1.0 (Flutter)'},
                body: query,
              )
              .timeout(const Duration(seconds: 20));
          if (response.statusCode == 200) break;
        } catch (_) {
          continue;
        }
      }

      if (response == null || response.statusCode != 200) {
        throw Exception('API error ${response?.statusCode ?? "unreachable"}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final elements = (data['elements'] as List?) ?? [];

      final mosques = <NearbyMosque>[];
      for (final el in elements) {
        final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
        final name =
            tags['name'] ??
            tags['name:tr'] ??
            tags['name:en'] ??
            (_isTr ? 'İsimsiz Cami' : 'Unnamed Mosque');

        double lat;
        double lon;
        if (el['type'] == 'way') {
          lat = (el['center']['lat'] as num).toDouble();
          lon = (el['center']['lon'] as num).toDouble();
        } else {
          lat = (el['lat'] as num).toDouble();
          lon = (el['lon'] as num).toDouble();
        }

        final distanceM = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat,
          lon,
        );

        mosques.add(
          NearbyMosque(
            name: name,
            lat: lat,
            lon: lon,
            distanceKm: distanceM / 1000,
          ),
        );
      }

      // Sort by distance
      mosques.sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

      if (!mounted) return;
      setState(() {
        _mosques = mosques;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _isTr
            ? 'Camiler yüklenemedi. İnternet bağlantınızı kontrol edin.'
            : 'Could not load mosques. Check your internet connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

                    Expanded(
                      child: Text(
                        _isTr ? 'Yakındaki Camiler' : 'Nearby Mosques',
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _fetchNearbyMosques,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: _goldColor,
                        size: 22,
                      ),
                      tooltip: _isTr ? 'Yenile' : 'Refresh',
                    ),
                  ],
                ),
              ),

              // Subtitle
              if (!_isLoading && _errorMessage == null && _userLat != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _isTr
                        ? '${_mosques.length} cami bulundu · 3 km içinde'
                        : '${_mosques.length} mosques found · within 3 km',
                    style: TextStyle(
                      color: _textColor.withValues(alpha: 0.55),
                      fontSize: 13,
                    ),
                  ),
                ),

              SizedBox(height: 12),

              // Content
              Expanded(child: _buildContent()),

              // Ad
              const CustomBannerAd(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _goldColor),
            SizedBox(height: 16),
            Text(
              _isTr ? 'Camiler aranıyor...' : 'Searching mosques...',
              style: TextStyle(
                color: _textColor.withValues(alpha: 0.6),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_outlined,
                color: _goldColor.withValues(alpha: 0.6),
                size: 56,
              ),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _textColor.withValues(alpha: 0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _fetchNearbyMosques,
                icon: Icon(Icons.refresh),
                label: Text(_isTr ? 'Tekrar Dene' : 'Try Again'),
                style: FilledButton.styleFrom(
                  backgroundColor: _goldColor,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () async => await Geolocator.openAppSettings(),
                child: Text(
                  _isTr ? 'Uygulama Ayarlarını Aç' : 'Open App Settings',
                  style: TextStyle(color: _goldColor),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_mosques.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mosque_outlined,
              color: _goldColor.withValues(alpha: 0.4),
              size: 64,
            ),
            SizedBox(height: 16),
            Text(
              _isTr
                  ? '3 km içinde cami bulunamadı.'
                  : 'No mosques found within 3 km.',
              style: TextStyle(
                color: _textColor.withValues(alpha: 0.6),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    final markers = <Marker>{};
    for (var i = 0; i < _mosques.length; i++) {
      final m = _mosques[i];
      markers.add(
        Marker(
          markerId: MarkerId('mosque_$i'),
          position: LatLng(m.lat, m.lon),
          infoWindow: InfoWindow(
            title: m.name,
            snippet: m.distanceKm != null
                ? '${m.distanceKm!.toStringAsFixed(2)} km'
                : '',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    // Add user marker
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(_userLat!, _userLng!),
        infoWindow: InfoWindow(title: _isTr ? 'Konumunuz' : 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_userLat!, _userLng!),
          zoom: 13.5,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }
}
