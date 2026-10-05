import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    final photo = await _picker.pickImage(source: source);
    if (photo != null) {
      setState(() {
        _selectedImage = photo;
        _isAnalyzing = true;
        _aiResult = null;
      });

      await Future.delayed(const Duration(milliseconds: 1200));
      final result = FishAiVisionService.classifyFishPhoto(photo.path);

      setState(() {
        _isAnalyzing = false;
        _aiResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'AI Fish Species Classifier',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const Text(
              'Ambil foto atau pilih dari galeri untuk identifikasi spesies ikan secara otomatis.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.teal.shade300, width: 2),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: const Center(child: Icon(Icons.phishing, size: 64, color: Colors.teal)),
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pilih Galeri'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.teal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_isAnalyzing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('AI sedang memproses fitur anatomi ikan...'),
                  ],
                ),
              )
            else if (_aiResult != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hasil Identifikasi AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Chip(
                            label: Text('Akurasi: ' + _aiResult!['confidence'].toString() + '%', style: const TextStyle(fontSize: 11, color: Colors.white)),
                            backgroundColor: Colors.teal,
                          ),
                        ],
                      ),
                      const Divider(),
                      Text('Spesies: ' + _aiResult!['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('Habitat: ' + _aiResult!['habitat'].toString()),
                      Text('Umpan Rekomendasi: ' + _aiResult!['recommendedBait'].toString()),
                      Text('Kelayakan Konsumsi: ' + _aiResult!['edible'].toString()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
