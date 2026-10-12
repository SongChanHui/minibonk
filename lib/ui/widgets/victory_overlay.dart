import 'package:flutter/material.dart';
import '../../game/minibonk_game.dart';

class VictoryOverlay extends StatelessWidget {
  final MinibonkGame game;
  final VoidCallback onRestart;
  final VoidCallback? onExit;

  const VictoryOverlay({
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
          width: 460,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0E09),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.85),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.85),
                blurRadius: 30,
              ),
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.28),
                blurRadius: 22,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFFFD700),
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'MISSION COMPLETE // VICTORY',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '3스테이지 최종 보스를 제압하고 전장을 평정했습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 11.5),
              ),
              const Divider(color: Color(0xFF2E2916), height: 26),
              _buildStatItem('총 클리어 시간', '$m:$s'),
              _buildStatItem('최종 레벨', 'LV. ${game.playerLevel}'),
              _buildStatItem('총 처치 수', '${game.killCount} 마리'),
              _buildStatItem('누적 골드', '${game.gold} G'),
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
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: const Color(0xFF0F0E09),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: onRestart,
                      child: const Text(
                        '새로운 여정 시작 // REPLAY',
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
        color: const Color(0xFF17150E),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF332B14), width: 1.0),
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
