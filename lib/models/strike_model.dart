class StrikeModel {
  final String id;
  final String userId;
  final String fishName;
  final double weightKg;
  final String spotName;
  final String? lureName;
  final String? notes;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final String? blockchainHash;
  final int? blockNumber;
  final DateTime caughtAt;

  StrikeModel({
    required this.id,
    required this.userId,
    required this.fishName,
    required this.weightKg,
    required this.spotName,
    this.lureName,
    this.notes,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.blockchainHash,
    this.blockNumber,
    required this.caughtAt,
  });

  factory StrikeModel.fromJson(Map<String, dynamic> json) {
    return StrikeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fishName: json['fish_name'] as String? ?? 'Ikan Misterius',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0.0,
      spotName: json['spot_name'] as String? ?? 'Spot Rahasia',
      lureName: json['lure_name'] as String?,
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      blockchainHash: json['blockchain_hash'] as String?,
      blockNumber: (json['block_number'] as num?)?.toInt(),
      caughtAt: json['caught_at'] != null
          ? DateTime.parse(json['caught_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fish_name': fishName,
      'weight_kg': weightKg,
      'spot_name': spotName,
      'lure_name': lureName,
      'notes': notes,
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'blockchain_hash': blockchainHash,
      'block_number': blockNumber,
      'caught_at': caughtAt.toIso8601String(),
    };
  }
}
