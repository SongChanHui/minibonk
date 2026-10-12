import 'stats.dart';

class UpgradeCardDefinition {
  final String id;
  final String nameKo;
  final String nameEn;
  final StatType targetStat;
  final double baseCardIncrease;
  final double baseZoneIncrease;
  final String description;
  final String assetPath;

  const UpgradeCardDefinition({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.targetStat,
    required this.baseCardIncrease,
    required this.baseZoneIncrease,
    required this.description,
    required this.assetPath,
  });
}

class UpgradeCards {
  static const List<UpgradeCardDefinition> allCards = [
    UpgradeCardDefinition(
      id: 'card_hp',
      nameKo: 'HP 서',
      nameEn: 'TOME OF HEALTH',
      targetStat: StatType.maxHp,
      baseCardIncrease: 25.0,
      baseZoneIncrease: 15.0,
      description: '최대 체력을 증가시킵니다.',
      assetPath: 'assets/sprites/items/health_potion_kit.png',
    ),
    UpgradeCardDefinition(
      id: 'card_damage',
      nameKo: '데미지의 카드',
      nameEn: 'RING OF MIGHT',
      targetStat: StatType.damage,
      baseCardIncrease: 8.0,
      baseZoneIncrease: 12.0,
      description: '공격력이 영구적으로 증가하는 능력입니다.',
      assetPath: 'assets/sprites/items/ring_of_might.png',
    ),
    UpgradeCardDefinition(
      id: 'card_move_speed',
      nameKo: '민첩의 카드',
      nameEn: 'SWIFT BOOTS',
      targetStat: StatType.moveSpeed,
      baseCardIncrease: 15.0,
      baseZoneIncrease: 8.0,
      description: '이동 속도가 증가합니다.',
      assetPath: 'assets/sprites/items/swift_boots.png',
    ),
    UpgradeCardDefinition(
      id: 'card_crit_chance',
      nameKo: '정밀의 카드',
      nameEn: 'CARD OF PRECISION',
      targetStat: StatType.critChance,
      baseCardIncrease: 7.0,
      baseZoneIncrease: 5.0,
      description: '치명타 확률이 증가합니다.',
      assetPath: 'assets/sprites/items/ghostly_daggers.png',
    ),
    UpgradeCardDefinition(
      id: 'card_attack_speed',
      nameKo: '공격 속도의 카드',
      nameEn: 'CARD OF HASTE',
      targetStat: StatType.attackSpeed,
      baseCardIncrease: 7.5,
      baseZoneIncrease: 6.0,
      description: '공격 속도가 증가하여 쿨타임이 감소합니다.',
      assetPath: 'assets/sprites/items/lightning_gauntlet.png',
    ),
    UpgradeCardDefinition(
      id: 'card_pickup',
      nameKo: '매력의 카드',
      nameEn: 'MAGNETIC CHARM',
      targetStat: StatType.pickupRange,
      baseCardIncrease: 75.0,
      baseZoneIncrease: 20.0,
      description: '아이템 및 경험치 획득 범위가 대폭 확장됩니다.',
      assetPath: 'assets/sprites/items/magnetic_core.png',
    ),
    UpgradeCardDefinition(
      id: 'card_luck',
      nameKo: '행운의 카드',
      nameEn: 'FOUR-LEAF CLOVER',
      targetStat: StatType.luck,
      baseCardIncrease: 7.0,
      baseZoneIncrease: 5.0,
      description: '행운이 증가하여 고등급 당첨 확률이 상승합니다.',
      assetPath: 'assets/sprites/items/four_leaf_clover.png',
    ),
    UpgradeCardDefinition(
      id: 'card_armor',
      nameKo: '방어의 카드',
      nameEn: 'CARD OF ARMOR',
      targetStat: StatType.armor,
      baseCardIncrease: 12.0,
      baseZoneIncrease: 5.0,
      description: '받는 피해를 감소시키는 방어력이 증가합니다.',
      assetPath: 'assets/sprites/items/reflective_shield.png',
    ),
    UpgradeCardDefinition(
      id: 'card_evasion',
      nameKo: '회피의 카드',
      nameEn: 'CARD OF EVASION',
      targetStat: StatType.evasion,
      baseCardIncrease: 10.0,
      baseZoneIncrease: 5.0,
      description: '적의 공격을 회피할 확률이 증가합니다.',
      assetPath: 'assets/sprites/items/time_hourglass.png',
    ),
    UpgradeCardDefinition(
      id: 'card_regen',
      nameKo: '재생의 카드',
      nameEn: 'CARD OF REGEN',
      targetStat: StatType.hpRegen,
      baseCardIncrease: 40.0,
      baseZoneIncrease: 20.0,
      description: '초당 체력 회복량이 증가합니다.',
      assetPath: 'assets/sprites/items/health_potion_kit.png',
    ),
    UpgradeCardDefinition(
      id: 'card_size',
      nameKo: '사이즈의 카드',
      nameEn: 'CARD OF SIZE',
      targetStat: StatType.size,
      baseCardIncrease: 10.0,
      baseZoneIncrease: 8.0,
      description: '모든 무기의 공격 범위 및 투사체 크기가 커집니다.',
      assetPath: 'assets/sprites/items/blacksmith_anvil.png',
    ),
    UpgradeCardDefinition(
      id: 'card_gold',
      nameKo: '황금의 카드',
      nameEn: 'CARD OF GOLD',
      targetStat: StatType.goldGain,
      baseCardIncrease: 12.0,
      baseZoneIncrease: 7.5,
      description: '골드 획득량이 증가합니다.',
      assetPath: 'assets/sprites/items/pink_coin.png',
    ),
  ];
}
