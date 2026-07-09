import 'package:flutter/material.dart';

class AppColors {
  static Color error = Color(0xFFE53935);
  static Color success = Color(0xFF2E7D32);

  // Background Gradient (Dark Green)
  static Gradient get backgroundGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1E3D2F), Color(0xFF162A20)],
    );
  }

  // To be used anywhere that strictly needs a single color background instead of a gradient
  static Color get background {
    return Color(0xFF1E3D2F);
  }

  static Color get textColor {
    return Colors.white;
  }

  static Color get primaryColor {
    return Color(0xFFC9A86A);
  }

  static Color get cardColor {
    return Color(0xFF264936);
  }

  static Color get borderColor {
    return Color(0xFFC9A86A).withValues(alpha: 0.3);
  }

  static Color get watermarkColor {
    return Color(0xFFC9A86A).withValues(alpha: 0.1);
  }
}
