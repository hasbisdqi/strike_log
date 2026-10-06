import 'package:flutter/material.dart';
import 'dart:math';
import '../services/web3_ai_service.dart';

class GameWeb3Screen extends StatefulWidget {
  const GameWeb3Screen({super.key});

  @override
  State<GameWeb3Screen> createState() => _GameWeb3ScreenState();
}

class _GameWeb3ScreenState extends State<GameWeb3Screen> {
  int _score = 0;
  bool _isPlaying = false;
  String _targetAction = 'Tekan "Lempar Umpan"';
  String _lastCertificate = '';
  bool _canStrikeNow = false;

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _canStrikeNow = false;
      _targetAction = 'Menunggu umpan disambar ikan...';
    });

    final delay = 1200 + Random().nextInt(1800);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted && _isPlaying) {
        setState(() {
          _canStrikeNow = true;
          _targetAction = '⚡ STRIKE SEKARANG! TARIK JORAN! ⚡';
        });
      }
    });
  }

  void _handleStrikeTap() {
    if (_canStrikeNow) {
      setState(() {
        _score += 100;
        _targetAction = 'IKAN BERHASIL NAIK! (+100 Poin)';
        _isPlaying = false;
        _canStrikeNow = false;
        Web3SolanaService.addReward(5.0);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Strike Berhasil! +100 Poin dan +5.0 STRIKE Reward Token masuk dompet!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _targetAction = 'Terlalu Cepat! Umpan Lepas.';
        _isPlaying = false;
        _canStrikeNow = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Umpan ditarik terlalu cepat, ikan kabur!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _mintWeb3Certificate() {
    final cert = Web3SolanaService.generateCatchCertificateHash('Ikan Tawes Sirip Merah', 2.4);
    setState(() => _lastCertificate = cert);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sertifikat Tangkapan Berhasil di-Mint ke Solana Devnet!'),
        backgroundColor: Colors.purple,
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
            // Web3 Solana Wallet Section
            Card(
              color: Colors.purple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Solana Devnet Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple)),
                        Icon(Icons.account_balance_wallet, color: Colors.purple),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Public Address:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    SelectableText(
                      Web3SolanaService.walletAddress,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Saldo Token: ${Web3SolanaService.tokenRewardBalance.toStringAsFixed(1)} STRIKE',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        ElevatedButton(
                          onPressed: _mintWeb3Certificate,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                          child: const Text('Mint Certificate NFT'),
                        ),
                      ],
                    ),
                    if (_lastCertificate.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Tx Hash: $_lastCertificate', style: const TextStyle(fontSize: 10, color: Colors.purple)),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mini Game Strike Reflex
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text('Strike Reflex Challenge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                    const Text('Uji kecepatan refleks saat ikan memakan umpan.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade400),
                      ),
                      child: Text(
                        'Total Skor: $_score Poin',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: _canStrikeNow ? Colors.red.shade100 : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _canStrikeNow ? Colors.red : Colors.teal),
                      ),
                      child: Text(
                        _targetAction,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _canStrikeNow ? Colors.red.shade900 : Colors.teal.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isPlaying ? null : _startGame,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Lempar Umpan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isPlaying ? _handleStrikeTap : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canStrikeNow ? Colors.red : Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('TARIK JORAN!'),
                          ),
                        ),
                      ],
                    ),
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
