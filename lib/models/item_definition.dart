import 'rarity.dart';
import 'stats.dart';

enum BuildTag {
  tanker,
  damage,
  agility,
  gold,
  risk,
  general;

  String get nameKo {
    switch (this) {
      case BuildTag.tanker:
        return '탱커';
      case BuildTag.damage:
        return '데미지';
      case BuildTag.agility:
        return '이속/회피';
      case BuildTag.gold:
        return '골드';
      case BuildTag.risk:
        return '리스크';
      case BuildTag.general:
        return '범용';
    }
  }
}

enum StackType {
  aLinear,
  bDiminishing,
  cUnique,
  dSpecial;
}

class PassiveItemDefinition {
  final String id;
  final String nameKo;
  final String nameEn;
  final Rarity rarity;
  final BuildTag buildTag;
  final StackType stackType;
  final String description;
  final String assetPath;
  final StatType? primaryStat;
  final double baseStatValue;

  const PassiveItemDefinition({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.rarity,
    required this.buildTag,
    required this.stackType,
    required this.description,
    required this.assetPath,
    this.primaryStat,
    this.baseStatValue = 0.0,
  });
}

class ItemRegistry {
  static const List<PassiveItemDefinition> allItems = [
    PassiveItemDefinition(
      id: 'accel_coil',
      nameKo: '가속 코일',
      nameEn: 'ACCEL COIL',
      rarity: Rarity.common,
      buildTag: BuildTag.general,
      stackType: StackType.aLinear,
      description: '공격 속도가 8% 증가합니다.',
      assetPath: 'assets/sprites/items/lightning_gauntlet.png',
      primaryStat: StatType.attackSpeed,
      baseStatValue: 8.0,
    ),
    PassiveItemDefinition(
      id: 'swift_boots_item',
      nameKo: '질주 부츠',
      nameEn: 'SWIFT BOOTS',
      rarity: Rarity.common,
      buildTag: BuildTag.agility,
      stackType: StackType.aLinear,
      description: '이동 속도가 15% 증가합니다.',
      assetPath: 'assets/sprites/items/swift_boots.png',
      primaryStat: StatType.moveSpeed,
      baseStatValue: 15.0,
    ),
    PassiveItemDefinition(
      id: 'four_leaf_clover_item',
      nameKo: '행운의 풀잎',
      nameEn: 'FOUR-LEAF CLOVER',
      rarity: Rarity.common,
      buildTag: BuildTag.general,
      stackType: StackType.aLinear,
      description: '행운이 7.5% 증가합니다.',
      assetPath: 'assets/sprites/items/four_leaf_clover.png',
      primaryStat: StatType.luck,
      baseStatValue: 7.5,
    ),
    PassiveItemDefinition(
      id: 'ring_of_might_item',
      nameKo: '위력의 반지',
      nameEn: 'RING OF MIGHT',
      rarity: Rarity.uncommon,
      buildTag: BuildTag.damage,
      stackType: StackType.aLinear,
      description: '공격력이 영구적으로 10% 증가합니다.',
      assetPath: 'assets/sprites/items/ring_of_might.png',
      primaryStat: StatType.damage,
      baseStatValue: 10.0,
    ),
    PassiveItemDefinition(
      id: 'magnetic_core_item',
      nameKo: '인력 코어',
      nameEn: 'MAGNETIC CORE',
      rarity: Rarity.common,
      buildTag: BuildTag.general,
      stackType: StackType.aLinear,
      description: '아이템 및 경험치 습득 범위가 25% 확장됩니다.',
      assetPath: 'assets/sprites/items/magnetic_core.png',
      primaryStat: StatType.pickupRange,
      baseStatValue: 25.0,
    ),
    PassiveItemDefinition(
      id: 'health_kit_item',
      nameKo: '재생 키트',
      nameEn: 'HEALTH POTION KIT',
      rarity: Rarity.common,
      buildTag: BuildTag.tanker,
      stackType: StackType.aLinear,
      description: '초당 체력 회복량이 증가합니다.',
      assetPath: 'assets/sprites/items/health_potion_kit.png',
      primaryStat: StatType.hpRegen,
      baseStatValue: 10.0,
    ),
    PassiveItemDefinition(
      id: 'cursed_crown_item',
      nameKo: '저주의 낙인',
      nameEn: 'CURSED CROWN',
      rarity: Rarity.rare,
      buildTag: BuildTag.risk,
      stackType: StackType.aLinear,
      description: '난이도가 7% 증가하지만 적들이 더 많은 보상을 제공합니다.',
      assetPath: 'assets/sprites/items/cursed_crown.png',
      primaryStat: StatType.difficulty,
      baseStatValue: 7.0,
    ),
    PassiveItemDefinition(
      id: 'reflective_shield_item',
      nameKo: '반사의 방패',
      nameEn: 'REFLECTIVE SHIELD',
      rarity: Rarity.uncommon,
      buildTag: BuildTag.tanker,
      stackType: StackType.aLinear,
      description: '방어력과 가시 피해가 증가합니다.',
      assetPath: 'assets/sprites/items/reflective_shield.png',
      primaryStat: StatType.thorns,
      baseStatValue: 15.0,
    ),
  ];
}
