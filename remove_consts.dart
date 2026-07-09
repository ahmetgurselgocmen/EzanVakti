import 'dart:io';

void main() {
  final dir = Directory('c:/flutter_app/EzanVakti/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (var file in files) {
    if (file.path.contains('quran_screen.dart') || file.path.contains('surah_detail_screen.dart') || file.path.contains('themes_screen.dart')) {
      continue;
    }
    String content = file.readAsStringSync();
    bool changed = false;
    
    // Split into lines
    var lines = content.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('AppColors.')) {
        if (lines[i].contains('const ')) {
          lines[i] = lines[i].replaceAll('const ', '');
          changed = true;
        }
      }
    }
    
    if (changed) {
      file.writeAsStringSync(lines.join('\n'));
      print('Removed const from AppColors lines in ${file.path}');
    }
  }
}
