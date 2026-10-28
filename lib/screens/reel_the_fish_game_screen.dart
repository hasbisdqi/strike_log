import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_tokens.dart';
import '../services/game_leaderboard_service.dart';
import 'widgets/game_leaderboard_sheet.dart';

class ReelTheFishGameScreen extends StatefulWidget {
  const ReelTheFishGameScreen({super.key});

  @override
  State<ReelTheFishGameScreen> createState() => _ReelTheFishGameScreenState();
}

class _ReelTheFishGameScreenState extends State<ReelTheFishGameScreen>
    with SingleTickerProviderStateMixin {
  // Game states: 'idle', 'waiting', 'hooked', 'lost', 'caught'
  String _gameState = 'idle';

  // Fishing Hook Core Mechanics
  double _tension = 20.0; // 0..100%
  double _distanceMeters = 40.0; // Starts at 40m
  final double _initialDistance = 40.0;

  // Fish HP & Rage/Hook Gauge
  double _fishHp = 100.0; // 0..100%
  double _hookGauge = 0.0; // 0..100% (Filled by keeping tension in Danger/Sweet spot)
  bool _isFishStunned = false;
  double _stunDurationRemaining = 0.0;

  // Fish State: Normal swim vs Thrashing/Run
  bool _isFishThrashing = false;
  double _fishXOffset = 0.0; // -1.0 to 1.0

  Timer? _gameLoopTimer;
  Timer? _biteWaitTimer;
  Timer? _thrashCycleTimer;

  String _currentFishName = 'Kakap Merah Monster';
  double _currentFishWeight = 5.2;
  String _currentFishAsset = 'assets/fish/kakap_merah.png';
  int _score = 0;

  bool _isReeling = false;
  double _reelRotationAngle = 0.0;

  final Random _rnd = Random();

  final List<Map<String, dynamic>> _fishSpecies = [
    {
      'name': 'Kakap Merah Monster',
      'minW': 3.5,
      'maxW': 8.5,
      'asset': 'assets/fish/kakap_merah.png',
      'power': 1.3,
      'maxHp': 120.0,
    },
    {
      'name': 'Barramundi Petarung',
      'minW': 4.0,
      'maxW': 10.5,
      'asset': 'assets/fish/barramundi.png',
      'power': 1.5,
      'maxHp': 150.0,
    },
    {
      'name': 'Channa Maru Galak',
      'minW': 1.8,
      'maxW': 5.2,
      'asset': 'assets/fish/channa_maru.png',
      'power': 1.1,
      'maxHp': 90.0,
    },
    {
      'name': 'Kerapu Bintang',
      'minW': 3.0,
      'maxW': 7.5,
      'asset': 'assets/fish/kerapu.png',
      'power': 1.4,
      'maxHp': 130.0,
    },
    {
      'name': 'Ikan Nila Super',
      'minW': 0.8,
      'maxW': 2.8,
      'asset': 'assets/fish/nila.png',
      'power': 0.8,
      'maxHp': 70.0,
    },
  ];

  Map<String, dynamic>? _activeFishConfig;
  late AnimationController _waterAnimController;

  @override
  void initState() {
    super.initState();
    _waterAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _biteWaitTimer?.cancel();
    _thrashCycleTimer?.cancel();
    _waterAnimController.dispose();
    super.dispose();
  }

  void _castLine() {
    _biteWaitTimer?.cancel();
    _gameLoopTimer?.cancel();
    _thrashCycleTimer?.cancel();

    HapticFeedback.mediumImpact();

    setState(() {
      _gameState = 'waiting';
      _tension = 15.0;
      _distanceMeters = 40.0;
      _fishHp = 100.0;
      _hookGauge = 0.0;
      _isFishStunned = false;
      _isFishThrashing = false;
      _fishXOffset = 0.0;
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

    _activeFishConfig = fish;

    HapticFeedback.heavyImpact();

    setState(() {
      _gameState = 'hooked';
      _currentFishName = fish['name'] as String;
      _currentFishAsset = fish['asset'] as String;
      _currentFishWeight = double.parse(weight.toStringAsFixed(1));
      _tension = 35.0;
      _distanceMeters = 38.0;
      _fishHp = 100.0;
      _hookGauge = 0.0;
      _isFishStunned = false;
      _isFishThrashing = true;
    });

    // Fish thrash vs calm rhythm
    _thrashCycleTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (!mounted || _gameState != 'hooked') {
        timer.cancel();
        return;
      }
      if (!_isFishStunned) {
        setState(() {
          _isFishThrashing = _rnd.nextDouble() > 0.45;
          _fishXOffset = (_rnd.nextDouble() * 2.0 - 1.0) * 0.75;
        });
        if (_isFishThrashing) {
          HapticFeedback.lightImpact();
        }
      }
    });

    // Physics Engine Loop (Every 40ms = 25 ticks/sec)
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted || _gameState != 'hooked') return;

      final power = (_activeFishConfig?['power'] as double? ?? 1.0);

      setState(() {
        // Handle Stun state
        if (_isFishStunned) {
          _stunDurationRemaining -= 0.04;
          if (_stunDurationRemaining <= 0.0) {
            _isFishStunned = false;
          }
        }

        // 1. Reel Input Handling (Fishing Hook Style)
        if (_isReeling) {
          _reelRotationAngle += 0.35;

          if (_isFishStunned) {
            // When stunned, reel in safely and rapidly without tension blowup
            _tension = min(60.0, _tension + 0.4);
            _distanceMeters = max(0.0, _distanceMeters - 0.45);
            _fishHp = max(0.0, _fishHp - 0.8);
          } else {
            // Normal reeling increases tension
            _tension += 1.8;
            _distanceMeters = max(0.0, _distanceMeters - 0.18);
            _fishHp = max(0.0, _fishHp - 0.35);

            // Fishing Hook Mechanic: Holding in Sweet/Danger zone (68 - 88) charges Hook Gauge!
            if (_tension >= 68.0 && _tension <= 88.0) {
              _hookGauge = min(100.0, _hookGauge + 1.2);
              HapticFeedback.selectionClick();
            }
          }
        } else {
          // Releasing reel drops tension immediately
          _tension = max(5.0, _tension - 1.4);

          // If fish is active, it runs away when angler doesn't reel
          if (!_isFishStunned) {
            final runSpeed = _isFishThrashing ? 0.16 * power : 0.06;
            _distanceMeters = min(_initialDistance * 1.35, _distanceMeters + runSpeed);
          }
        }

        // 2. Fish Thrash Tension Penalty
        if (_isFishThrashing && !_isFishStunned) {
          _tension += (0.65 * power);
        }

        // Haptic warning when approaching snap line
        if (_tension >= 88.0) {
          HapticFeedback.mediumImpact();
        }

        // 3. Lose Conditions
        // Line snapped (Tension over 96%)
        if (_tension >= 96.0) {
          _gameOver(lostReason: 'Senar Putus! Terlalu lama menahan reel di zona merah.');
        }
        // Fish ran too far (> 50m)
        else if (_distanceMeters >= 50.0) {
          _gameOver(lostReason: 'Ikan Lari Terlalu Jauh! Senar spool habis.');
        }

        // 4. Win Conditions
        // Fish brought to boat (distance <= 1.5m) OR Fish HP reaches 0
        if (_distanceMeters <= 1.5 || _fishHp <= 0.0) {
          _gameWin();
        }
      });
    });
  }

  /// Hook Strike (Special Skill when Gauge is 100%)
  void _executeHookStrike() {
    if (_gameState != 'hooked' || _hookGauge < 100.0) return;

    HapticFeedback.heavyImpact();

    setState(() {
      _hookGauge = 0.0;
      _isFishStunned = true;
      _stunDurationRemaining = 3.0; // 3 seconds stun!
      _tension = 35.0; // Drop tension to safe zone
      _fishHp = max(0.0, _fishHp - 25.0); // Big critical hit!
      _distanceMeters = max(0.0, _distanceMeters - 5.0); // Pull 5m immediately
    });
  }

  void _gameOver({required String lostReason}) {
    _gameLoopTimer?.cancel();
    _thrashCycleTimer?.cancel();
    HapticFeedback.heavyImpact();

    setState(() {
      _gameState = 'lost';
      _isReeling = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.broken_image_outlined, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Ikan Terlepas!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Text(lostReason, style: const TextStyle(color: Color(0xFF475569), fontSize: 14)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
    _thrashCycleTimer?.cancel();
    HapticFeedback.heavyImpact();

    final points = (_currentFishWeight * 150).toInt();

    setState(() {
      _gameState = 'caught';
      _isReeling = false;
      _score += points;
    });

    // Auto submit highscore to Supabase
    GameLeaderboardService.submitScore(
      addedScore: points,
      fishName: _currentFishName,
      fishWeight: _currentFishWeight,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3C7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events, color: Color(0xFFD97706), size: 36),
            ),
            const SizedBox(height: 12),
            const Text(
              'STRIKE DIDARATKAN!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Image.asset(
                  _currentFishAsset,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(Icons.phishing, size: 60, color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _currentFishName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              'Bobot: $_currentFishWeight Kg • +$points Poin',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _gameState = 'idle');
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const GameLeaderboardSheet(),
                    );
                  },
                  child: const Text('Peringkat', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() => _gameState = 'idle');
                  },
                  child: const Text('Mancing Lagi', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color tensionColor = const Color(0xFF10B981); // Green safe
    if (_tension > 85) {
      tensionColor = const Color(0xFFEF4444); // Red danger snap
    } else if (_tension >= 68) {
      tensionColor = const Color(0xFFF59E0B); // Amber / Hook charge zone
    }

    final distanceProgress = (1.0 - (_distanceMeters / _initialDistance)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Fishing Hook Simulator', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined, color: AppColors.primary),
            tooltip: 'Papan Peringkat Online',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const GameLeaderboardSheet(),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Score & Fishing Stats Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.military_tech_rounded, color: Color(0xFFF59E0B), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Total Skor: $_score',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _gameState == 'hooked' ? 'JARAK: ${_distanceMeters.toStringAsFixed(1)}M' : 'STANDBY',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fishing Arena Viewport
            Container(
              height: 290,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0369A1).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Top Status Header
                  Positioned(
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isFishStunned
                                ? Icons.flash_on
                                : (_isFishThrashing ? Icons.warning_amber_rounded : Icons.waves),
                            color: _isFishStunned
                                ? const Color(0xFFFACC15)
                                : (_isFishThrashing ? const Color(0xFFEF4444) : const Color(0xFF38BDF8)),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _gameState == 'waiting'
                                ? 'Menunggu sambaran kail...'
                                : _gameState == 'hooked'
                                    ? (_isFishStunned
                                        ? '⚡ IKAN PINGSAN! GULUNG CEPAT!'
                                        : (_isFishThrashing ? 'IKAN BERONTAK! HATI-HATI SENAR' : 'IKAN TENANG - TARIK REEL'))
                                    : 'Lempar kail ke spot',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Center Animation
                  if (_gameState == 'waiting')
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Pelampung bergoyang tenang...',
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  else if (_gameState == 'hooked')
                    AnimatedBuilder(
                      animation: _waterAnimController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            _fishXOffset * 90,
                            sin(_waterAnimController.value * 2 * pi) * (_isFishStunned ? 2 : 10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Fish Image Asset
                              Opacity(
                                opacity: _isFishStunned ? 0.85 : 1.0,
                                child: Image.asset(
                                  _currentFishAsset,
                                  width: 140,
                                  height: 95,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.set_meal, color: Colors.white, size: 70),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Fish HP Bar
                              Container(
                                width: 120,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (_fishHp / 100.0).clamp(0.0, 1.0),
                                        minHeight: 6,
                                        backgroundColor: Colors.white24,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'HP: ${_fishHp.toInt()}%',
                                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phishing, color: Colors.white60, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Tekan tombol Lempar Kail di bawah\nuntuk memulai pertarungan!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),

                  // Distance Progress Bottom
                  if (_gameState == 'hooked')
                    Positioned(
                      bottom: 12,
                      left: 18,
                      right: 18,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Target Mendarat', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                Text(
                                  'Sisa ${_distanceMeters.toStringAsFixed(1)} m',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: distanceProgress,
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fishing Hook Tension Arc & Gauge Meter
            if (_gameState == 'hooked') ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tegangan Senar (Tension Meter)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          '${_tension.toInt()}%',
                          style: TextStyle(fontWeight: FontWeight.w800, color: tensionColor, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_tension / 100.0).clamp(0.0, 1.0),
                        minHeight: 14,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(tensionColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Aman (<65%)', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                        Text('⚡ Hook Charge (68-88%)', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.w800)),
                        Text('Putus (>95%)', style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Hook Strike Gauge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt_rounded, color: Color(0xFFEAB308), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'HOOK STUN GAUGE',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        Text(
                          _hookGauge >= 100.0 ? 'SIAP DISIKAT! ⚡' : '${_hookGauge.toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _hookGauge >= 100.0 ? const Color(0xFFEAB308) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_hookGauge / 100.0).clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEAB308)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Fishing Hook Big Interactive Controls
            if (_gameState == 'idle')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _castLine,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: const Text('Lempar Kail (Cast Line)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              )
            else if (_gameState == 'hooked')
              Row(
                children: [
                  // Hook Skill Strike Button
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(
                          color: _hookGauge >= 100.0 ? const Color(0xFFEAB308) : const Color(0xFFE2E8F0),
                          width: 2,
                        ),
                        backgroundColor: _hookGauge >= 100.0 ? const Color(0xFFFEF3C7) : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: _hookGauge >= 100.0 ? _executeHookStrike : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flash_on_rounded,
                            color: _hookGauge >= 100.0 ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'HOOK STRIKE',
                            style: TextStyle(
                              color: _hookGauge >= 100.0 ? const Color(0xFF92400E) : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Giant Reel Button (Hold to Reel ala Fishing Hook)
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _isReeling = true),
                      onTapUp: (_) => setState(() => _isReeling = false),
                      onTapCancel: () => setState(() => _isReeling = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: _isReeling ? const Color(0xFF0369A1) : AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: _reelRotationAngle,
                              child: const Icon(Icons.motion_photos_on_rounded, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _isReeling ? 'TARIK TERUS!' : 'TAHAN REEL',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
