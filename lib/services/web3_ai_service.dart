import 'dart:math';

class Web3SolanaService {
  // Public wallet address Solana devnet Hasbi
  static const String walletAddress = '13yfcWDQmnfknP5WfPNxNP2P5fthxC4zAKC9tyhn7DVR';
  static double tokenRewardBalance = 145.50; // STRIKE Tokens

  static String generateCatchCertificateHash(String species, double weight) {
    final chars = '0123456789abcdefABCDEF';
    final rand = Random();
    final hashSuffix = List.generate(12, (index) => chars[rand.nextInt(chars.length)]).join();
    return '0xSolDev_$species\_${weight}kg_$hashSuffix';
  }

  static void addReward(double amount) {
    tokenRewardBalance += amount;
  }
}

class FishAiVisionService {
  static final List<Map<String, dynamic>> fishDatabase = [
    {
      'name': 'Ikan Kakap Merah (Lutjanus campechanus)',
      'habitat': 'Laut Dalam / Karang',
      'recommendedBait': 'Udang Hidup, Cumi-cumi',
      'edible': 'Sangat Layak Konsumsi (Grade A)',
      'confidence': 96.4
    },
    {
      'name': 'Ikan Kerapu Macan (Epinephelus fuscoguttatus)',
      'habitat': 'Muara & Terumbu Karang',
      'recommendedBait': 'Ikan Selar Kecil, Undur-undur laut',
      'edible': 'Sangat Layak Konsumsi (Nilai Ekonomi Tinggi)',
      'confidence': 94.8
    },
    {
      'name': 'Ikan Bawal Air Tawar (Colossoma macropomum)',
      'habitat': 'Sungai, Danau, Waduk',
      'recommendedBait': 'Kacang, Pelet Fermentasi, Jangkrik',
      'edible': 'Layak Konsumsi',
      'confidence': 98.1
    },
    {
      'name': 'Ikan Nila Merah (Oreochromis niloticus)',
      'habitat': 'Air Tawar / Tambak',
      'recommendedBait': 'Lumut Sawah, Cacing Merah',
      'edible': 'Layak Konsumsi',
      'confidence': 97.5
    },
  ];

  static Map<String, dynamic> classifyFishPhoto(String imagePath) {
    final rand = Random();
    return fishDatabase[rand.nextInt(fishDatabase.length)];
  }
}
