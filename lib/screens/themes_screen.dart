import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_colors.dart';
import '../widgets/dynamic_background.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isTr = appSettings.languageCode == 'tr';
    
    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isTr ? 'Arayüz Temaları' : 'UI Themes',
            style: TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: AppColors.textColor),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              isTr ? 'Göz Yormayan Arayüz Tasarımları' : 'Eye-friendly UI Designs',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildThemeCard(
              title: isTr ? 'Klasik Arayüz' : 'Classic UI',
              description: isTr ? 'Alışılmış, rahat okunan krem renkli tasarım' : 'Familiar, easy to read cream design',
              index: 0,
              bgGradient: const LinearGradient(
                colors: [Color(0xFFFCF9F2), Color(0xFFF5ECD7)],
              ),
              primaryColor: const Color(0xFFB8860B),
              textColor: const Color(0xFF2C1810),
            ),
            const SizedBox(height: 16),
            _buildThemeCard(
              title: isTr ? 'Modern Arayüz' : 'Modern UI',
              description: isTr ? 'Fütüristik koyu mod ve cam efekti (Glassmorphism)' : 'Futuristic dark mode with glassmorphism',
              index: 1,
              bgGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E1E2C), Color(0xFF191924)],
              ),
              primaryColor: const Color(0xFF4ECDC4),
              textColor: Colors.white,
            ),
            const SizedBox(height: 16),
            _buildThemeCard(
              title: isTr ? 'Minimalist Arayüz' : 'Minimal UI',
              description: isTr ? 'Göz yormayan, son derece sade, çerçevesiz tasarım' : 'Eye-friendly, extremely clean borderless design',
              index: 2,
              bgGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF9F9FB), Color(0xFFF0F0F5)],
              ),
              primaryColor: const Color(0xFF6B8E23),
              textColor: const Color(0xFF333333),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String description,
    required int index,
    required Gradient bgGradient,
    required Color primaryColor,
    required Color textColor,
  }) {
    final isSelected = appSettings.themeIndex == index;
    
    return GestureDetector(
      onTap: () {
        appSettings.setThemeIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 28)
                  : Icon(Icons.dashboard_customize, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
