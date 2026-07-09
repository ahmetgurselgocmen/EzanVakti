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
    
    // Fix missing `final ` before variables assigned to AppColors
    // e.g. "    textColor = AppColors.textColor;" -> "    final textColor = AppColors.textColor;"
    final RegExp regex = RegExp(r'^(\s*)([a-zA-Z0-9_]+Color) = AppColors\.', multiLine: true);
    if (regex.hasMatch(content)) {
      content = content.replaceAllMapped(regex, (match) {
        return '${match.group(1)}final ${match.group(2)} = AppColors.';
      });
      changed = true;
    }
    
    // Also remove ALL `const ` from the entire file just to be safe about invalid_constant errors!
    // Since this is a UI layer, removing `const` from widgets is completely fine, it just slightly reduces performance optimization.
    // Wait, removing ALL `const ` might break some things that REQUIRE const (like switch cases, but we don't have switch cases on widgets).
    // Let's only remove `const ` if it's before Widget names (e.g. `const Icon`, `const Text`, `const TextStyle`, `const EdgeInsets`, `const SizedBox`, `const Color`, `const BoxShadow`, `const BorderSide`, `const BoxDecoration`, `const LinearGradient`, `const IconThemeData`).
    
    List<String> constWidgets = [
      'Icon', 'Text', 'TextStyle', 'EdgeInsets', 'SizedBox', 'Color', 'BoxShadow', 
      'BorderSide', 'BoxDecoration', 'LinearGradient', 'IconThemeData', 'Padding',
      'Center', 'Container', 'Row', 'Column', 'Expanded', 'Align', 'AnimatedContainer',
      'MaterialPageRoute', 'Scaffold', 'AppBar'
    ];
    
    for (String w in constWidgets) {
      if (content.contains('const $w')) {
        content = content.replaceAll('const $w', w);
        changed = true;
      }
    }
    
    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed ${file.path}');
    }
  }
}
