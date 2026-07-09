import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../main.dart';
import '../services/ad_service.dart';

/// Represents a Quran radio station
class RadioStation {
  final String name;
  final String url;
  final String icon;
  final String description;
  final String country;

  const RadioStation({
    required this.name,
    required this.url,
    required this.icon,
    required this.description,
    required this.country,
  });
}

const _radioStations = [
  RadioStation(
    name: 'Makkah Quran Radio',
    url: 'https://backup.qurango.net/radio/tarateel',
    icon: '🕋',
    description: 'Mescid-i Haram',
    country: 'Suudi Arabistan',
  ),
  RadioStation(
    name: 'Madinah Quran Radio',
    url: 'https://backup.qurango.net/radio/madinah',
    icon: '🕌',
    description: 'Mescid-i Nebevi',
    country: 'Suudi Arabistan',
  ),
  RadioStation(
    name: 'Tarteel',
    url: 'https://backup.qurango.net/radio/tarteel',
    icon: '📖',
    description: 'Ağır okuyuş',
    country: 'Global',
  ),
  RadioStation(
    name: 'Türkçe Meal',
    url: 'https://backup.qurango.net/radio/translation_quran_turkish',
    icon: '🇹🇷',
    description: 'Türkçe mealli okuyuş',
    country: 'Türkiye',
  ),
  RadioStation(
    name: 'Mishary Rashid al-Afasy',
    url: 'https://backup.qurango.net/radio/mishari_alafasi',
    icon: '🎙️',
    description: 'Kuveytli hafız',
    country: 'Kuveyt',
  ),
  RadioStation(
    name: 'Abdul Basit Abdus Samad',
    url: 'https://backup.qurango.net/radio/abd_elbasset',
    icon: '🎙️',
    description: 'Efsanevi okuyucu',
    country: 'Mısır',
  ),
  RadioStation(
    name: 'Abdurrahman al-Sudais',
    url: 'https://backup.qurango.net/radio/sudais',
    icon: '🎙️',
    description: 'Harem İmamı',
    country: 'Suudi Arabistan',
  ),
  RadioStation(
    name: 'Saud al-Shuraim',
    url: 'https://backup.qurango.net/radio/saud_alshuraim',
    icon: '🎙️',
    description: 'Harem İmamı',
    country: 'Suudi Arabistan',
  ),
  RadioStation(
    name: 'Maher al-Muaiqly',
    url: 'https://backup.qurango.net/radio/maher',
    icon: '🎙️',
    description: 'Harem İmamı',
    country: 'Suudi Arabistan',
  ),
  RadioStation(
    name: 'Saad al-Ghamdi',
    url: 'https://backup.qurango.net/radio/sa3d_alghamdi',
    icon: '🎙️',
    description: 'Hatim radyosu',
    country: 'Suudi Arabistan',
  ),
  RadioStation(
    name: 'Ahmed al-Ajmi',
    url: 'https://backup.qurango.net/radio/ahmad_elajmy',
    icon: '🎙️',
    description: 'Kuveytli okuyucu',
    country: 'Kuveyt',
  ),
  RadioStation(
    name: 'Yasser al-Dosari',
    url: 'https://backup.qurango.net/radio/yasser_aldosari',
    icon: '🎙️',
    description: 'Suudi okuyucu',
    country: 'Suudi Arabistan',
  ),
];

class QuranRadioScreen extends StatefulWidget {
  const QuranRadioScreen({super.key});

  @override
  State<QuranRadioScreen> createState() => _QuranRadioScreenState();
}

class _QuranRadioScreenState extends State<QuranRadioScreen>
    with TickerProviderStateMixin {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  int _currentStationIndex = 0;
  double _volume = 0.8;

  late final AnimationController _discController;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;
  late final AnimationController _freqAnimController;

  // Frequency dial
  double _freqDialValue = 0.0; // 0.0 to 1.0 mapped to stations

  RadioStation get _currentStation => _radioStations[_currentStationIndex];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _discController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _freqAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _freqDialValue = 0.0;

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (_isPlaying) {
            _isLoading = false;
            _discController.repeat();
            _glowController.repeat(reverse: true);
          } else {
            _discController.stop();
            _glowController.stop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _discController.dispose();
    _glowController.dispose();
    _freqAnimController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playStation(int index) async {
    setState(() {
      _currentStationIndex = index;
      _isLoading = true;
      _freqDialValue = index / (_radioStations.length - 1);
    });
    await _audioPlayer.stop();
    await _audioPlayer.setVolume(_volume);
    await _audioPlayer.play(UrlSource(_radioStations[index].url));
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      setState(() => _isLoading = true);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(UrlSource(_currentStation.url));
    }
  }

  void _previousStation() {
    final newIndex = (_currentStationIndex - 1 + _radioStations.length) %
        _radioStations.length;
    _playStation(newIndex);
  }

  void _nextStation() {
    final newIndex = (_currentStationIndex + 1) % _radioStations.length;
    _playStation(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isTr = appSettings.languageCode == 'tr';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isTr),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildRadioDisplay(),
                    const SizedBox(height: 20),
                    _buildFrequencyDial(),
                    const SizedBox(height: 20),
                    _buildControls(),
                    const SizedBox(height: 20),
                    _buildVolumeControl(isTr),
                    const SizedBox(height: 24),
                    _buildStationList(isTr),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            const CustomBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isTr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [

          Expanded(
            child: Text(
              isTr ? "Kur'an Radyo" : "Quran Radio",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          // Live indicator
          if (_isPlaying)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'CANLI',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadioDisplay() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowOpacity = _isPlaying ? _glowAnimation.value * 0.4 : 0.0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isPlaying
                  ? AppColors.primaryColor.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: glowOpacity),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Spinning disc
              RotationTransition(
                turns: _discController,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF2D2D2D),
                        const Color(0xFF1A1A1A),
                        const Color(0xFF2D2D2D),
                        const Color(0xFF1A1A1A),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withValues(alpha: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mosque_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Station info
              Text(
                _currentStation.icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStation.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_currentStation.description}  •  ${_currentStation.country}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              // Audio visualizer bars when playing
              if (_isPlaying) ...[
                const SizedBox(height: 16),
                _buildVisualizer(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisualizer() {
    return SizedBox(
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (index) {
          return _VisualizerBar(
            index: index,
            isPlaying: _isPlaying,
          );
        }),
      ),
    );
  }

  Widget _buildFrequencyDial() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // Frequency display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FM',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'CH ${_currentStationIndex + 1}/${_radioStations.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Frequency slider with tick marks
          SizedBox(
            height: 50,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final newVal =
                        (details.localPosition.dx / width).clamp(0.0, 1.0);
                    final stationIndex =
                        (newVal * (_radioStations.length - 1)).round();
                    if (stationIndex != _currentStationIndex) {
                      _playStation(stationIndex);
                    }
                  },
                  child: CustomPaint(
                    size: Size(width, 50),
                    painter: _FreqDialPainter(
                      value: _freqDialValue,
                      stationCount: _radioStations.length,
                      activeColor: AppColors.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        _buildControlButton(
          icon: Icons.skip_previous_rounded,
          size: 32,
          onTap: _previousStation,
        ),
        const SizedBox(width: 24),
        // Play/Pause
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
          ),
        ),
        const SizedBox(width: 24),
        // Next
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          size: 32,
          onTap: _nextStation,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: Colors.white70, size: size),
      ),
    );
  }

  Widget _buildVolumeControl(bool isTr) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Icon(Icons.volume_down, color: Colors.white.withValues(alpha: 0.5), size: 20),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primaryColor,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                thumbColor: AppColors.primaryColor,
                overlayColor: AppColors.primaryColor.withValues(alpha: 0.2),
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: _volume,
                onChanged: (val) {
                  setState(() => _volume = val);
                  _audioPlayer.setVolume(val);
                },
              ),
            ),
          ),
          Icon(Icons.volume_up, color: Colors.white.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }

  Widget _buildStationList(bool isTr) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(Icons.cell_tower, color: AppColors.primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  isTr ? 'İstasyonlar' : 'Stations',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_radioStations.length} ${isTr ? "kanal" : "channels"}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          ...List.generate(_radioStations.length, (index) {
            final station = _radioStations[index];
            final isActive = index == _currentStationIndex;
            final isLast = index == _radioStations.length - 1;

            return Column(
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? AppColors.primaryColor.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Center(
                      child: Text(station.icon, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  title: Text(
                    station.name,
                    style: TextStyle(
                      color: isActive ? AppColors.primaryColor : Colors.white,
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${station.description}  •  ${station.country}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                  trailing: isActive && _isPlaying
                      ? _buildMiniEqualizer()
                      : Icon(
                          Icons.play_circle_outline,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 24,
                        ),
                  onTap: () => _playStation(index),
                ),
                if (!isLast)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    height: 1,
                    indent: 72,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniEqualizer() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (index) {
          return _EqualizerBar(
            index: index,
            isPlaying: _isPlaying,
          );
        }),
      ),
    );
  }
}

/// Animated visualizer bar
class _VisualizerBar extends StatefulWidget {
  final int index;
  final bool isPlaying;

  const _VisualizerBar({required this.index, required this.isPlaying});

  @override
  State<_VisualizerBar> createState() => _VisualizerBarState();
}

class _VisualizerBarState extends State<_VisualizerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + _random.nextInt(400)),
    );
    _animation = Tween<double>(
      begin: 0.15,
      end: 0.3 + _random.nextDouble() * 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _VisualizerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 3,
          height: 30 * _animation.value,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.5),
            color: AppColors.primaryColor.withValues(
              alpha: 0.3 + _animation.value * 0.5,
            ),
          ),
        );
      },
    );
  }
}

/// Equalizer bar for station list
class _EqualizerBar extends StatefulWidget {
  final int index;
  final bool isPlaying;

  const _EqualizerBar({required this.index, required this.isPlaying});

  @override
  State<_EqualizerBar> createState() => _EqualizerBarState();
}

class _EqualizerBarState extends State<_EqualizerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250 + _random.nextInt(300)),
    );
    _animation = Tween<double>(begin: 0.2, end: 0.5 + _random.nextDouble() * 0.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _EqualizerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 4,
          height: 24 * _animation.value,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: AppColors.primaryColor,
          ),
        );
      },
    );
  }
}

/// Frequency dial painter
class _FreqDialPainter extends CustomPainter {
  final double value;
  final int stationCount;
  final Color activeColor;

  _FreqDialPainter({
    required this.value,
    required this.stationCount,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    final activeTickPaint = Paint()
      ..color = activeColor
      ..strokeWidth = 2;

    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.3),
      fontSize: 8,
    );

    // Draw tick marks for each station
    for (int i = 0; i < stationCount; i++) {
      final x = (i / (stationCount - 1)) * size.width;
      final isActive = (value * (stationCount - 1)).round() == i;
      final isMajor = i % 3 == 0;
      final tickHeight = isMajor ? 20.0 : 12.0;

      canvas.drawLine(
        Offset(x, size.height - tickHeight),
        Offset(x, size.height),
        isActive ? activeTickPaint : tickPaint,
      );

      // Station number label for major ticks
      if (isMajor) {
        final textSpan = TextSpan(
          text: '${i + 1}',
          style: isActive
              ? labelStyle.copyWith(color: activeColor, fontWeight: FontWeight.bold)
              : labelStyle,
        );
        final tp = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - tickHeight - 14));
      }
    }

    // Draw minor ticks between stations
    final minorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 0.5;
    for (int i = 0; i < (stationCount - 1) * 4; i++) {
      final x = (i / ((stationCount - 1) * 4)) * size.width;
      canvas.drawLine(
        Offset(x, size.height - 6),
        Offset(x, size.height),
        minorPaint,
      );
    }

    // Indicator needle
    final needleX = value * size.width;
    final needlePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(needleX, 0),
      Offset(needleX, size.height),
      needlePaint,
    );

    // Needle triangle at top
    final trianglePath = Path()
      ..moveTo(needleX - 5, 0)
      ..lineTo(needleX + 5, 0)
      ..lineTo(needleX, 8)
      ..close();
    canvas.drawPath(trianglePath, Paint()..color = activeColor);
  }

  @override
  bool shouldRepaint(covariant _FreqDialPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
