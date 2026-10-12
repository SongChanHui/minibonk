import 'package:flutter/material.dart';
import '../../game/minibonk_game.dart';

class HudOverlay extends StatefulWidget {
  final MinibonkGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  Offset? _dragStart;
  Offset _dragDelta = Offset.zero;

  String _formatTime(double seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.game.hudNotifier,
      builder: (context, _) {
        return Stack(
          children: [
            // Top Status Bar (Luxury Sci-Fi HUD)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),

            // Teleporter Radar Pointer (if discovered)
            if (widget.game.isTeleporterDiscovered) _buildRadarArrow(),

            if (widget.game.nearbyChest != null)
              Positioned(
                bottom: 150,
                left: 0,
                right: 0,
                child: Center(child: _buildChestPrompt()),
              ),

            if (widget.game.eventLogs.isNotEmpty)
              Positioned(
                top: 78,
                right: 12,
                child: _buildEventLog(),
              ),

            // Bottom-Right: Equipped Items & Dash Button
            Positioned(
              bottom: 16,
              right: 18,
              child: _buildBottomRightControls(),
            ),

            // Virtual Joystick for Touch / Mouse
            Positioned(
              bottom: 60,
              left: 30,
              child: _buildVirtualJoystick(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChestPrompt() {
    final game = widget.game;
    final chest = game.nearbyChest!;
    final isGolden = chest.type.name == 'chestGolden';
    final cost = isGolden ? 0 : game.nearbyChestCost;
    final canAfford = isGolden || game.gold >= cost;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF090D17).withValues(alpha: 0.94),
        border: Border.all(
          color: canAfford ? const Color(0xFFFFD54F) : Colors.redAccent,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        canAfford
            ? '상자 열기  [E]${isGolden ? '  무료' : '  $cost G'}'
            : '골드 부족  [$cost G 필요]',
        style: TextStyle(
          color: canAfford ? const Color(0xFFFFE082) : Colors.redAccent,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildEventLog() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF080B13).withValues(alpha: 0.82),
        border: Border.all(color: const Color(0xFF263238)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('진행 로그', style: TextStyle(color: Color(0xFF80DEEA), fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 4),
          ...widget.game.eventLogs.take(4).map((entry) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(entry, style: const TextStyle(color: Colors.white, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
              )),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final game = widget.game;
    final hp = game.player.currentHp.toInt();
    final maxHp = game.player.maxHp.toInt();
    final hpRatio = (hp / (maxHp <= 0 ? 1 : maxHp)).clamp(0.0, 1.0);

    final exp = game.currentExp;
    final targetExp = game.targetExp;
    final expRatio = (exp / (targetExp <= 0 ? 1 : targetExp)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF060911).withValues(alpha: 0.98),
            const Color(0xFF090E1B).withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Player Profile & Red Health Bar (Sharp, Luxury Titanium/Neon Border)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B101D).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.14),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar Box (Sharp bevel look)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10192B),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: const Color(0xFF00E5FF),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: Color(0xFFE0F7FA),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name & Level
                      Row(
                        children: [
                          const Text(
                            'ELARA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E5FF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              'LV. ${game.playerLevel}',
                              style: const TextStyle(
                                color: Color(0xFF050B14),
                                fontWeight: FontWeight.w900,
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Health Bar (High-tech crisp look)
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            width: 135,
                            height: 11,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A0A0E),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: const Color(0xFF4A1016),
                                width: 1.0,
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Container(
                              width: 135 * hpRatio,
                              height: 11,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFD50000),
                                    Color(0xFFFF1744),
                                    Color(0xFFFF5252),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 135,
                            alignment: Alignment.center,
                            child: Text(
                              'HP $hp / $maxHp',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Center: EXP Bar (High-tech Neon Gauge)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 10,
                            color: const Color(0xFF00E5FF),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'EXP // PROGRESS',
                            style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'NEXT: $targetExp',
                        style: const TextStyle(
                          color: Color(0xFF78909C),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF090E1A),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: const Color(0xFF16253D),
                            width: 1.0,
                          ),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: FractionallySizedBox(
                          widthFactor: expRatio,
                          child: Container(
                            height: 11,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF0D47A1),
                                  Color(0xFF00B0FF),
                                  Color(0xFF00E5FF),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Right: Time, Survivors (Kills), Gold (Sharp, Luxury Dark Panel)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0B101D).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFFFFD54F).withValues(alpha: 0.75),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD54F).withValues(alpha: 0.12),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TIME',
                        style: TextStyle(
                          color: Color(0xFF78909C),
                          fontWeight: FontWeight.bold,
                          fontSize: 8.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        _formatTime(game.elapsedTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Survivors / Kills
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'KILLS',
                        style: TextStyle(
                          color: Color(0xFF78909C),
                          fontWeight: FontWeight.bold,
                          fontSize: 8.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${game.killCount}',
                        style: const TextStyle(
                          color: Color(0xFFFF5252),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Gold
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Color(0xFFFFD700),
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${game.gold}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Pause Menu Button (ESC) - Sleek High-tech Button
            InkWell(
              onTap: () => game.togglePause(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1523),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: const Color(0xFF263238),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.pause,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ),

            const SizedBox(width: 6),

            // Debug Button (F1)
            InkWell(
              onTap: () => game.toggleDebugOverlay(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1523),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.bug_report,
                  color: Color(0xFF00E5FF),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarArrow() {
    return Positioned(
      top: 85,
      right: 25,
      child: Transform.rotate(
        angle: widget.game.teleporterAngle,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0B20).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color(0xFFB388FF),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB388FF).withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.navigation,
            color: Color(0xFFE1BEE7),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomRightControls() {
    final game = widget.game;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Inventory Slots Row - Sharp & Luxurious
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F1D).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Equipped Weapons
              ...game.inventory.equippedWeapons.map((weapon) {
                return _buildSlot(
                  title: weapon.nameEn,
                  level: 'LV.${weapon.level}',
                  assetPath: weapon.assetPath,
                  borderColor: const Color(0xFF00E5FF),
                );
              }),

              // Equipped Cards / Items
              ...game.inventory.equippedCards.map((card) {
                final lvl = game.inventory.cardLevels[card.id] ?? 1;
                return _buildSlot(
                  title: card.nameEn,
                  level: 'LV.$lvl',
                  assetPath: card.assetPath,
                  borderColor: const Color(0xFFFFB300),
                );
              }),
            ],
          ),
        ),

        const SizedBox(width: 10),

        // Dash Button - Sharp Sleek Neon Hex/Box
        _buildDashButton(),
      ],
    );
  }

  Widget _buildSlot({
    required String title,
    required String level,
    required String assetPath,
    required Color borderColor,
  }) {
    return Container(
      width: 58,
      margin: const EdgeInsets.symmetric(horizontal: 2.5),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF101626),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title on top
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFCFD8DC),
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          // Icon in middle
          SizedBox(
            width: 30,
            height: 30,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.shield,
                color: borderColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Level badge on bottom
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: Color(0xFF0A0F1D),
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashButton() {
    final player = widget.game.player;
    final cdPercent = player.dashCooldownPercent;
    final isReady = cdPercent <= 0.0;

    return GestureDetector(
      onTap: () {
        player.triggerDash();
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: isReady
              ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
              : const Color(0xFF101724),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isReady ? const Color(0xFF00E5FF) : const Color(0xFF37474F),
            width: 1.5,
          ),
          boxShadow: isReady
              ? [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.45),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!isReady)
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: cdPercent,
                  color: const Color(0xFF00E5FF),
                  backgroundColor: Colors.transparent,
                  strokeWidth: 2.5,
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bolt,
                  color: isReady ? const Color(0xFF00E5FF) : const Color(0xFF546E7A),
                  size: 24,
                ),
                Text(
                  'DASH',
                  style: TextStyle(
                    color: isReady ? Colors.white : const Color(0xFF546E7A),
                    fontWeight: FontWeight.w900,
                    fontSize: 8.5,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualJoystick() {
    return GestureDetector(
      onPanStart: (details) {
        _dragStart = details.localPosition;
      },
      onPanUpdate: (details) {
        if (_dragStart != null) {
          final offset = details.localPosition - _dragStart!;
          const maxRadius = 45.0;
          final dist = offset.distance;
          final clamped = (dist > maxRadius)
              ? Offset(offset.dx / dist * maxRadius, offset.dy / dist * maxRadius)
              : offset;
          _dragDelta = clamped;

          final normX = clamped.dx / maxRadius;
          final normY = clamped.dy / maxRadius;
          widget.game.player.joystickInput.setValues(normX, normY);
        }
      },
      onPanEnd: (_) {
        _dragStart = null;
        _dragDelta = Offset.zero;
        widget.game.player.joystickInput.setZero();
      },
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFF060911).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Transform.translate(
            offset: _dragDelta,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.control_camera,
                color: Color(0xFF060A14),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
