import 'package:flutter/material.dart';
import '../../game/components/drop_item.dart';
import '../../game/components/field_object.dart';
import '../../game/components/monster.dart';
import '../../game/components/projectile.dart';
import '../../game/minibonk_game.dart';

class DebugOverlay extends StatefulWidget {
  final MinibonkGame game;

  const DebugOverlay({super.key, required this.game});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  Offset _panelPosition = const Offset(20, 80);
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return AnimatedBuilder(
      animation: game.hudNotifier,
      builder: (context, _) {
        final monstersCount =
            game.world.children.whereType<MonsterComponent>().length;
        final projectilesCount =
            game.world.children.whereType<Projectile>().length;
        final dropsCount = game.world.children.whereType<DropItem>().length;
        final objectsCount =
            game.world.children.whereType<FieldObjectComponent>().length;

        return Positioned(
          left: _panelPosition.dx,
          top: _panelPosition.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _panelPosition += details.delta;
              });
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 330,
                decoration: BoxDecoration(
                  color: const Color(0xFF090D16).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.85),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.75),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.18),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Bar (Draggable Header) - Sharp & Luxurious
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF101726),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(3),
                          topRight: Radius.circular(3),
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF1E2A40),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: const Color(0xFF00E5FF)
                                    .withValues(alpha: 0.4),
                                width: 1.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.terminal,
                              color: Color(0xFF00E5FF),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'SYS.CONSOLE // F1',
                              style: TextStyle(
                                color: Color(0xFFE0F7FA),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isCollapsed = !_isCollapsed;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                _isCollapsed
                                    ? Icons.unfold_more
                                    : Icons.unfold_less,
                                color: const Color(0xFF90A4AE),
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => game.toggleDebugOverlay(),
                            child: const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(
                                Icons.close,
                                color: Color(0xFFFF5252),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (!_isCollapsed) ...[
                      // Performance & Live Telemetry
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        color: const Color(0xFF060910),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMetricTag(
                                  label: 'FPS',
                                  value: game.currentFps.toStringAsFixed(1),
                                  color: const Color(0xFF00E676),
                                ),
                                _buildMetricTag(
                                  label: 'SCALE',
                                  value: '${game.gameTimeScale.toStringAsFixed(1)}x',
                                  color: const Color(0xFFFFD54F),
                                ),
                                _buildMetricTag(
                                  label: 'MODE',
                                  value: game.isGodMode ? 'GOD:ON' : 'NORMAL',
                                  color: game.isGodMode
                                      ? const Color(0xFFFF5252)
                                      : const Color(0xFF78909C),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0B101C),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: const Color(0xFF162033),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'ENTITIES',
                                    style: TextStyle(
                                      color: const Color(0xFF00E5FF)
                                          .withValues(alpha: 0.8),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    'M:$monstersCount  P:$projectilesCount  D:$dropsCount  O:$objectsCount',
                                    style: const TextStyle(
                                      color: Color(0xFFCFD8DC),
                                      fontSize: 9.5,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'COORD: [${game.player.position.x.round()}, ${game.player.position.y.round()}]',
                                style: const TextStyle(
                                  color: Color(0xFF546E7A),
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Debug Actions
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Section: Player & Economy
                            _buildSectionHeader('PLAYER & ECONOMY', const Color(0xFF00E5FF)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                _buildDebugBtn(
                                  label: '+1 LVL',
                                  color: const Color(0xFF00E5FF),
                                  onPressed: () => game.debugLevelUp(),
                                ),
                                _buildDebugBtn(
                                  label: '+500 EXP',
                                  color: const Color(0xFF00B0FF),
                                  onPressed: () => game.debugAddExp(500),
                                ),
                                _buildDebugBtn(
                                  label: '+1000 G',
                                  color: const Color(0xFFFFD700),
                                  onPressed: () => game.debugAddGold(1000),
                                ),
                                _buildDebugBtn(
                                  label: 'MAX HP',
                                  color: const Color(0xFF00E676),
                                  onPressed: () => game.debugHealFull(),
                                ),
                                _buildDebugBtn(
                                  label: game.isGodMode ? 'GOD: OFF' : 'GOD: ON',
                                  color: game.isGodMode
                                      ? const Color(0xFFFF5252)
                                      : const Color(0xFFFF9100),
                                  onPressed: () => game.debugToggleGodMode(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Section: Combat & Spawn
                            _buildSectionHeader('COMBAT & SPAWNING', const Color(0xFFFF5252)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                _buildDebugBtn(
                                  label: 'KILL ALL',
                                  color: const Color(0xFFFF5252),
                                  onPressed: () =>
                                      game.debugKillAllMonsters(),
                                ),
                                _buildDebugBtn(
                                  label: 'SPAWN MIDBOSS',
                                  color: const Color(0xFFFF7043),
                                  onPressed: () => game.debugSpawnMidboss(),
                                ),
                                _buildDebugBtn(
                                  label: 'SPAWN BOSS',
                                  color: const Color(0xFFE040FB),
                                  onPressed: () => game.debugSpawnBoss(),
                                ),
                                _buildDebugBtn(
                                  label: 'NEXT STAGE',
                                  color: const Color(0xFF7C4DFF),
                                  onPressed: () => game.debugNextStage(),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Section: Upgrades & Systems
                            _buildSectionHeader('UPGRADES & ZONES', const Color(0xFFFFD54F)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 5,
                              runSpacing: 5,
                              children: [
                                _buildDebugBtn(
                                  label: 'ZONE: NORMAL',
                                  color: const Color(0xFFFFD54F),
                                  onPressed: () =>
                                      game.debugTriggerZone(false),
                                ),
                                _buildDebugBtn(
                                  label: 'ZONE: GOLD',
                                  color: const Color(0xFFFFB300),
                                  onPressed: () => game.debugTriggerZone(true),
                                ),
                                _buildDebugBtn(
                                  label: 'ROLL/SKIP +5',
                                  color: const Color(0xFF26A69A),
                                  onPressed: () =>
                                      game.debugAddRollsAndSkips(5),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Section: Game Speed
                            _buildSectionHeader('TIME DILATION', const Color(0xFF90A4AE)),
                            const SizedBox(height: 6),
                            Row(
                              children: [1.0, 1.5, 2.0, 4.0].map((scale) {
                                final isSelected =
                                    game.gameTimeScale == scale;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: InkWell(
                                      onTap: () =>
                                          game.debugSetTimeScale(scale),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF00E5FF)
                                                  .withValues(alpha: 0.25)
                                              : const Color(0xFF0E1422),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF00E5FF)
                                                : const Color(0xFF202B40),
                                            width: 1.0,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF00E5FF)
                                                            .withValues(
                                                                alpha: 0.3),
                                                    blurRadius: 6,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${scale.toStringAsFixed(1)}x',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              color: isSelected
                                                  ? const Color(0xFF00E5FF)
                                                  : const Color(0xFF90A4AE),
                                              fontWeight: isSelected
                                                  ? FontWeight.w900
                                                  : FontWeight.bold,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricTag({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF546E7A),
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 10.5,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 10,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDebugBtn({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: color.withValues(alpha: 0.6),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 4,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}
