import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/dynamic_background.dart';
import '../theme/app_colors.dart';
import '../main.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  void initState() {
    super.initState();
    appSettings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.textColor;

    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [

                    Text(
                      appSettings.l10n.t('qiblaTitle'),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _deviceSupport,
                  builder: (_, AsyncSnapshot<bool?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Hata: ${snapshot.error.toString()}",
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }
                    if (snapshot.data == true) {
                      return _buildQiblaCompass(textColor);
                    } else {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            "Cihazınızda pusula sensörü bulunmuyor.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQiblaCompass(Color textColor) {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }

        if (snapshot.hasError) {
          return _buildPermissionNeeded(textColor);
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return _buildPermissionNeeded(textColor);
        }

        final qiblahDirection = snapshot.data!;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appSettings.l10n.t('qiblaDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: 320,
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass Dial (Rotates to North)
                  Transform.rotate(
                    angle: (qiblahDirection.direction * (pi / 180) * -1),
                    child: CustomPaint(
                      size: const Size(320, 320),
                      painter: CompassDialPainter(textColor: textColor),
                    ),
                  ),
                  // Qibla Needle (Rotates to Qibla)
                  Transform.rotate(
                    angle: (qiblahDirection.qiblah * (pi / 180) * -1),
                    child: CustomPaint(
                      size: const Size(320, 320),
                      painter: QiblaNeedlePainter(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    "Kıble Açısı",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${qiblahDirection.offset.toStringAsFixed(1)}°",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPermissionNeeded(Color textColor) {
    final isTr = appSettings.languageCode == 'tr';
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 72,
              color: AppColors.primaryColor.withValues(alpha: 0.6),
            ),
            SizedBox(height: 20),
            Text(
              isTr
                  ? 'Kıble yönünü bulmak için\nkonum iznine ihtiyaç var'
                  : 'Location permission is needed\nto find the Qibla direction',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.75),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () async {
                final permission = await Geolocator.requestPermission();
                if (permission == LocationPermission.deniedForever) {
                  await Geolocator.openAppSettings();
                } else if (mounted) {
                  setState(() {}); // Rebuild to retry stream
                }
              },
              icon: Icon(Icons.location_on),
              label: Text(
                isTr ? 'Konum İzni Ver' : 'Grant Location Permission',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () async => await Geolocator.openAppSettings(),
              child: Text(
                isTr ? 'Uygulama Ayarlarını Aç' : 'Open App Settings',
                style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompassDialPainter extends CustomPainter {
  final Color textColor;

  CompassDialPainter({required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer rings
    final outerRingPaint = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final innerRingPaint = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius - 2, outerRingPaint);
    canvas.drawCircle(center, radius - 12, innerRingPaint);

    // Draw ticks
    final tickPaint = Paint()
      ..color = textColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final majorTickPaint = Paint()
      ..color = AppColors.primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 360; i += 5) {
      final isMajor = i % 30 == 0;
      final tickLength = isMajor ? 14.0 : 6.0;
      final angle = i * pi / 180;
      
      final startRadius = radius - 16;
      final endRadius = startRadius - tickLength;

      final startPoint = Offset(
        center.dx + startRadius * cos(angle),
        center.dy + startRadius * sin(angle),
      );
      final endPoint = Offset(
        center.dx + endRadius * cos(angle),
        center.dy + endRadius * sin(angle),
      );

      canvas.drawLine(startPoint, endPoint, isMajor ? majorTickPaint : tickPaint);
    }

    // Draw Cardinal Points (N, E, S, W)
    _drawText(canvas, center, "N", radius - 45, 0, true);
    _drawText(canvas, center, "E", radius - 45, pi / 2, false);
    _drawText(canvas, center, "S", radius - 45, pi, false);
    _drawText(canvas, center, "W", radius - 45, 3 * pi / 2, false);
  }

  void _drawText(Canvas canvas, Offset center, String text, double radius, double angle, bool isNorth) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isNorth ? Color(0xFFD4AF37) : textColor.withValues(alpha: 0.7),
          fontSize: isNorth ? 24 : 18,
          fontWeight: isNorth ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      center.dx + radius * cos(angle - pi / 2) - textPainter.width / 2,
      center.dy + radius * sin(angle - pi / 2) - textPainter.height / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QiblaNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = size.height / 2 - 20;

    // Draw shadow
    final shadowPath = Path();
    shadowPath.moveTo(center.dx - 10, center.dy);
    shadowPath.lineTo(center.dx, center.dy - needleLength + 5);
    shadowPath.lineTo(center.dx + 10, center.dy);
    shadowPath.lineTo(center.dx, center.dy + 30);
    shadowPath.close();

    canvas.drawShadow(shadowPath, Colors.black, 8, true);

    // Draw back of needle
    final backPaint = Paint()
      ..color = AppColors.textColor
      ..style = PaintingStyle.fill;
    
    final backPath = Path();
    backPath.moveTo(center.dx - 12, center.dy);
    backPath.lineTo(center.dx + 12, center.dy);
    backPath.lineTo(center.dx, center.dy + 35);
    backPath.close();
    canvas.drawPath(backPath, backPaint);

    // Draw front of needle (pointing to Qibla)
    final frontPaintLeft = Paint()
      ..color = Color(0xFFD4AF37) // Bright Gold
      ..style = PaintingStyle.fill;
    final frontPaintRight = Paint()
      ..color = Color(0xFF996515) // Dark Gold
      ..style = PaintingStyle.fill;

    // Left half
    final leftPath = Path();
    leftPath.moveTo(center.dx - 12, center.dy);
    leftPath.lineTo(center.dx, center.dy - needleLength);
    leftPath.lineTo(center.dx, center.dy);
    leftPath.close();
    canvas.drawPath(leftPath, frontPaintLeft);

    // Right half
    final rightPath = Path();
    rightPath.moveTo(center.dx, center.dy - needleLength);
    rightPath.lineTo(center.dx + 12, center.dy);
    rightPath.lineTo(center.dx, center.dy);
    rightPath.close();
    canvas.drawPath(rightPath, frontPaintRight);

    // Center pivot
    final pivotOuterPaint = Paint()..color = AppColors.textColor;
    final pivotInnerPaint = Paint()..color = Color(0xFFD4AF37);
    
    canvas.drawCircle(center, 12, pivotOuterPaint);
    canvas.drawCircle(center, 6, pivotInnerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
