import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/strike_service.dart';
import '../services/location_service.dart';
import '../services/weather_api_service.dart';
import '../services/local_notification_service.dart';
import '../services/ai_vision_service.dart';
import '../services/blockchain_proof_service.dart';
import 'location_picker_screen.dart';

class AddStrikeScreen extends StatefulWidget {
  const AddStrikeScreen({super.key});

  @override
  State<AddStrikeScreen> createState() => _AddStrikeScreenState();
}

class _AddStrikeScreenState extends State<AddStrikeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fishNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _spotNameController = TextEditingController();
  final _lureController = TextEditingController();
  final _notesController = TextEditingController();

  final _strikeService = StrikeService();
  final _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;
  bool _isAiScanning = false;
  bool _isLocating = false;

  double? _latitude;
  double? _longitude;
  WeatherResult? _weatherInfo;
  BlockchainProofResult? _blockchainProof;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePhoto();
    });
  }

  @override
  void dispose() {
    _fishNameController.dispose();
    _weightController.dispose();
    _spotNameController.dispose();
    _lureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickLocationFromMap() async {
    final result = await Navigator.push<LocationPickerResult>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLat: _latitude ?? -6.2088,
          initialLng: _longitude ?? 106.8456,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _spotNameController.text = result.spotName;
      });

      // Update weather info for new location
      final weather = await WeatherApiService.getWeather(
        latitude: result.latitude,
        longitude: result.longitude,
      );
      if (weather != null && mounted) {
        setState(() => _weatherInfo = weather);
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() => _imageFile = file);
        await _processSmartLog(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka kamera: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (picked != null) {
        final file = File(picked.path);
        setState(() => _imageFile = file);
        await _processSmartLog(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih foto: $e')),
        );
      }
    }
  }

  /// Flow Cerdas: GPS LBS + AI Vision Scan + Blockchain Hash Generation
  Future<void> _processSmartLog(File file) async {
    setState(() {
      _isAiScanning = true;
      _isLocating = true;
    });

    // 1. Fetch Location LBS & Live Weather API
    LocationResult? loc;
    try {
      loc = await LocationService.getCurrentLocation();
      if (loc != null && mounted) {
        setState(() {
          _latitude = loc?.latitude;
          _longitude = loc?.longitude;
          if (_spotNameController.text.isEmpty) {
            _spotNameController.text = loc?.spotName ?? '';
          }
        });

        // Query real-time Open-Meteo Weather API based on coordinates
        final weather = await WeatherApiService.getWeather(
          latitude: loc.latitude,
          longitude: loc.longitude,
        );
        if (weather != null && mounted) {
          setState(() {
            _weatherInfo = weather;
            if (_notesController.text.isEmpty) {
              _notesController.text =
                  'Cuaca: ${weather.weatherCodeDescription}, ${weather.temperature}°C, Angin ${weather.windSpeedKmH} km/h. (${weather.spotCondition})';
            }
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLocating = false);

    // 2. AI Vision Scan
    try {
      final scanResult = await AiVisionService.scanFishPhoto(file);
      if (mounted) {
        setState(() {
          _fishNameController.text = scanResult.fishName;
          _weightController.text = scanResult.estimatedWeightKg.toString();
          if (_lureController.text.isEmpty) {
            _lureController.text = scanResult.recommendedLure;
          }
          if (_notesController.text.isEmpty) {
            _notesController.text = scanResult.description;
          }
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isAiScanning = false);

    // 3. Generate Blockchain Proof of Catch
    try {
      final proof = await BlockchainProofService.generateProof(
        photoFile: file,
        userId: _strikeService.currentUserId ?? 'guest_angler',
        fishName: _fishNameController.text.isEmpty ? 'Unknown Catch' : _fishNameController.text,
        weightKg: double.tryParse(_weightController.text) ?? 1.0,
        spotName: _spotNameController.text.isEmpty ? 'Unknown Spot' : _spotNameController.text,
        latitude: _latitude ?? 0.0,
        longitude: _longitude ?? 0.0,
        timestamp: DateTime.now(),
      );
      if (mounted) {
        setState(() => _blockchainProof = proof);
      }
    } catch (_) {}
  }

  Future<void> _saveStrike() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? uploadedPhotoUrl;
      if (_imageFile != null) {
        uploadedPhotoUrl = await _strikeService.uploadPhoto(_imageFile!);
      }

      final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
      final fishName = _fishNameController.text.trim();
      final spotName = _spotNameController.text.trim();

      await _strikeService.addStrike(
        fishName: fishName,
        weightKg: weight,
        spotName: spotName,
        lureName: _lureController.text.trim().isEmpty ? null : _lureController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photoUrl: uploadedPhotoUrl,
        latitude: _latitude,
        longitude: _longitude,
        blockchainHash: _blockchainProof?.txHash,
        blockNumber: _blockchainProof?.blockNumber,
      );

      // Trigger local mobile notification
      await LocalNotificationService.showStrikeNotification(
        fishName: fishName,
        weightKg: weight,
        spotName: spotName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Strike & Blockchain Stamp berhasil dicatat! 🎣⛓️')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0284C7);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF),
      appBar: AppBar(
        title: const Text(
          'Catat Strike Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo & Blockchain Watermark Card
              GestureDetector(
                onTap: _takePhoto,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _imageFile != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(_imageFile!, fit: BoxFit.cover),
                            ),

                            // Scanning overlay
                            if (_isAiScanning || _isLocating)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.black.withValues(alpha: 0.55),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(color: Colors.white),
                                      const SizedBox(height: 12),
                                      Text(
                                        _isLocating ? 'Mendeteksi GPS LBS Spot...' : 'AI Vision Memindai Ikan...',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // Blockchain Proof Stamp Overlay (Polygon Amoy Network)
                            if (_blockchainProof != null)
                              Positioned(
                                top: 12,
                                left: 12,
                                child: InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(_blockchainProof!.explorerUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.9)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.link, color: Colors.purpleAccent, size: 13),
                                            const SizedBox(width: 4),
                                            Text(
                                              'POLYGON AMOY (#${_blockchainProof!.blockNumber})',
                                              style: const TextStyle(
                                                color: Colors.purpleAccent,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Tx: ${_blockchainProof!.shortHash} ↗',
                                          style: const TextStyle(color: Colors.white, fontSize: 8),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                                      onPressed: _takePhoto,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(Icons.photo_library, color: Colors.white),
                                      onPressed: _pickFromGallery,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, size: 40, color: primaryColor),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Foto Hasil Pancingan',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Auto-scan AI, deteksi lokasi GPS & stamp Blockchain',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library, size: 18),
                              label: const Text('Pilih dari Galeri'),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // AI Badge Notification
              if (_fishNameController.text.isNotEmpty && !_isAiScanning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.teal, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI Vision berhasil mendeteksi ikan & GPS spot!',
                          style: TextStyle(color: Colors.teal.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_weatherInfo != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'LBS Cuaca: ${_weatherInfo!.weatherCodeDescription} • ${_weatherInfo!.temperature}°C • Angin ${_weatherInfo!.windSpeedKmH} km/h',
                          style: const TextStyle(color: Color(0xFF0369A1), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Detail Form Cards
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fishNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Ikan *',
                        hintText: 'Misal: Kakap Merah, Gabus, Nila',
                        prefixIcon: Icon(Icons.set_meal_outlined),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Nama ikan wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Berat Tangkapan (Kg) *',
                        hintText: 'Misal: 2.5',
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Berat wajib diisi';
                        if (double.tryParse(val.trim()) == null) return 'Gunakan angka desimal valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _spotNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Spot Mancing *',
                        hintText: 'Misal: Waduk Jatiluhur, Muara Angke',
                        prefixIcon: const Icon(Icons.place_outlined),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_latitude != null)
                              const Tooltip(
                                message: 'GPS Terdeteksi',
                                child: Icon(Icons.my_location, color: Colors.teal, size: 20),
                              ),
                            IconButton(
                              tooltip: 'Pilih Titik di Peta',
                              icon: const Icon(Icons.map, color: primaryColor),
                              onPressed: _pickLocationFromMap,
                            ),
                          ],
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Spot wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lureController,
                      decoration: const InputDecoration(
                        labelText: 'Umpan / Lure (Opsional)',
                        hintText: 'Misal: Soft Frog, Lumut, Udang Hidup',
                        prefixIcon: Icon(Icons.phishing_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan & Analisis AI (Opsional)',
                        hintText: 'Kondisi cuaca, kedalaman air, perjuangan saat strike...',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveStrike,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isLoading ? 'Menyimpan & Menerbitkan Hash...' : 'Simpan Strike Log (PoC)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
