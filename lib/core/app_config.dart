class AppConfig {
  /// Di-pass saat run: --dart-define=GEMINI_API_KEY=xxx
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  /// Model endpoint yang didukung di v1beta
  static const String geminiModel = 'gemini-2.5-flash';
}
