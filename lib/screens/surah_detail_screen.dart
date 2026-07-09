import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../main.dart';
import '../widgets/dynamic_background.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _versesPerPage = 5;

  // Book-style color palette
  static const _pageColor = Color(0xFFF5ECD7);
  static const _pageDarkColor = Color(0xFFEDE1C8);
  static const _inkColor = Color(0xFF2C1810);
  static const _goldColor = Color(0xFFB8860B);
  static const _borderColor = Color(0xFFC9B88B);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  int get _totalPages {
    final verseCount = quran.getVerseCount(widget.surahNumber);
    return (verseCount / _versesPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicBackground(
      forceClassic: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar (leather-style)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3E2723),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [

                  Expanded(
                    child: Text(
                      quran.getSurahNameTurkish(widget.surahNumber),
                      style: const TextStyle(
                        color: Color(0xFFD4A843),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // Page indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A843).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD4A843).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${_currentPage + 1} / $_totalPages',
                      style: const TextStyle(
                        color: Color(0xFFD4A843),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            // Book page with page-turn swipe
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                decoration: BoxDecoration(
                  color: _pageColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  border: Border.all(color: _borderColor, width: 1.5),
                  boxShadow: [
                    // Book spine shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(-3, 0),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(3, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _totalPages,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    itemBuilder: (context, pageIndex) {
                      return _buildPage(pageIndex);
                    },
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int pageIndex) {
    final verseCount = quran.getVerseCount(widget.surahNumber);
    final startVerse = pageIndex * _versesPerPage + 1;
    final endVerse = (startVerse + _versesPerPage - 1).clamp(1, verseCount);

    return Container(
      color: _pageColor,
      child: Stack(
        children: [
          // Subtle page texture — diagonal lines
          Positioned.fill(
            child: CustomPaint(
              painter: _PageTexturePainter(),
            ),
          ),
          // Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: [
                // Basmala on first page
                if (pageIndex == 0) _buildBasmalaHeader(),
                // Verses
                for (int v = startVerse; v <= endVerse; v++) _buildVerse(v),
                const SizedBox(height: 16),
                // Page ornament footer
                _buildPageFooter(pageIndex),
              ],
            ),
          ),
          // Book spine effect on left edge
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 8,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasmalaHeader() {
    return Column(
      children: [
        // Surah name in decorative frame
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: _pageDarkColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _goldColor.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: _goldColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                quran.getSurahNameArabic(widget.surahNumber),
                style: const TextStyle(
                  color: _goldColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 6),
              // Ornamental divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 40, height: 0.5, color: _goldColor.withValues(alpha: 0.5)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.diamond_outlined, color: _goldColor.withValues(alpha: 0.5), size: 10),
                  ),
                  Container(width: 40, height: 0.5, color: _goldColor.withValues(alpha: 0.5)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${quran.getSurahNameTurkish(widget.surahNumber)} • ${quran.getVerseCount(widget.surahNumber)} ${appSettings.languageCode == 'tr' ? 'Ayet' : 'Verses'}',
                style: TextStyle(
                  color: _inkColor.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // Basmala
        if (widget.surahNumber != 1 && widget.surahNumber != 9)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Text(
                  quran.basmala,
                  style: const TextStyle(
                    color: _goldColor,
                    fontSize: 26,
                    height: 1.6,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Container(height: 0.5, color: _goldColor.withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.star, color: _goldColor.withValues(alpha: 0.4), size: 8),
                    ),
                    Expanded(child: Container(height: 0.5, color: _goldColor.withValues(alpha: 0.3))),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVerse(int verseNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse number badge
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _goldColor.withValues(alpha: 0.6), width: 1),
                color: _goldColor.withValues(alpha: 0.08),
              ),
              child: Center(
                child: Text(
                  '$verseNumber',
                  style: TextStyle(
                    color: _goldColor,
                    fontWeight: FontWeight.bold,
                    fontSize: verseNumber > 99 ? 9 : 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Arabic text
          Text(
            quran.getVerse(widget.surahNumber, verseNumber, verseEndSymbol: true),
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _inkColor,
              fontSize: 24,
              height: 2.0,
              letterSpacing: 0.5,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 10),
          // Subtle verse divider
          if (verseNumber < quran.getVerseCount(widget.surahNumber))
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 0.3,
                    color: _borderColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(int pageIndex) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 30, height: 0.5, color: _goldColor.withValues(alpha: 0.3)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '❊',
                style: TextStyle(
                  color: _goldColor.withValues(alpha: 0.4),
                  fontSize: 12,
                ),
              ),
            ),
            Container(width: 30, height: 0.5, color: _goldColor.withValues(alpha: 0.3)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '— ${pageIndex + 1} —',
          style: TextStyle(
            color: _inkColor.withValues(alpha: 0.3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Custom painter to add subtle paper texture
class _PageTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4C5A0).withValues(alpha: 0.08)
      ..strokeWidth = 0.3;

    // Draw subtle horizontal lines to mimic paper grain
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
