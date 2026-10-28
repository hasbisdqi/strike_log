import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_config.dart';
import 'core/theme/app_tokens.dart';
import 'services/local_strike_storage.dart';
import 'services/local_notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    publishableKey: SupabaseConfig.supabasePublishableKey,
  );

  // Inisialisasi Database Lokal Hive
  await LocalStrikeStorage.init();

  // Inisialisasi Notifikasi Lokal
  await LocalNotificationService.init();

  runApp(const StrikeLogApp());
}

class StrikeLogApp extends StatelessWidget {
  final Widget? homeOverride;

  const StrikeLogApp({super.key, this.homeOverride});

  @override
  Widget build(BuildContext context) {
    Widget initialHome = const LoginScreen();
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null) {
        initialHome = MainNavigationScreen(userEmail: session.user.email);
      }
    } catch (_) {}

    return MaterialApp(
      title: 'Strike Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 2,
          ),
        ),
      ),
      home: homeOverride ?? initialHome,
    );
  }
}
