import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/glass_card.dart';

class ReelTheFishGameScreen extends StatefulWidget {
  const ReelTheFishGameScreen({super.key});

  @override
  State<ReelTheFishGameScreen> createState() => _ReelTheFishGameScreenState();
}

class _ReelTheFishGameScreenState extends State<ReelTheFishGameScreen> {
  // Game states: 'idle', 'waiting', 'hooked', 'lost', 'caught'
  String _gameState = 'idle';

  double _tension = 50.0; // 0..100
  double _progress = 0.0; // 0..100%
  Timer? _gameLoopTimer;
  Timer? _biteWaitTimer;

  String _currentFishName = '';
  double _currentFishWeight = 0.0;
  int _score = 0;

  final Random _rnd = Random();

  final List<Map<String, dynamic>> _fishSpecies = [
    {'name': 'Ikan Kakap Merah Monster', 'minW': 3.5, 'maxW': 8.0},
    {'name': 'Ikan Channa Maru Galak', 'minW': 2.0, 'maxW': 5.5},
    {'name': 'Ikan Nila Raksasa', 'minW': 1.2, 'maxW': 3.0},
    {'name': 'Ikan Barramundi Petarung', 'minW': 4.0, 'maxW': 10.0},
    {'name': 'Ikan Kerapu Bintang', 'minW': 3.0, 'maxW': 7.5},
  ];

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _biteWaitTimer?.cancel();
    super.dispose();
  }

  void _castLine() {
    _biteWaitTimer?.cancel();
    _gameLoopTimer?.cancel();

    setState(() {
      _gameState = 'waiting';
      _tension = 50.0;
      _progress = 10.0;
    });

    final delaySeconds = 2 + _rnd.nextInt(3);
    _biteWaitTimer = Timer(Duration(seconds: delaySeconds), () {
      if (!mounted) return;
      _fishBite();
    });
  }

  void _fishBite() {
    final fish = _fishSpecies[_rnd.nextInt(_fishSpecies.length)];
    final minW = fish['minW'] as double;
    final maxW = fish['maxW'] as double;
    final weight = minW + (_rnd.nextDouble() * (maxW - minW));

    setState(() {
      _gameState = 'hooked';
      _currentFishName = fish['name'] as String;
      _currentFishWeight = double.parse(weight.toStringAsFixed(1));
      _tension = 50.0;
      _progress = 20.0;
    });

    // Start fight game loop
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;

      setState(() {
        // Fish fights back: tension pulls up or slack drops
        final jitter = (_rnd.nextDouble() * 6.0) - 2.5;
        _tension = (_tension + jitter).clamp(0.0, 100.0);

        // Natural line tension drain if not reeling
        _tension = (_tension - 0.3).clamp(0.0, 100.0);

        // Tension thresholds:
        // Too tight (> 92): line snaps
        // Too loose (< 8): fish unhooks
        if (_tension >= 95.0) {
          _gameOver(lostReason: 'Senar Putus! Tarikan terlalu tegang.');
        } else if (_tension <= 5.0) {
          _gameOver(lostReason: 'Ikan Lepas! Senar terlalu kendur.');
        }

        // Win condition
        if (_progress >= 100.0) {
          _gameWin();
        }
      });
    });
  }

  void _reelIn() {
    if (_gameState != 'hooked') return;

    setState(() {
      _tension = (_tension + 6.5).clamp(0.0, 100.0);
      _progress = (_progress + 3.5).clamp(0.0, 100.0);
    });
  }

  void _releaseDrag() {
    if (_gameState != 'hooked') return;

    setState(() {
      _tension = (_tension - 8.0).clamp(0.0, 100.0);
    });
  }

  void _gameOver({required String lostReason}) {
    _gameLoopTimer?.cancel();
    setState(() {
      _gameState = 'lost';
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.sentiment_dissatisfied, color: AppColors.error),
            SizedBox(width: AppSpacing.sm),
            Text('Ikan Lolos!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(lostReason),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _gameState = 'idle');
            },
            child: const Text('Lempar Umpan Lagi'),
          ),
        ],
      ),
    );
  }

  void _gameWin() {
    _gameLoopTimer?.cancel();
    final points = (_currentFishWeight * 100).toInt();

    setState(() {
      _gameState = 'caught';
      _score += points;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: AppColors.amberAccent),
            SizedBox(width: AppSpacing.sm),
            Text('BERHASIL STRIKE!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kamu berhasil mendaratkan:', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            Text(_currentFishName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Bobot: $_currentFishWeight Kg', style: const TextStyle(color: AppColors.tealAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Bonus Skor: +$points Poin 🏆', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _gameState = 'idle');
            },
            child: const Text('Lanjut Mancing'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color tensionColor = AppColors.primary;
    if (_tension > 75) tensionColor = AppColors.error;
    if (_tension < 25) tensionColor = AppColors.amberAccent;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mini Game: Reel The Fish', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Score Board
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              borderRadius: AppRadius.xl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sports_esports, color: AppColors.primary),
                      SizedBox(width: AppSpacing.sm),
                      Text('Angler Arcade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Skor: $_score',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Fishing Water Arena
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                gradient: const LinearGradient(
                  colors: [Color(0xFF38BDF8), Color(0xFF0369A1), Color(0xFF075985)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fishing rod / boat silhouette
                  Positioned(
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _gameState == 'hooked' ? Icons.warning_rounded : Icons.phishing,
                            color: _gameState == 'hooked' ? AppColors.amberAccent : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _gameState == 'waiting'
                                ? 'Menunggu sambaran ikan...'
                                : _gameState == 'hooked'
                                    ? 'STRIKE! $_currentFishName ($_currentFishWeight Kg)'
                                    : 'Siap melempar joran',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center Animation/Icon
                  if (_gameState == 'waiting')
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: AppSpacing.md),
                        Text('Pelampung bergoyang di air...', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ],
                    )
                  else if (_gameState == 'hooked')
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.set_meal, color: Colors.white, size: 68),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: const Text('TARIKAN AGRESIF!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    )
                  else
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.waves, color: Colors.white70, size: 60),
                        SizedBox(height: 8),
                        Text('Perairan tenang. Ayo lempar umpanmu!', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),

                  // Reel Progress Bar
                  if (_gameState == 'hooked')
                    Positioned(
                      bottom: 14,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Jarak Menuju Kapal', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              Text('${_progress.toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: _progress / 100.0,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Line Tension Meter
            if (_gameState == 'hooked') ...[
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                borderRadius: AppRadius.xl,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tegangan Senar (Line Tension)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          '${_tension.toInt()}%',
                          style: TextStyle(fontWeight: FontWeight.bold, color: tensionColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: _tension / 100.0,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(tensionColor),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kendur (Lepas)', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        Text('Aman (25-75%)', style: TextStyle(color: AppColors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('Tegang (Putus)', style: TextStyle(color: AppColors.error, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Action Buttons
            if (_gameState == 'idle')
              ElevatedButton.icon(
                onPressed: _castLine,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Lempar Umpan (Cast Line)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )
            else if (_gameState == 'hooked')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.amberAccent, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      onPressed: _releaseDrag,
                      icon: const Icon(Icons.rotate_left, color: AppColors.amberAccent),
                      label: const Text('Kendurkan Drag', style: TextStyle(color: AppColors.amberAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: _reelIn,
                      icon: const Icon(Icons.refresh),
                      label: const Text('GULUNG REEL!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: AppSpacing.bottomNavPadding),
          ],
        ),
      ),
    );
  }
}
