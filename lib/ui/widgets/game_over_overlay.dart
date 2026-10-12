import 'package:flutter/material.dart';
import '../../game/minibonk_game.dart';

class GameOverOverlay extends StatelessWidget {
  final MinibonkGame game;
  final VoidCallback onRestart;
  final VoidCallback? onExit;

  const GameOverOverlay({
    super.key,
    required this.game,
    required this.onRestart,
    this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final m = (game.elapsedTime / 60).floor().toString().padLeft(2, '0');
    final s = (game.elapsedTime % 60).floor().toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.88),
      body: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0B12),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: const Color(0xFFFF1744).withValues(alpha: 0.85),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.85),
                blurRadius: 30,
              ),
              BoxShadow(
                color: const Color(0xFFFF1744).withValues(alpha: 0.25),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    color: const Color(0xFFFF1744),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'SIGNAL LOST // GAME OVER',
                    style: TextStyle(
                      color: Color(0xFFFF1744),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '생체 신호가 소멸되었습니다. 작전에 실패했습니다.',
                style: TextStyle(color: Color(0xFF90A4AE), fontSize: 11.5),
              ),
              const Divider(color: Color(0xFF261822), height: 28),
              _buildStatItem('생존 시간', '$m:$s'),
              _buildStatItem('도달 레벨', 'LV. ${game.playerLevel}'),
              _buildStatItem('처치한 몬스터', '${game.killCount} 마리'),
              _buildStatItem('획득한 골드', '${game.gold} G'),
              const SizedBox(height: 22),
              Row(
                children: [
                  if (onExit != null)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF90A4AE),
                          side: const BorderSide(color: Color(0xFF37474F)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: onExit,
                        child: const Text(
                          '메인 메뉴',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  if (onExit != null) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1744),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: onRestart,
                      child: const Text(
                        '작전 재개 // RESTART',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1.0,
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
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF140F18),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF2B1822), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                color: Color(0xFF90A4AE),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              )),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: 'monospace',
              )),
        ],
      ),
    );
  }
}
