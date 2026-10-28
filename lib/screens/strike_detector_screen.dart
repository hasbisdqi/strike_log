import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';

class StrikeDetectorScreen extends StatefulWidget {
  const StrikeDetectorScreen({super.key});

  @override
  State<StrikeDetectorScreen> createState() => _StrikeDetectorScreenState();
}

class _StrikeDetectorScreenState extends State<StrikeDetectorScreen> {
  // Sensor 1: Accelerometer (Strike Jolt Detector)
  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  double _currentForce = 0.0;
  double _maxForce = 0.0;
  bool _isStrikeTriggered = false;
  int _strikeCount = 0;
  static const double _strikeThreshold = 14.0; // Ambang hentakan joran (m/s^2)

  // Sensor 2: Magnetometer / Compass (Arah Angin & Perahu)
  StreamSubscription<CompassEvent>? _compassSub;
  double? _heading = 0.0;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    // 1. Accelerometer Listener
    _accelSub = userAccelerometerEventStream().listen((event) {
      final totalForce = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (mounted) {
        setState(() {
          _currentForce = totalForce;
          if (totalForce > _maxForce) _maxForce = totalForce;

          if (totalForce > _strikeThreshold && !_isStrikeTriggered) {
            _isStrikeTriggered = true;
            _strikeCount++;
            _showStrikeDialog(totalForce);
          }
        });
      }
    });

    // 2. Compass Listener
    _compassSub = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _heading = event.heading;
        });
      }
    });
  }

  void _showStrikeDialog(double force) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.amberAccent, size: 28),
            SizedBox(width: AppSpacing.sm),
            Text('STRIKE TERDETEKSI! 🎣', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Sentakan joran terdeteksi dengan kekuatan ${force.toStringAsFixed(1)} m/s²!\nSegera gulung senar pancinganmu!',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) setState(() => _isStrikeTriggered = false);
              });
            },
            child: const Text('Siap Gulung!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  String _getDirectionLabel(double deg) {
    if (deg >= 337.5 || deg < 22.5) return 'Utara (N)';
    if (deg >= 22.5 && deg < 67.5) return 'Timur Laut (NE)';
    if (deg >= 67.5 && deg < 112.5) return 'Timur (E)';
    if (deg >= 112.5 && deg < 157.5) return 'Tenggara (SE)';
    if (deg >= 157.5 && deg < 202.5) return 'Selatan (S)';
    if (deg >= 202.5 && deg < 247.5) return 'Barat Daya (SW)';
    if (deg >= 247.5 && deg < 292.5) return 'Barat (W)';
    return 'Barat Laut (NW)';
  }

  @override
  Widget build(BuildContext context) {
    final headingDeg = _heading ?? 0.0;
    final forceRatio = (_currentForce / _strikeThreshold).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sensor Joran & Kompas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Column(
          children: [
            // SENSOR 1: Accelerometer Strike Detector Card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.vibration, color: AppColors.primary, size: 24),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Detektor Sentakan (Accelerometer)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '$_strikeCount Strike',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Force gauge meter
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: forceRatio,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          color: forceRatio > 0.8 ? AppColors.error : AppColors.primary,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentForce.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'm/s²',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    forceRatio > 0.8 ? 'SENTAKAN KUAT!' : 'Pasang HP di joran untuk mendeteksi strike',
                    style: TextStyle(
                      color: forceRatio > 0.8 ? AppColors.error : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Puncak Tarikan: ${_maxForce.toStringAsFixed(1)} m/s²',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // SENSOR 2: Compass Magnetometer Card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.explore_outlined, color: AppColors.tealAccent, size: 24),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Kompas Navigasi Spot (Magnetometer)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Visual Compass Dial & Needle
                  Transform.rotate(
                    angle: ((headingDeg) * (pi / 180) * -1),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.tealAccent.withValues(alpha: 0.4), width: 3),
                        gradient: RadialGradient(
                          colors: [
                            AppColors.tealAccent.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Utara (N)
                          const Positioned(
                            top: 8,
                            child: Text(
                              'U',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error),
                            ),
                          ),
                          // Selatan (S)
                          const Positioned(
                            bottom: 8,
                            child: Text(
                              'S',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ),
                          // Timur (E)
                          const Positioned(
                            right: 8,
                            child: Text(
                              'T',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ),
                          // Barat (W)
                          const Positioned(
                            left: 8,
                            child: Text(
                              'B',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
                            ),
                          ),
                          // Needle (North: Merah, South: Teal/Abu)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                                ),
                              ),
                              Container(
                                width: 5,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: AppColors.tealAccent,
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                                ),
                              ),
                            ],
                          ),
                          // Center Pivot
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.tealAccent, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    '${headingDeg.toStringAsFixed(0)}° ${_getDirectionLabel(headingDeg)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Orientasi arah haluan perahu & mata angin spot',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.bottomNavPadding),
          ],
        ),
      ),
    );
  }
}
