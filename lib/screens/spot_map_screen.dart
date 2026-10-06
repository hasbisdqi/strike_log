import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/catch_model.dart';

class SpotMapScreen extends StatefulWidget {
  const SpotMapScreen({super.key});

  @override
  State<SpotMapScreen> createState() => _SpotMapScreenState();
}

class _SpotMapScreenState extends State<SpotMapScreen> {
  Position? _currentPosition;
  bool _loadingLocation = false;

  final List<FishingSpot> _spots = [
    FishingSpot(name: 'Pantai Sadeng (Tebing Karang)', type: 'Air Asin / Laut', latitude: -8.1908, longitude: 110.8017, bestTime: 'Subuh & Sore', rating: 4.9),
    FishingSpot(name: 'Waduk Sermo Kulon Progo', type: 'Air Tawar', latitude: -7.8286, longitude: 110.1219, bestTime: 'Pagi Hari', rating: 4.7),
    FishingSpot(name: 'Muara Sungai Progo', type: 'Muara / Payau', latitude: -7.9814, longitude: 110.2039, bestTime: 'Menjelang Pasang', rating: 4.6),
    FishingSpot(name: 'Dermaga Pantai Baron', type: 'Air Asin / Karang', latitude: -8.1289, longitude: 110.5489, bestTime: 'Malam Hari', rating: 4.8),
  ];

  Future<void> _getCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = pos;
        _loadingLocation = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lokasi GPS Terkunci: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}')),
      );
    } catch (e) {
      setState(() => _loadingLocation = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPS Info: Menggunakan koordinat default DIY (${e.toString()})')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.my_location, color: Colors.teal),
                title: const Text('GPS Navigator Angler', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  _currentPosition != null
                      ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)} | Long: ${_currentPosition!.longitude.toStringAsFixed(4)}'
                      : 'Tekan tombol untuk deteksi koordinat GPS saat ini',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: _loadingLocation
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : ElevatedButton(
                        onPressed: _getCurrentLocation,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        child: const Text('GPS'),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Rekomendasi Spot Mancing Terdekat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _spots.length,
                itemBuilder: (context, index) {
                  final spot = _spots[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: spot.type.contains('Laut') ? Colors.blue.shade100 : Colors.green.shade100,
                        child: Icon(spot.type.contains('Laut') ? Icons.waves : Icons.water, color: Colors.teal),
                      ),
                      title: Text(spot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Tipe: ${spot.type} | Waktu Ideal: ${spot.bestTime}\nKoordinat: ${spot.latitude}, ${spot.longitude}'),
                      isThreeLine: true,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Text('★ ${spot.rating}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
