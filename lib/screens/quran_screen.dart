import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../main.dart';
import 'surah_detail_screen.dart';
import '../widgets/dynamic_background.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  List<int> get _filteredSurahs {
    List<int> surahs = List.generate(quran.totalSurahCount, (index) => index + 1);
    if (_searchQuery.isEmpty) return surahs;
    
    final query = _searchQuery.toLowerCase();
    return surahs.where((surahNumber) {
      final nameTr = quran.getSurahNameTurkish(surahNumber).toLowerCase();
      final nameEn = quran.getSurahName(surahNumber).toLowerCase();
      return nameTr.contains(query) || nameEn.contains(query);
    }).toList();
  }

  // Book-style color palette
  static const _pageColor = Color(0xFFF5ECD7);
  static const _pageDarkColor = Color(0xFFEDE1C8);
  static const _inkColor = Color(0xFF2C1810);
  static const _goldColor = Color(0xFFB8860B);
  static const _borderColor = Color(0xFFC9B88B);

  @override
  Widget build(BuildContext context) {
    return DynamicBackground(
      forceClassic: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button (dark leather style)
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
                      appSettings.l10n.t('quranTitle'),
                      style: const TextStyle(
                        color: Color(0xFFD4A843),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Book page content
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
                    // Book spine shadow on the left
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(-3, 0),
                    ),
                    // Page depth shadow
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
                  child: Column(
                    children: [
                      // Decorative header
                      _buildDecorativeHeader(),
                      // Search Bar
                      _buildSearchBar(),
                      // Surah list (table of contents style)
                      Expanded(
                        child: _filteredSurahs.isEmpty
                            ? Center(
                                child: Text(
                                  appSettings.languageCode == 'tr' 
                                      ? 'Sure bulunamadı.' 
                                      : 'No surah found.',
                                  style: TextStyle(
                                    color: _inkColor.withValues(alpha: 0.5),
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                                physics: const BouncingScrollPhysics(),
                                itemCount: _filteredSurahs.length,
                                itemBuilder: (context, index) {
                                  final surahNumber = _filteredSurahs[index];
                                  return _buildSurahItem(surahNumber);
                                },
                              ),
                      ),
                    ],
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

  Widget _buildDecorativeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: _pageDarkColor,
        border: Border(
          bottom: BorderSide(color: _borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Top ornament line
          Row(
            children: [
              Expanded(child: Container(height: 1, color: _goldColor)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '﷽',
                  style: TextStyle(
                    color: _goldColor,
                    fontSize: 28,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              Expanded(child: Container(height: 1, color: _goldColor)),
            ],
          ),
          const SizedBox(height: 12),
          // Ornamental border
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: _goldColor.withValues(alpha: 0.5), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  appSettings.l10n.t('surahs'),
                  style: const TextStyle(
                    color: _inkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${quran.totalSurahCount} ${appSettings.languageCode == 'tr' ? 'Sure' : 'Surahs'}',
                  style: TextStyle(
                    color: _inkColor.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Bottom ornament
          Row(
            children: [
              Expanded(child: Container(height: 0.5, color: _goldColor.withValues(alpha: 0.5))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.star, color: _goldColor.withValues(alpha: 0.5), size: 10),
              ),
              Expanded(child: Container(height: 0.5, color: _goldColor.withValues(alpha: 0.5))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: const TextStyle(color: _inkColor),
        decoration: InputDecoration(
          hintText: appSettings.languageCode == 'tr' ? 'Sure ara...' : 'Search surah...',
          hintStyle: TextStyle(color: _inkColor.withValues(alpha: 0.5)),
          prefixIcon: const Icon(Icons.search, color: _goldColor),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: Icon(Icons.clear, color: _inkColor.withValues(alpha: 0.5)),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
          filled: true,
          fillColor: _pageDarkColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: _goldColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahItem(int surahNumber) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahDetailScreen(surahNumber: surahNumber),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: _goldColor.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Surah number in gold circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _goldColor, width: 1.5),
                color: _goldColor.withValues(alpha: 0.08),
              ),
              child: Center(
                child: Text(
                  '$surahNumber',
                  style: const TextStyle(
                    color: _goldColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Surah name and info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quran.getSurahNameTurkish(surahNumber),
                    style: const TextStyle(
                      color: _inkColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${quran.getVerseCount(surahNumber)} ${appSettings.languageCode == 'tr' ? 'Ayet' : 'Verses'} • ${quran.getPlaceOfRevelation(surahNumber) == "Makkah" ? (appSettings.languageCode == 'tr' ? "Mekke" : "Makkah") : (appSettings.languageCode == 'tr' ? "Medine" : "Madinah")}',
                    style: TextStyle(
                      color: _inkColor.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Arabic name
            Text(
              quran.getSurahNameArabic(surahNumber),
              style: const TextStyle(
                color: _goldColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: _inkColor.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
