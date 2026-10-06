import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/web3_ai_service.dart';

class AiScannerScreen extends StatefulWidget {
  const AiScannerScreen({super.key});

  @override
  State<AiScannerScreen> createState() => _AiScannerScreenState();
}

class _AiScannerScreenState extends State<AiScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Map<String, dynamic>? _aiResult;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo != null) {
        setState(() {
          _selectedImage = photo;
          _isAnalyzing = true;
          _aiResult = null;
        });

        await Future.delayed(const Duration(milliseconds: 1400));
        final result = FishAiVisionService.classifyFishPhoto(photo.path);

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _aiResult = result;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  void _showManualFishSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Spesies Ikan Langsung (Manual Match)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: FishAiVisionService.fishCatalog.length,
                itemBuilder: (context, idx) {
                  final fish = FishAiVisionService.fishCatalog[idx];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.phishing, color: Colors.white, size: 20),
                    ),
                    title: Text(fish['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(fish['habitat'], style: const TextStyle(fontSize: 11)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _aiResult = {
                          'name': fish['name'],
                          'habitat': fish['habitat'],
                          'recommendedBait': fish['recommendedBait'],
                          'edible': fish['edible'],
                          'confidence': fish['baseConfidence'],
                          'isFish': true,
                        };
                      });
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Fish Species Classifier',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                TextButton.icon(
                  onPressed: _showManualFishSelector,
                  icon: const Icon(Icons.tune, size: 16, color: Colors.teal),
                  label: const Text('Katalog', style: TextStyle(fontSize: 12, color: Colors.teal)),
                ),
              ],
            ),
            const Text(
              'Ambil foto atau pilih dari galeri untuk identifikasi anatomi & spesies ikan.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Image Preview Box
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade300, width: 2),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                        ),
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_enhance, size: 54, color: Colors.teal),
                        SizedBox(height: 8),
                        Text('Belum ada foto yang dipilih', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Buka Kamera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pilih Galeri'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isAnalyzing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Colors.teal),
                      SizedBox(height: 12),
                      Text('AI sedang mengekstrak tekstur sisik & bentuk sirip ikan...'),
                    ],
                  ),
                ),
              )
            else if (_aiResult != null)
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Hasil Identifikasi AI',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              'Akurasi: ${_aiResult!['confidence']}%',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildAiRow(Icons.phishing, 'Spesies', _aiResult!['name']),
                      const SizedBox(height: 10),
                      _buildAiRow(Icons.waves, 'Habitat', _aiResult!['habitat']),
                      const SizedBox(height: 10),
                      _buildAiRow(Icons.fastfood, 'Umpan Rekomendasi', _aiResult!['recommendedBait']),
                      const SizedBox(height: 10),
                      _buildAiRow(Icons.restaurant, 'Kelayakan Konsumsi', _aiResult!['edible']),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}
