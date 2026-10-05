import 'package:flutter/material.dart';
import '../models/catch_model.dart';
import '../services/database_service.dart';

class LogbookScreen extends StatefulWidget {
  final VoidCallback onCatchesChanged;
  const LogbookScreen({super.key, required this.onCatchesChanged});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  List<CatchLog> _allCatches = [];
  List<CatchLog> _filteredCatches = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCatches();
  }

  Future<void> _fetchCatches() async {
    final list = await DatabaseService.instance.getAllCatches();
    setState(() {
      _allCatches = list;
      _filteredCatches = list;
      _isLoading = false;
    });
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      setState(() => _filteredCatches = _allCatches);
    } else {
      setState(() {
        _filteredCatches = _allCatches.where((item) {
          final q = query.toLowerCase();
          return item.fishSpecies.toLowerCase().contains(q) ||
              item.locationName.toLowerCase().contains(q) ||
              item.bait.toLowerCase().contains(q);
        }).toList();
      });
    }
  }

  Future<void> _showAddCatchDialog() async {
    final speciesCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final lengthCtrl = TextEditingController();
    final baitCtrl = TextEditingController();
    final locCtrl = TextEditingController(text: 'Pantai Sadeng, DIY');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catat Tangkapan Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: speciesCtrl, decoration: const InputDecoration(labelText: 'Spesies Ikan')),
              TextField(
                controller: weightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Berat (kg)'),
              ),
              TextField(
                controller: lengthCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Panjang (cm)'),
              ),
              TextField(controller: baitCtrl, decoration: const InputDecoration(labelText: 'Umpan yang Dipakai')),
              TextField(controller: locCtrl, decoration: const InputDecoration(labelText: 'Nama Lokasi / Spot')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? 0.0;
              final length = double.tryParse(lengthCtrl.text.replaceAll(',', '.')) ?? 0.0;

              if (speciesCtrl.text.isNotEmpty && weight > 0) {
                final newLog = CatchLog(
                  fishSpecies: speciesCtrl.text.trim(),
                  weight: weight,
                  length: length,
                  bait: baitCtrl.text.trim(),
                  locationName: locCtrl.text.trim(),
                  latitude: -8.1908,
                  longitude: 110.8017,
                  timestamp: DateTime.now().toIso8601String(),
                  txHash: '0xSol_' + DateTime.now().millisecondsSinceEpoch.toString(),
                );
                await DatabaseService.instance.insertCatch(newLog);
                widget.onCatchesChanged();
                _fetchCatches();
                if (!mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Log tangkapan berhasil disimpan ke SQLite!')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              decoration: InputDecoration(
                hintText: 'Cari spesies, lokasi, atau umpan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCatches.isEmpty
                      ? const Center(child: Text('Tidak ada log tangkapan yang cocok.'))
                      : ListView.builder(
                          itemCount: _filteredCatches.length,
                          itemBuilder: (context, index) {
                            final item = _filteredCatches[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Icon(Icons.phishing, color: Colors.white),
                                ),
                                title: Text(item.fishSpecies, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Berat: ' + item.weight.toString() + ' kg | Panjang: ' + item.length.toString() + ' cm\nSpot: ' + item.locationName + '\nTx: ' + (item.txHash ?? '-')),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () async {
                                    if (item.id != null) {
                                      await DatabaseService.instance.deleteCatch(item.id!);
                                      widget.onCatchesChanged();
                                      _fetchCatches();
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCatchDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
