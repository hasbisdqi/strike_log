import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/app_config.dart';
import '../core/supabase_config.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
      };
}

class StrikeBotService {
  /// Kirim percakapan dengan konteks history ke Edge Function 'gemini'
  static Future<String> getBotResponse(
    String userPrompt, {
    List<ChatMessage> conversationHistory = const [],
  }) async {
    try {
      final historyPayload = conversationHistory.map((m) => m.toJson()).toList();

      final response = await SupabaseConfig.client.functions.invoke(
        AppConfig.geminiFunctionName,
        body: {
          'action': 'chat',
          'userPrompt': userPrompt,
          'conversationHistory': historyPayload,
        },
      );

      final data = response.data;
      if (response.status == 200 && data != null) {
        if (data is Map && data['success'] == true) {
          return (data['reply'] as String?)?.trim() ??
              'StrikeBot tidak dapat menghasilkan jawaban.';
        }
        if (data is Map && data.containsKey('error')) {
          return 'Gagal dari StrikeBot AI (${data['error']}).';
        }
        return 'Format tanggapan StrikeBot tidak sesuai.';
      } else {
        String errMsg = 'Kode status ${response.status}';
        if (data is Map && data['error'] != null) {
          errMsg = data['error'].toString();
        }
        return 'Gagal terhubung ke Gemini AI via Edge Function ($errMsg).';
      }
    } on FunctionException catch (fe) {
      String detail = fe.reasonPhrase ?? 'Status ${fe.status}';
      if (fe.details != null && fe.details is Map && fe.details['error'] != null) {
        detail = fe.details['error'].toString();
      }
      return 'Layanan StrikeBot mengalami kendala ($detail).';
    } catch (e) {
      return 'Koneksi ke StrikeBot terputus. Pastikan perangkatmu terhubung ke internet. ($e)';
    }
  }
}
