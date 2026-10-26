import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tentang Aplikasi', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Logo & Title
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.phishing, size: 42, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Strike Log',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text('Versi 1.0.0 (Release Proyek Akhir)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            ),
            const SizedBox(height: AppSpacing.xl),

            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  const Text(
                    'Strike Log adalah aplikasi jurnal & log memancing generasi baru yang mengombinasikan '
                    'teknologi modern: AI Vision Scanner foto ikan, deteksi tarikan joran menggunakan sensor Accelerometer, '
                    'kompas arah spot, LBS & prakiraan cuaca Open-Meteo, Proof-of-Catch Blockchain Stamp, '
                    'serta database offline-first dengan Hive & cloud database Supabase.',
                    style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  _buildSpecRow('Framework', 'Flutter 3.x (Dart)'),
                  _buildSpecRow('Backend', 'Supabase PostgreSQL & Storage'),
                  _buildSpecRow('Local Database', 'Hive Flutter Box'),
                  _buildSpecRow('Keamanan', 'Biometric & SHA-256 Hash'),
                  _buildSpecRow('Mata Kuliah', 'Praktikum Pemrograman Aplikasi Mobile'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
