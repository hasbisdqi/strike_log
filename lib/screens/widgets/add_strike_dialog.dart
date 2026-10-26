import 'package:flutter/material.dart';
import '../../models/strike_model.dart';
import '../../services/strike_service.dart';

class AddStrikeDialog extends StatefulWidget {
  const AddStrikeDialog({super.key});

  @override
  State<AddStrikeDialog> createState() => _AddStrikeDialogState();
}

class _AddStrikeDialogState extends State<AddStrikeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fishNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _spotNameController = TextEditingController();
  final _lureController = TextEditingController();
  final _notesController = TextEditingController();
  final _strikeService = StrikeService();
  bool _isLoading = false;

  @override
  void dispose() {
    _fishNameController.dispose();
    _weightController.dispose();
    _spotNameController.dispose();
    _lureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
      await _strikeService.addStrike(
        fishName: _fishNameController.text.trim(),
        weightKg: weight,
        spotName: _spotNameController.text.trim(),
        lureName: _lureController.text.trim().isEmpty ? null : _lureController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (!mounted) return;
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
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.phishing, color: Color(0xFF0284C7)),
          SizedBox(width: 8),
          Text('Catat Strike Baru'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fishNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Ikan *',
                  hintText: 'Misal: Ikan Gabus, Nila',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Nama ikan wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Berat (Kg) *',
                  hintText: 'Misal: 1.5',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Berat wajib diisi';
                  if (double.tryParse(val.trim()) == null) return 'Gunakan angka desimal';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _spotNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Spot Mancing *',
                  hintText: 'Misal: Waduk Jatiluhur',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Spot wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lureController,
                decoration: const InputDecoration(
                  labelText: 'Umpan / Lure (Opsional)',
                  hintText: 'Misal: Soft Frog, Lumut, Pelet',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Catatan Tambahan (Opsional)',
                  hintText: 'Kondisi air, cuaca, dll.',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
