import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';

class FeedbackCourseScreen extends StatelessWidget {
  const FeedbackCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saran & Kesan Kuliah PAM', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Header Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.school_outlined, size: 48, color: Colors.white),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Praktikum Pemrograman Aplikasi Mobile',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Teknik Informatika • Semester Genap',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Card Kesan
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, color: AppColors.tealAccent, size: 24),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Kesan Selama Perkuliahan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Mata kuliah Praktikum Pemrograman Aplikasi Mobile (PAM) memberikan pengalaman belajar Flutter yang sangat mendalam dan aplikatif. '
                    'Mulai dari fundamental state management, integrasi cloud database Supabase, pemanfaatan sensor perangkat nyata (biometrik, GPS LBS, accelerometer, kompas), '
                    'hingga implementasi kecerdasan buatan (AI Vision & LLM). Materi yang disampaikan sangat relevan dengan standar industri pengembangan aplikasi mobile modern.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.55, fontSize: 13.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Card Saran
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.amberAccent, size: 24),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Saran untuk Masa Depan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '1. Alokasi waktu hands-on code review atau sesi bedah arsitektur clean architecture/bloc bersama asisten praktikum dapat ditambah.\n'
                    '2. Dokumentasi studi kasus proyek akhir berbasis real-world device integration (hardware sensors & offline-first database) dipertahankan karena sangat menantang dan memacu kreativitas mahasiswa.',
                    style: TextStyle(color: AppColors.textSecondary, height: 1.55, fontSize: 13.5),
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
