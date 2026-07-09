import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../widgets/dynamic_background.dart';

/// Zikir (dhikr) presets the user can choose from
class ZikirPreset {
  final String arabicText;
  final String latinText;
  final String turkishName;
  final String englishName;
  final int target; // Still kept for menu UI, but not used for count

  const ZikirPreset({
    required this.arabicText,
    required this.latinText,
    required this.turkishName,
    required this.englishName,
    this.target = 33,
  });
}

const _zikirPresets = [
  ZikirPreset(
    arabicText: 'سُبْحَانَ اللَّهِ',
    latinText: 'Sübhanallah',
    turkishName: 'Sübhanallah',
    englishName: 'SubhanAllah',
    target: 33,
  ),
  ZikirPreset(
    arabicText: 'الْحَمْدُ لِلَّهِ',
    latinText: 'Elhamdülillah',
    turkishName: 'Elhamdülillah',
    englishName: 'Alhamdulillah',
    target: 33,
  ),
  ZikirPreset(
    arabicText: 'اللَّهُ أَكْبَرُ',
    latinText: 'Allahu Ekber',
    turkishName: 'Allahu Ekber',
    englishName: 'Allahu Akbar',
    target: 33,
  ),
  ZikirPreset(
    arabicText: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
    latinText: 'Allahümme salli alâ seyyidinâ Muhammed',
    turkishName: 'Salavat',
    englishName: 'Salawat',
    target: 33,
  ),
  ZikirPreset(
    arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
    latinText: 'Lâ ilâhe illallah',
    turkishName: 'Kelime-i Tevhid',
    englishName: 'Kalima Tawhid',
    target: 99,
  ),
  ZikirPreset(
    arabicText: 'أَسْتَغْفِرُ اللَّهَ',
    latinText: 'Estağfirullah',
    turkishName: 'Estağfirullah',
    englishName: 'Astaghfirullah',
    target: 33,
  ),
];

class ZikirmatikScreen extends StatefulWidget {
  const ZikirmatikScreen({super.key});

  @override
  State<ZikirmatikScreen> createState() => _ZikirmatikScreenState();
}

class _ZikirmatikScreenState extends State<ZikirmatikScreen>
    with TickerProviderStateMixin {
  int _totalCount = 0;
  int _selectedPresetIndex = 0;
  static const String _totalKey = 'zikirmatik_total';
  static const String _presetKey = 'zikirmatik_preset';

  // Colors based on AppColors
  static const _pageColor = Color(0xFFF5ECD7);
  static Color get _inkColor => AppColors.textColor;
  static Color get _goldColor => AppColors.primaryColor;
  static Color get _borderColor => AppColors.borderColor;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  ZikirPreset get _currentPreset => _zikirPresets[_selectedPresetIndex];

  // FocusNode to intercept key events
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadData();
    appSettings.addListener(_onSettingsChanged);

    HardwareKeyboard.instance.addHandler(_handleKeyEvent);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _focusNode.dispose();
    _pulseController.dispose();
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp ||
          event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
        _increment();
        return true;
      }
    }
    return false;
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPresetIndex = prefs.getInt(_presetKey) ?? 0;
      _totalCount = prefs.getInt(_totalKey) ?? 0;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalKey, _totalCount);
    await prefs.setInt(_presetKey, _selectedPresetIndex);
  }

  void _increment() {
    setState(() {
      _totalCount++;
    });
    _saveData();

    // Haptic feedback
    if (_totalCount % 33 == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    _pulseController.forward().then((_) => _pulseController.reverse());
  }

  void _reset() {
    final isTr = appSettings.languageCode == 'tr';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          appSettings.l10n.t('reset'),
          style: TextStyle(color: _inkColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          isTr
              ? 'Toplam sayacı sıfırlamak istediğinize emin misiniz?'
              : 'Are you sure you want to reset the total counter?',
          style: TextStyle(color: _inkColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isTr ? 'İptal' : 'Cancel',
              style: TextStyle(color: _inkColor.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _totalCount = 0;
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text(
              'Sıfırla',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPresetPicker() {
    final isTr = appSettings.languageCode == 'tr';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    isTr ? 'Zikir Seçin' : 'Select Dhikr',
                    style: TextStyle(
                      color: _goldColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(_zikirPresets.length, (index) {
                  final preset = _zikirPresets[index];
                  final isSelected = index == _selectedPresetIndex;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? _goldColor.withValues(alpha: 0.2)
                            : _borderColor.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Text(
                          '${preset.target}',
                          style: TextStyle(
                            color: isSelected ? _goldColor : _inkColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      isTr ? preset.turkishName : preset.englishName,
                      style: TextStyle(
                        color: isSelected ? _goldColor : _inkColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      preset.latinText,
                      style: TextStyle(
                        color: _inkColor.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: _goldColor, size: 20)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedPresetIndex = index;
                      });
                      _saveData();
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTr = appSettings.languageCode == 'tr';

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.audioVolumeUp ||
              event.logicalKey == LogicalKeyboardKey.audioVolumeDown) {
            _increment();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: DynamicBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(isTr),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Column(
                        children: [
                          _buildDuaHeader(),
                          Expanded(
                            child: Center(
                              child: _buildCircularCounter(),
                            ),
                          ),
                          _buildBottomHint(isTr),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isTr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [

          Expanded(
            child: Text(
              appSettings.l10n.t('zikirmatikTitle'),
              style: TextStyle(
                color: _goldColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _showPresetPicker,
              icon: Icon(Icons.menu_book_rounded, color: _goldColor, size: 22),
              tooltip: isTr ? 'Zikir Seçin' : 'Select Dhikr',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _reset,
              icon: Icon(Icons.refresh_rounded, color: _goldColor, size: 22),
              tooltip: appSettings.l10n.t('reset'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            _currentPreset.arabicText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _goldColor,
              fontSize: 28,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 50, height: 1, color: _goldColor.withValues(alpha: 0.3)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.star_border_rounded, color: _goldColor.withValues(alpha: 0.5), size: 14),
              ),
              Container(width: 50, height: 1, color: _goldColor.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentPreset.latinText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _inkColor.withValues(alpha: 0.8),
              fontSize: 15,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularCounter() {
    return GestureDetector(
      onTap: _increment,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _pageColor,
            boxShadow: [
              // Outer light shadow
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.6),
                blurRadius: 16,
                offset: const Offset(-6, -6),
              ),
              // Outer dark shadow
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Static ring (since no target is used, we just show a permanent full ring for aesthetics)
              SizedBox(
                width: 210,
                height: 210,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4,
                  backgroundColor: _borderColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(_goldColor.withValues(alpha: 0.5)),
                ),
              ),
              // Inner glowing gradient circle
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _pageColor,
                      _pageColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _goldColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Count Text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_totalCount',
                    style: TextStyle(
                      color: _inkColor,
                      fontSize: 64,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'Toplam',
                    style: TextStyle(
                      color: _goldColor.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomHint(bool isTr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: _pageColor.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: _borderColor.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_rounded, color: _inkColor.withValues(alpha: 0.4), size: 16),
          const SizedBox(width: 8),
          Text(
            isTr ? 'Dokunun veya ses tuşunu kullanın' : 'Tap or use volume keys',
            style: TextStyle(
              color: _inkColor.withValues(alpha: 0.5),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
