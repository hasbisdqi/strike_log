import 'dart:convert';
import 'package:http/http.dart' as http;

class FishialSpecies {
  final String commonName;
  final String scientificName;
  final String habitat;
  final String? family;

  const FishialSpecies({
    required this.commonName,
    required this.scientificName,
    required this.habitat,
    this.family,
  });

  factory FishialSpecies.fromJson(Map<String, dynamic> json) {
    return FishialSpecies(
      commonName: json['common_name'] ?? 'Unknown Fish',
      scientificName: json['scientific_name'] ?? '',
      habitat: json['habitat'] ?? 'Air Tawar / Laut Tropis',
      family: json['family'],
    );
  }

  Map<String, dynamic> toJson() => {
        'common_name': commonName,
        'scientific_name': scientificName,
        'habitat': habitat,
        'family': family,
      };
}

class FishialApiService {
  static const String speciesDocsUrl =
      'https://raw.githubusercontent.com/fishial/docs/master/pages/100.API/10.Specieslist/default.md';

  /// Master cache offline berbasis taksonomi resmi Fishial.AI v10
  static const List<FishialSpecies> defaultFishialSpecies = [
    FishialSpecies(
      commonName: 'Barramundi (Kakap Putih)',
      scientificName: 'Lates calcarifer',
      habitat: 'Muara Payau, Bakau & Pesisir Pantai',
      family: 'Latidae',
    ),
    FishialSpecies(
      commonName: 'Giant Trevally (GT / Kuwe Batu)',
      scientificName: 'Caranx ignobilis',
      habitat: 'Tubir Karang, Arus Laut Kuat & Karang Terjal',
      family: 'Carangidae',
    ),
    FishialSpecies(
      commonName: 'Mangrove Red Snapper (Kakap Merah)',
      scientificName: 'Lutjanus argentimaculatus',
      habitat: 'Hutan Bakau, Muara & Karang Karang',
      family: 'Lutjanidae',
    ),
    FishialSpecies(
      commonName: 'Striped Snakehead (Ikan Gabus)',
      scientificName: 'Channa striata',
      habitat: 'Rawa Air Tawar, Danau & Kanal Dangkal',
      family: 'Channidae',
    ),
    FishialSpecies(
      commonName: 'Indonesian Snakehead (Ikan Toman)',
      scientificName: 'Channa micropeltes',
      habitat: 'Danau Pedalaman & Rawa Tropis',
      family: 'Channidae',
    ),
    FishialSpecies(
      commonName: 'Brown-Marbled Grouper (Kerapu Macan)',
      scientificName: 'Epinephelus fuscoguttatus',
      habitat: 'Terumbu Karang Dasar Laut & Gua Batu',
      family: 'Serranidae',
    ),
    FishialSpecies(
      commonName: 'Nile Tilapia (Ikan Nila Badot)',
      scientificName: 'Oreochromis niloticus',
      habitat: 'Waduk, Danau & Kolam Air Tawar',
      family: 'Cichlidae',
    ),
    FishialSpecies(
      commonName: 'Wahoo (Tenggiri Laki)',
      scientificName: 'Acanthocybium solandri',
      habitat: 'Laut Lepas (Pelagic) & Karang Luar',
      family: 'Scombridae',
    ),
    FishialSpecies(
      commonName: 'Yellowfin Tuna (Madidihang)',
      scientificName: 'Thunnus albacares',
      habitat: 'Samudera Lepas Tropis & Drop-off Laut Dalam',
      family: 'Scombridae',
    ),
    FishialSpecies(
      commonName: 'Mahi Mahi (Ikan Lemadang)',
      scientificName: 'Coryphaena hippurus',
      habitat: 'Permukaan Laut Lepas & Sekitar Rumpon',
      family: 'Coryphaenidae',
    ),
    FishialSpecies(
      commonName: 'Bluefin Trevally (Kuwe Sirip Biru)',
      scientificName: 'Caranx melampygus',
      habitat: 'Laguna Dangkal & Terumbu Karang Luar',
      family: 'Carangidae',
    ),
    FishialSpecies(
      commonName: 'Common Carp (Ikan Mas / Karper)',
      scientificName: 'Cyprinus carpio',
      habitat: 'Sungai Berarus Tenang & Kolam Air Tawar',
      family: 'Cyprinidae',
    ),
    FishialSpecies(
      commonName: 'Orange-Spotted Grouper (Kerapu Lumpur)',
      scientificName: 'Epinephelus coioides',
      habitat: 'Muara Sungai, Bakau & Perairan Keruh',
      family: 'Serranidae',
    ),
    FishialSpecies(
      commonName: 'Great Barracuda (Alu-Alu)',
      scientificName: 'Sphyraena barracuda',
      habitat: 'Perairan Karang Tropis & Dermaga Laut',
      family: 'Sphyraenidae',
    ),
    FishialSpecies(
      commonName: 'Milkfish (Ikan Bandeng)',
      scientificName: 'Chanos chanos',
      habitat: 'Muara Sungai, Tambak Payau & Pesisir',
      family: 'Chanidae',
    ),
  ];

  /// Fetch live species list from Fishial.AI repository docs markdown table
  static Future<List<FishialSpecies>> fetchFishialSpeciesList() async {
    try {
      final response = await http
          .get(Uri.parse(speciesDocsUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final content = response.body;
        final lines = LineSplitter.split(content).toList();
        final List<FishialSpecies> parsed = [];

        for (final line in lines) {
          if (line.startsWith('|') && line.contains('|') && !line.contains('---')) {
            final parts = line
                .split('|')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();

            if (parts.length >= 2) {
              final col1 = parts[0];
              final col2 = parts[1];

              // Skip header rows
              if (col1.toLowerCase() == 'scientific_name' ||
                  col1.toLowerCase() == 'scientific name' ||
                  col2.toLowerCase() == 'common_name' ||
                  col2.toLowerCase() == 'common name') {
                continue;
              }

              // In Fishial V10 table: col1 is common_name, col2 is scientific_name
              final common = col1;
              final sci = col2;

              if (common.isNotEmpty && sci.isNotEmpty) {
                parsed.add(
                  FishialSpecies(
                    commonName: common,
                    scientificName: sci,
                    habitat: _guessHabitat(common, sci),
                  ),
                );
              }
            }
          }
        }

        if (parsed.isNotEmpty) {
          // Filter to priority species or return unique top 50
          return parsed.take(60).toList();
        }
      }
    } catch (_) {}

    return defaultFishialSpecies;
  }

  static String _guessHabitat(String common, String scientific) {
    final lower = '$common $scientific'.toLowerCase();
    if (lower.contains('trout') || lower.contains('salmon') || lower.contains('carp') || lower.contains('bass') || lower.contains('catfish') || lower.contains('channa') || lower.contains('tilapia')) {
      return 'Air Tawar Tropis & Subtropis';
    } else if (lower.contains('snapper') || lower.contains('grouper') || lower.contains('tuna') || lower.contains('mackerel') || lower.contains('jack') || lower.contains('trevally') || lower.contains('shark') || lower.contains('barracuda')) {
      return 'Perairan Karang & Samudera Tropis';
    }
    return 'Perairan Tropis & Payau';
  }
}
