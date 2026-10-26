import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keySavedEmail = 'saved_user_email';
  static const String _keySavedPassword = 'saved_user_password';

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    return val == 'true';
  }

  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _keyBiometricEnabled, value: 'true');
    await _storage.write(key: _keySavedEmail, value: email);
    await _storage.write(key: _keySavedPassword, value: password);
  }

  Future<String?> getSavedEmail() async {
    return await _storage.read(key: _keySavedEmail);
  }

  Future<String?> getSavedPassword() async {
    return await _storage.read(key: _keySavedPassword);
  }

  Future<void> clearCredentials() async {
    await _storage.delete(key: _keyBiometricEnabled);
    await _storage.delete(key: _keySavedPassword);
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Pindai sidik jari atau wajah untuk masuk ke Strike Log',
        biometricOnly: false, // fallback to device pin/pattern if no biometric enrolled
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      return false;
    }
  }
}
