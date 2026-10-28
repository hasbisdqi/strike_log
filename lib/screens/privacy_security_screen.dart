import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';
import '../core/utils/custom_toast.dart';
import '../services/local_notification_service.dart';

class PrivacySecurityScreen extends StatefulWidget {
  final String? userEmail;

  const PrivacySecurityScreen({super.key, this.userEmail});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final newPass = _passwordController.text.trim();
    final confirmPass = _confirmController.text.trim();

    if (newPass.length < 6) {
      CustomToast.showError(context, 'Password baru minimal 6 karakter');
      return;
    }
    if (newPass != confirmPass) {
      CustomToast.showError(context, 'Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(password: newPass),
      );
      if (!mounted) return;
      _passwordController.clear();
      _confirmController.clear();
      CustomToast.showSuccess(context, 'Password akun berhasil diperbarui!');
    } catch (e) {
      if (!mounted) return;
      CustomToast.showError(context, 'Gagal update password: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Privasi & Keamanan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Account info card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: AppRadius.xl,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.tealAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.security, color: AppColors.tealAccent),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Akun Terautentikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(widget.userEmail ?? 'Tidak diketahui', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Change password card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ubah Password Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text('Pastikan gunakan password yang kuat dan aman.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.lg),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  TextField(
                    controller: _confirmController,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      prefixIcon: Icon(Icons.lock_reset),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _updatePassword,
                    icon: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(_isLoading ? 'Menyimpan...' : 'Perbarui Password'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notification Test Card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Uji Coba Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    'Kirim notifikasi lokal ke perangkat untuk memastikan izin notifikasi aktif.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await LocalNotificationService.requestPermission();
                      await LocalNotificationService.showTestNotification();
                      if (context.mounted) {
                        CustomToast.showSuccess(context, 'Notifikasi test terkirim!');
                      }
                    },
                    icon: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                    label: const Text('Kirim Test Notifikasi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
