import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/database_service.dart';
import '../services/web3_ai_service.dart';
import '../models/catch_model.dart';
import 'logbook_screen.dart';
import 'ai_scanner_screen.dart';
import 'spot_map_screen.dart';
import 'game_web3_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _username = 'Angler';
  List<CatchLog> _recentCatches = [];
  bool _isLoading = true;

  // Sensor Stream Data
  double _magnetometerX = 0.0;
  double _magnetometerY = 0.0;
  double _magnetometerZ = 0.0;
  StreamSubscription? _magSub;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCatches();
    _initSensors();
  }

  void _initSensors() {
    try {
      _magSub = magnetometerEvents.listen((MagnetometerEvent event) {
        if (mounted) {
          setState(() {
            _magnetometerX = event.x;
            _magnetometerY = event.y;
            _magnetometerZ = event.z;
          });
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _magSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Muhammad Hasbi Assidiqi';
    });
  }

  Future<void> _loadCatches() async {
    final list = await DatabaseService.instance.getAllCatches();
    setState(() {
      _recentCatches = list;
      _isLoading = false;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari sesi StrikeLog?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!mounted) return;
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody() {
    return RefreshIndicator(
      onRefresh: _loadCatches,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.teal.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selamat Memancing,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text(
                            _username,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.amber.shade700, borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              'Reward: \${Web3SolanaService.tokenRewardBalance.toStringAsFixed(1)} STRIKE',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white70),
                      onPressed: _showLogoutDialog,
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Live Weather & Barometer Widget (Solunar Forecast)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('Kondisi Spot & Cuaca Maritim', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(8)),
                          child: const Text('Rating: Sangat Baik (4.8/5)', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricItem(Icons.speed, '1013.2 hPa', 'Tekanan Udara'),
                        _buildMetricItem(Icons.water, 'Pasang 0.8m', 'Pasang Surut'),
                        _buildMetricItem(Icons.nightlight_round, 'Bulan Sabit', 'Fase Solunar'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Live Compass Sensor Bar
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.explore, color: Colors.teal, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sensor Kompas (Magnetometer): X:\${_magnetometerX.toStringAsFixed(1)} Y:\${_magnetometerY.toStringAsFixed(1)} Z:\${_magnetometerZ.toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 10, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section Tangkapan Terkini
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tangkapan Terkini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 1),
                  child: const Text('Lihat Semua Log'),
                ),
              ],
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_recentCatches.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Belum ada log tangkapan. Catat sekarang!')),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentCatches.length > 3 ? 3 : _recentCatches.length,
                itemBuilder: (context, index) {
                  final item = _recentCatches[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.teal,
                        child: Icon(Icons.phishing, color: Colors.white),
                      ),
                      title: Text(item.fishSpecies, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('\${item.weight} kg | \${item.length} cm | Umpan: \${item.bait}\n\${item.locationName}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardBody(),
      LogbookScreen(onCatchesChanged: _loadCatches),
      const AiScannerScreen(),
      const SpotMapScreen(),
      const GameWeb3Screen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('StrikeLog Mobile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifikasi: Waktu pasang laut Sadeng diprediksi pukul 17:30 WIB.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Logbook'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'AI Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Spot Peta'),
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Trophy & Web3'),
        ],
      ),
    );
  }
}
