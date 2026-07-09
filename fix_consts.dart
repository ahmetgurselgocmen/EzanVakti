import 'dart:io';

void main() {
  final dir = Directory('c:/flutter_app/EzanVakti/lib/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (var file in files) {
    if (file.path.contains('quran_screen.dart') || file.path.contains('surah_detail_screen.dart') || file.path.contains('themes_screen.dart')) {
      continue;
    }
    String content = file.readAsStringSync();
    
    final RegExp regex = RegExp(r'static const (_[a-zA-Z0-9]+Color) = AppColors\.([a-zA-Z0-9]+);');
    if (regex.hasMatch(content)) {
      content = content.replaceAllMapped(regex, (match) {
        return 'static Color get ${match.group(1)} => AppColors.${match.group(2)};';
      });
      
      file.writeAsStringSync(content);
      print('Fixed ${file.path}');
    }
  }
  
  // also check other files like widgets if any
  final widgetsDir = Directory('c:/flutter_app/EzanVakti/lib/widgets');
  if (widgetsDir.existsSync()) {
    final wFiles = widgetsDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (var file in wFiles) {
      String content = file.readAsStringSync();
      final RegExp regex = RegExp(r'static const (_[a-zA-Z0-9]+Color) = AppColors\.([a-zA-Z0-9]+);');
      if (regex.hasMatch(content)) {
        content = content.replaceAllMapped(regex, (match) {
          return 'static Color get ${match.group(1)} => AppColors.${match.group(2)};';
        });
        file.writeAsStringSync(content);
        print('Fixed ${file.path}');
      }
    }
  }
}
