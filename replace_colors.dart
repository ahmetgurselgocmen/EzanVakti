import 'dart:io';

void main() {
  final dir = Directory('c:/flutter_app/EzanVakti/lib/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (var file in files) {
    if (file.path.contains('quran_screen.dart') || file.path.contains('surah_detail_screen.dart') || file.path.contains('themes_screen.dart')) {
      continue;
    }
    String content = file.readAsStringSync();
    
    // Add import if missing
    if (!content.contains('app_colors.dart')) {
      if (content.contains("import '../main.dart';")) {
        content = content.replaceFirst("import '../main.dart';", "import '../theme/app_colors.dart';\nimport '../main.dart';");
      } else {
        content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../theme/app_colors.dart';");
      }
    }
    
    // Replace colors
    content = content.replaceAll("const Color(0xFF2C1810)", "AppColors.textColor");
    content = content.replaceAll("Color(0xFF2C1810)", "AppColors.textColor");
    
    content = content.replaceAll("const Color(0xFFB8860B)", "AppColors.primaryColor");
    content = content.replaceAll("Color(0xFFB8860B)", "AppColors.primaryColor");
    
    content = content.replaceAll("const Color(0xFFEDE1C8)", "AppColors.cardColor");
    content = content.replaceAll("Color(0xFFEDE1C8)", "AppColors.cardColor");
    
    content = content.replaceAll("const Color(0xFFC9B88B)", "AppColors.borderColor");
    content = content.replaceAll("Color(0xFFC9B88B)", "AppColors.borderColor");
    
    // Remove "const " before AppColors if it got left behind (e.g. const AppColors.textColor)
    content = content.replaceAll("const AppColors.", "AppColors.");
    
    file.writeAsStringSync(content);
  }
  print('Done replacing colors in screens!');
}
