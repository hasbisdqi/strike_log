import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class BlockchainProofService {
  /// Generate SHA-256 block hash for proof-of-catch
  static Future<Map<String, dynamic>> generateProof({
    required File photoFile,
    required String userId,
    required String fishName,
    required double weightKg,
    required String spotName,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
  }) async {
    // 1. Hash file bytes
    final bytes = await photoFile.readAsBytes();
    final photoHash = sha256.convert(bytes).toString();

    // 2. Prepare block payload
    final blockData = {
      'angler_id': userId,
      'fish': fishName,
      'weight_kg': weightKg,
      'spot': spotName,
      'lat': latitude,
      'lng': longitude,
      'timestamp': timestamp.toIso8601String(),
      'photo_sha256': photoHash,
    };

    final rawPayload = jsonEncode(blockData);
    final blockHash = sha256.convert(utf8.encode(rawPayload)).toString();

    // Generate block number based on timestamp hash
    final blockNumber = (timestamp.millisecondsSinceEpoch ~/ 1000) % 900000 + 100000;

    return {
      'block_number': blockNumber,
      'block_hash': '0x$blockHash',
      'photo_hash': photoHash,
      'short_hash': '0x${blockHash.substring(0, 10)}...${blockHash.substring(blockHash.length - 6)}',
      'verified_at': timestamp.toIso8601String(),
    };
  }
}
