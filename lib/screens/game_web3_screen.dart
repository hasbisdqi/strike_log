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
  String _targetAction = 'Tunggu...';
  String _lastCertificate = '';

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _targetAction = 'SIAP-SIAP TARIK JORAN!';
    });

    Future.delayed(Duration(milliseconds: 1500 + Random().nextInt(2000)), () {
      if (mounted && _isPlaying) {
        setState(() => _targetAction = 'STRIKE SEKARANG!');
      }
    });
  }

  void _handleStrikeTap() {
    if (_targetAction == 'STRIKE SEKARANG!') {
      setState(() {
        _score += 100;
        _targetAction = 'IKAN BERHASIL NAIK (+100 Poin)';
        _isPlaying = false;
        Web3SolanaService.addReward(5.0);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mantap! Skor bertambah dan dapat +5.0 STRIKE Reward Token!')),
      );
    } else {
      setState(() {
        _targetAction = 'Terlalu Cepat! Umpan Lepas.';
        _isPlaying = false;
      });
    }
  }

  void _mintWeb3Certificate() {
    final cert = Web3SolanaService.generateCatchCertificateHash('Ikan Marlin Raksasa', 12.8);
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
                        Text('Saldo Token: ${Web3SolanaService.tokenRewardBalance.toStringAsFixed(1)} STRIKE', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    Text('Total Skor: $_score', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: _targetAction.contains('STRIKE') ? Colors.red.shade100 : Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _targetAction.contains('STRIKE') ? Colors.red : Colors.teal),
                      ),
                      child: Text(
                        _targetAction,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _targetAction.contains('STRIKE') ? Colors.red : Colors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isPlaying ? null : _startGame,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade700, foregroundColor: Colors.white),
                            child: const Text('Mulai Lempar Umpan'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isPlaying ? _handleStrikeTap : null,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
