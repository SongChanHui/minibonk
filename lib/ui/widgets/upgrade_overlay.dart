import 'package:flutter/material.dart';
import '../../game/minibonk_game.dart';
import '../../game/managers/inventory_manager.dart';

class UpgradeOverlay extends StatefulWidget {
  final MinibonkGame game;

  const UpgradeOverlay({super.key, required this.game});

  @override
  State<UpgradeOverlay> createState() => _UpgradeOverlayState();
}

class _UpgradeOverlayState extends State<UpgradeOverlay> {
  LevelUpOption? _hoveredOption;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final options = game.currentLevelUpOptions;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.86),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1080, maxHeight: 680),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF090D17).withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.8),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column: Character Info Panel (Sharp & Luxurious Operative Dossier)
                _buildCharacterInfoPanel(),

                const SizedBox(width: 18),

                // Right Column: Vertical stack of 4 upgrade cards & action buttons
                Expanded(
                  child: Column(
                    children: [
                      // Header: Level Up / Zone Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF),
                                    width: 1.0,
                                  ),
                                ),
                                child: Icon(
                                  game.isZoneUpgradeModal
                                      ? Icons.bolt
                                      : Icons.keyboard_double_arrow_up,
                                  color: const Color(0xFF00E5FF),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                game.isZoneUpgradeModal
                                    ? 'ENHANCEMENT ZONE // 강화 선택'
                                    : 'LEVEL UPGRADE // 능력 선택',
                                style: const TextStyle(
                                  color: Color(0xFFE0F7FA),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD54F)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: const Color(0xFFFFD54F),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              'STAGE ${game.currentStage}',
                              style: const TextStyle(
                                color: Color(0xFFFFD54F),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Card List: Stacked vertically as 4 horizontal card rows
                      Expanded(
                        child: Column(
                          children: options.map((opt) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: _buildUpgradeCardRow(opt),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Bottom Reroll / Skip Buttons (Sharp & High-Tech)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            label: '재설정 (${game.rerollCount})',
                            icon: Icons.refresh,
                            color: const Color(0xFF00E5FF),
                            onTap: game.rerollCount > 0
                                ? () {
                                    setState(() {
                                      game.rerollUpgradeOptions();
                                    });
                                  }
                                : null,
                          ),
                          const SizedBox(width: 10),
                          _buildActionButton(
                            label: '스킵 (${game.skipCount})',
                            icon: Icons.close,
                            color: const Color(0xFFFF5252),
                            onTap: game.skipCount > 0
                                ? () {
                                    setState(() {
                                      game.skipUpgradeOptions();
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterInfoPanel() {
    final game = widget.game;
    final stats = game.stats;

    return Container(
      width: 270,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C101A),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF1E2A40),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Badge: CHARACTER DATA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: const Color(0xFF00E5FF), width: 1.0),
            ),
            child: const Text(
              'OPERATIVE PROFILE',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Character Profile: Avatar + ELARA + Level progression
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF10192A),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: const Color(0xFF00E5FF),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      color: Color(0xFFE0F7FA),
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ELARA',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'LV.${game.playerLevel} → LV.${game.playerLevel + 1}',
                    style: const TextStyle(
                      color: Color(0xFFFFD54F),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(color: Color(0xFF182234), height: 20),

          // 9 Stat Rows
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildStatItem(
                  icon: Icons.bolt,
                  name: '공격력 (ATK)',
                  value: (stats.damageMultiplier * 50).round().toString(),
                  bonus: '+10',
                ),
                _buildStatItem(
                  icon: Icons.favorite,
                  name: '최대 체력 (HP)',
                  value: stats.maxHp.round().toString(),
                  bonus: '+10',
                ),
                _buildStatItem(
                  icon: Icons.gps_fixed,
                  name: '치명타 확률 (CRIT)',
                  value: '${stats.totalCritChance.round()}%',
                  bonus: '+10',
                ),
                _buildStatItem(
                  icon: Icons.whatshot,
                  name: '치명타 피해 (C.DMG)',
                  value: '${(stats.baseCritDamage * 100).round()}%',
                  bonus: '+10',
                ),
                _buildStatItem(
                  icon: Icons.directions_run,
                  name: '이동속도 (SPD)',
                  value: (stats.moveSpeedMultiplier * 100).round().toString(),
                  bonus: '+10',
                ),
                _buildStatItem(
                  icon: Icons.speed,
                  name: '공격속도 (ATK SPD)',
                  value: (stats.attackSpeedMultiplier * 100).round().toString(),
                  bonus: '+10',
                ),
                _buildStatItem(
                  icon: Icons.shield,
                  name: '방어력 (ARMOR)',
                  value: stats.armorPercent.round().toString(),
                  bonus: '+6',
                ),
                _buildStatItem(
                  icon: Icons.radio_button_checked,
                  name: '획득범위 (RANGE)',
                  value: (stats.pickupRange / 10).round().toString(),
                  bonus: '+10',
                ),
                _buildStatItem(
                  icon: Icons.aspect_ratio,
                  name: '공격범위 (AREA)',
                  value: (stats.sizeMultiplier * 100).round().toString(),
                  bonus: '+6',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String name,
    required String value,
    required String bonus,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF00E5FF)),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF90A4AE),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '($bonus)',
            style: const TextStyle(
              color: Color(0xFF00E676),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  // Horizontal Card Row - Sharp Bevel Look with Neon Glow
  Widget _buildUpgradeCardRow(LevelUpOption option) {
    final borderColor = option.rarity.color;
    final isHovered = _hoveredOption == option;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredOption = option),
      onExit: (_) => setState(() => _hoveredOption = null),
      child: GestureDetector(
        onTap: () => widget.game.selectLevelUpOption(option),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isHovered
                ? const Color(0xFF161F33)
                : const Color(0xFF0D121F),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isHovered ? Colors.white : borderColor.withValues(alpha: 0.85),
              width: isHovered ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: isHovered ? 0.4 : 0.15),
                blurRadius: isHovered ? 14 : 6,
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: Item Icon Container (Sharp)
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFF060910),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                ),
                child: Image.asset(
                  option.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.star,
                    color: borderColor,
                    size: 26,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Middle: Title, Level progression & Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top row: Title + Level
                    Row(
                      children: [
                        Text(
                          option.title.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD54F)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            option.levelText,
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Bottom row: Korean description
                    Text(
                      option.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right: Category Badge & Rarity Tag
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: option.isNew
                          ? const Color(0xFFFF5252).withValues(alpha: 0.9)
                          : const Color(0xFF1E88E5).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      option.isNew ? '신규' : '강화',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: borderColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: borderColor, width: 0.8),
                    ),
                    child: Text(
                      option.rarity.nameKo,
                      style: TextStyle(
                        color: borderColor,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
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

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0C101A),
        foregroundColor: color,
        disabledBackgroundColor: const Color(0xFF070A10),
        disabledForegroundColor: const Color(0xFF455A64),
        side: BorderSide(
          color: onTap != null ? color.withValues(alpha: 0.8) : const Color(0xFF263238),
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
