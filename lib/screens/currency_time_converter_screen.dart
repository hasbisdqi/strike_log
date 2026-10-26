import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';
import '../services/converter_service.dart';

class CurrencyTimeConverterScreen extends StatefulWidget {
  const CurrencyTimeConverterScreen({super.key});

  @override
  State<CurrencyTimeConverterScreen> createState() => _CurrencyTimeConverterScreenState();
}

class _CurrencyTimeConverterScreenState extends State<CurrencyTimeConverterScreen> {
  final _amountController = TextEditingController(text: '100000');
  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  Map<String, double> _rates = {
    'IDR': 1.0,
    'USD': 16250.0,
    'JPY': 105.0,
    'EUR': 17400.0,
  };
  bool _isLoadingRates = false;

  // Time conversion
  Timer? _clockTimer;
  DateTime _currentUtc = DateTime.now().toUtc();
  String _selectedZone = 'WIB (UTC+7)';

  final List<String> _currencies = ['IDR', 'USD', 'JPY', 'EUR'];
  final List<String> _timeZones = [
    'WIB (UTC+7)',
    'WITA (UTC+8)',
    'WIT (UTC+9)',
    'London GMT (UTC+0)',
  ];

  @override
  void initState() {
    super.initState();
    _loadRates();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentUtc = DateTime.now().toUtc());
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() => _isLoadingRates = true);
    final rates = await ConverterService.fetchLatestRates();
    if (mounted) {
      setState(() {
        _rates = rates;
        _isLoadingRates = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputVal = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0.0;
    final convertedCurrency = ConverterService.convertCurrency(
      amount: inputVal,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
      rates: _rates,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Konversi Uang & Waktu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // CURRENCY CONVERTER CARD
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.payments_outlined, color: AppColors.primary),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Kalkulator Logistik & Alat (4 Kurs)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      if (_isLoadingRates)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                          onPressed: _loadRates,
                          tooltip: 'Update Kurs',
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Amount input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Nominal Biaya / Harga Alat',
                      prefixIcon: Icon(Icons.calculate_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Currency picker row
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _fromCurrency,
                          decoration: const InputDecoration(labelText: 'Dari'),
                          items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _fromCurrency = v);
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward, color: AppColors.textMuted),
                      ),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _toCurrency,
                          decoration: const InputDecoration(labelText: 'Ke'),
                          items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _toCurrency = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Result Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Hasil Konversi:',
                          style: TextStyle(fontSize: 12, color: AppColors.primaryDark.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_toCurrency ${convertedCurrency.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // TIME ZONE CONVERTER CARD
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.xl),
              borderRadius: AppRadius.xxl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.schedule, color: AppColors.tealAccent),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Konversi Waktu Memancing (4 Zona)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    value: _selectedZone,
                    decoration: const InputDecoration(labelText: 'Pilih Zona Target'),
                    items: _timeZones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedZone = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Clock display for chosen zone
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Builder(
                      builder: (_) {
                        final zoneTime = ConverterService.convertTimeZone(_currentUtc, _selectedZone);
                        final timeStr = DateFormat('HH:mm:ss').format(zoneTime);
                        final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(zoneTime);

                        return Column(
                          children: [
                            Text(
                              _selectedZone,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateStr,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Mini All-Zone Table
                  Column(
                    children: _timeZones.map((tz) {
                      final t = ConverterService.convertTimeZone(_currentUtc, tz);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(tz, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            Text(
                              DateFormat('HH:mm:ss').format(t),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.bottomNavPadding),
          ],
        ),
      ),
    );
  }
}
