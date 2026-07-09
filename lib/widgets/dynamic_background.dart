import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../main.dart';

class DynamicBackground extends StatelessWidget {
  final Widget child;
  final bool forceClassic;

  const DynamicBackground({
    super.key, 
    required this.child,
    this.forceClassic = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Background Pattern
        RepaintBoundary(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home_bg_pattern.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // 2. Foreground Content
        child,
      ],
    );
  }
}

