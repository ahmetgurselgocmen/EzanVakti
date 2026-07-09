import 'package:flutter/material.dart';

import '../main.dart';
import 'home_screen.dart';
import 'others_screen.dart';
import 'settings_screen.dart';
import '../widgets/dynamic_background.dart';
import '../services/ad_service.dart';
class MainScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const MainScreen({super.key, this.initialData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Show interstitial ad on app start
    AdService.showInterstitialAd();

    _pages = [
      HomeScreen(initialData: widget.initialData),
      const OthersScreen(),
      const SettingsScreen(),
    ];
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

  @override
  Widget build(BuildContext context) {
    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Ana Sayfa'),
              _buildNavItem(1, Icons.grid_view_rounded, 'Diğerleri'),
              _buildNavItem(2, Icons.settings_rounded, 'Ayarlar'),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final activeColor = const Color(0xFF1E3B2E);
    final inactiveColor = const Color(0xFF9E9E9E);
    final dotColor = const Color(0xFFD4AF37); // Gold

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? dotColor : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
