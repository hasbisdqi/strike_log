class CatchLog {
  final int? id;
  final String fishSpecies;
  final double weight; // kg
  final double length; // cm
  final String bait;
  final String locationName;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String? imagePath;
  final String? txHash; // Web3 proof

  CatchLog({
    this.id,
    required this.fishSpecies,
    required this.weight,
    required this.length,
    required this.bait,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.imagePath,
    this.txHash,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fishSpecies': fishSpecies,
      'weight': weight,
      'length': length,
      'bait': bait,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp,
      'imagePath': imagePath,
      'txHash': txHash,
    };
  }

  factory CatchLog.fromMap(Map<String, dynamic> map) {
    return CatchLog(
      id: map['id'],
      fishSpecies: map['fishSpecies'] ?? '',
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      length: (map['length'] as num?)?.toDouble() ?? 0.0,
      bait: map['bait'] ?? '',
      locationName: map['locationName'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] ?? '',
      imagePath: map['imagePath'],
      txHash: map['txHash'],
    );
  }
}

class FishingSpot {
  final String name;
  final String type; // Air Tawar / Air Asin
  final double latitude;
  final double longitude;
  final String bestTime;
  final double rating;

  FishingSpot({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.bestTime,
    required this.rating,
  });
}
