import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class StrikeBotService {
  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY'); // Masukkan via --dart-define=GEMINI_API_KEY=xxx

  /// Rule-based knowledge base + LLM fallback
  static Future<String> getBotResponse(String userPrompt) async {
    final cleanPrompt = userPrompt.toLowerCase().trim();

    // 1. Coba lewat Gemini API jika key diisi
    if (_geminiApiKey.isNotEmpty) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiApiKey',
        );
        final body = jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Kamu adalah StrikeBot, asisten AI memancing cerdas dan ramah. Berikan tips singkat, taktik umpan, analisis cuaca, atau lokasi mancing untuk pertanyaan ini: $userPrompt'
                }
              ]
            }
          ]
        });
        final resp = await http
            .post(url, headers: {'Content-Type': 'application/json'}, body: body)
            .timeout(const Duration(seconds: 8));

        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          return data['candidates'][0]['content']['parts'][0]['text'] as String;
        }
      } catch (_) {}
    }

    // 2. Local Intelligence Engine berbasis pemancingan profesional
    await Future.delayed(const Duration(milliseconds: 900));

    if (cleanPrompt.contains('umpan') || cleanPrompt.contains('lure')) {
      if (cleanPrompt.contains('gabus') || cleanPrompt.contains('channa')) {
        return '🎣 Untuk ikan Gabus/Channa, gunakan Soft Frog lure dengan retrieve lambat di atas teratai atau eceng gondok. Waktu terbaik adalah pagi pukul 06.00-08.30!';
      } else if (cleanPrompt.contains('kakap') || cleanPrompt.contains('snapper')) {
        return '🐟 Untuk Kakap Merah atau Putih, umpan paling jitu adalah Udang Hidup atau Jig Metal 20-40g jika mancing di karang dalam. Mainkan di waktu pasang naik.';
      } else if (cleanPrompt.contains('nila')) {
        return '🌿 Untuk Nila liar atau badot, racikan lumut sawah campur sedikit vanili atau cacing merah sangat ampuh!';
      }
      return '🎣 Rekomendasi Umpan Umum:\n• Air tawar predator: Soft frog, spinner, minnow.\n• Muara/laut: Udang hidup, iris tongkol, jig metal.\n• Air tawar herbivor: Lumut sawah, pelet apung.';
    }

    if (cleanPrompt.contains('cuaca') || cleanPrompt.contains('waktu') || cleanPrompt.contains('kapan')) {
      return '⛅ Waktu memancing terbaik:\n1. Pagi hari (05.30 - 08.30): Ikan aktif sarapan.\n2. Sore senja (16.30 - 18.30): Suhu permukaan turun, predator berburu.\n3. Perhatikan pasang surut: Arus perbani/pasang awal adalah momen strike tertinggi!';
    }

    if (cleanPrompt.contains('spot') || cleanPrompt.contains('lokasi')) {
      return '📍 Tips Mencari Spot:\n• Cari struktur bawah air: pohon tumbang, tiang jembatan, karang tepi.\n• Perhatikan riak udara: gelembung halus sering menandakan ikan dasar sedang mencari makan.';
    }

    if (cleanPrompt.contains('senar') || cleanPrompt.contains('reel') || cleanPrompt.contains('joran')) {
      return '⚙️ Setup Piranti Mancing:\n• Kolam harian/harian: Senar PE 0.8 - 1.2, reel size 1000-2000.\n• Casting predator: Senar PE 1.5 - 2.5, reel size 2500-3000.\n• Pasang drag pada 30-40% dari kekuatan batas senar.';
    }

    if (cleanPrompt.contains('halo') || cleanPrompt.contains('hai') || cleanPrompt.contains('pagi') || cleanPrompt.contains('sore')) {
      return 'Halo Angler! 🎣 Saya StrikeBot, asisten AI memancingmu. Ada yang ingin kamu tanyakan seputar umpan, teknik joran, cuaca, atau spot hari ini?';
    }

    return 'Pertanyaan menarik! Untuk kondisi perairan tropis Indonesia, selalu perhatikan pasang surut air dan kejernihan perairan. Apakah kamu ingin saran umpan spesifik untuk jenis ikan tertentu (misal: Kakap, Gabus, atau Nila)? 🎣';
  }
}
