import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../game/minibonk_game.dart';

class PauseOverlay extends StatelessWidget {
  final MinibonkGame game;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseOverlay({
    super.key,
    required this.game,
    required this.onRestart,
    required this.onExit,
  });

  String _formatTime(double seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          game.resumeGame();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 560),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF090D17).withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Header (Sharp High-tech)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.pause,
                          color: Color(0xFF00E5FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'SYSTEM PAUSED // 일시정지',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFF162033), height: 1),
                  const SizedBox(height: 16),

                  // Run Info Grid (Sharp Bevel Look)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D121F),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF1E2A40), width: 1.0),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoStat(
                              label: '스테이지',
                              value: 'Stage ${game.currentStage}',
                              color: const Color(0xFFFFD54F),
                            ),
                            _buildInfoStat(
                              label: '생존 시간',
                              value: _formatTime(game.elapsedTime),
                              color: Colors.white,
                            ),
                            _buildInfoStat(
                              label: '레벨',
                              value: 'Lv. ${game.playerLevel}',
                              color: const Color(0xFF00E5FF),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoStat(
                              label: '처치 수 (KILLS)',
                              value: '${game.killCount}',
                              color: const Color(0xFFFF5252),
                            ),
                            _buildInfoStat(
                              label: '보유 골드',
                              value: '${game.gold} G',
                              color: const Color(0xFFFFD700),
                            ),
                            _buildInfoStat(
                              label: '남은 리롤/스킵',
                              value: '${game.rerollCount} / ${game.skipCount}',
                              color: const Color(0xFF00E676),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Equipped Weapons & Cards preview
                  if (game.inventory.equippedWeapons.isNotEmpty ||
                      game.inventory.equippedCards.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'EQUIPPED LOADOUT (${game.inventory.equippedWeapons.length + game.inventory.equippedCards.length})',
                        style: const TextStyle(
                          color: Color(0xFF78909C),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...game.inventory.equippedWeapons.map((w) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101726),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              '${w.nameKo} Lv.${w.level}',
                              style: const TextStyle(
                                color: Color(0xFFE0F7FA),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                        ...game.inventory.equippedCards.map((c) {
                          final lvl = game.inventory.cardLevels[c.id] ?? 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF101726),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              '${c.nameKo} Lv.$lvl',
                              style: const TextStyle(
                                color: Color(0xFFFFF8E1),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Action Buttons (Sharp & High-Tech)
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5FF),
                        foregroundColor: const Color(0xFF060911),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => game.resumeGame(),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: const Text(
                        'RESUME // 계속하기! (ESC)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFD54F),
                            side: const BorderSide(
                              color: Color(0xFFFFD54F),
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            game.resumeGame();
                            onRestart();
                          },
                          icon: const Icon(Icons.restart_alt, size: 16),
                          label: const Text(
                            '다시 시작',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF5252),
                            side: const BorderSide(
                              color: Color(0xFFFF5252),
                              width: 1.2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: () {
                            game.resumeGame();
                            onExit();
                          },
                          icon: const Icon(Icons.home, size: 16),
                          label: const Text(
                            '메인 메뉴',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF78909C),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
