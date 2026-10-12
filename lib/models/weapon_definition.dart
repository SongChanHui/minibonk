import 'dart:math';
import 'rarity.dart';

enum WeaponType {
  projectile,
  melee,
  area,
  orbit,
  returnType,
  special;
}

class WeaponDefinition {
  final String id;
  final String nameKo;
  final String nameEn;
  final String description;
  final String assetPath;
  final WeaponType weaponType;

  // Base stats
  final double baseDamage;
  final double damageGrowth;
  final int baseAmount;
  final int amountGrowth;
  final double baseSpeed;
  final double speedGrowth;
  final double baseCooldown;
  final double cooldownGrowth;
  final double baseKnockback;
  final double knockbackGrowth;
  final double baseArea;
  final double areaGrowth;
  final double baseCritChance;
  final double critChanceGrowth;
  final double baseCritDamage;
  final double critDamageGrowth;
  final double baseDuration;
  final double durationGrowth;
  final int baseBounce;
  final int bounceGrowth;

  // Current mutable state
  int level;
  double currentDamage;
  int currentAmount;
  double currentSpeed;
  double currentCooldown;
  double currentKnockback;
  double currentArea;
  double currentCritChance;
  double currentCritDamage;
  double currentDuration;
  int currentBounce;

  WeaponDefinition({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.description,
    required this.assetPath,
    required this.weaponType,
    required this.baseDamage,
    this.damageGrowth = 0.0,
    this.baseAmount = 1,
    this.amountGrowth = 0,
    this.baseSpeed = 1.0,
    this.speedGrowth = 0.0,
    this.baseCooldown = 1.0,
    this.cooldownGrowth = 0.0,
    this.baseKnockback = 1.0,
    this.knockbackGrowth = 0.0,
    this.baseArea = 1.0,
    this.areaGrowth = 0.0,
    this.baseCritChance = 0.0,
    this.critChanceGrowth = 0.0,
    this.baseCritDamage = 2.0,
    this.critDamageGrowth = 0.0,
    this.baseDuration = 1.0,
    this.durationGrowth = 0.0,
    this.baseBounce = 0,
    this.bounceGrowth = 0,
    this.level = 1,
  })  : currentDamage = baseDamage,
        currentAmount = baseAmount,
        currentSpeed = baseSpeed,
        currentCooldown = baseCooldown,
        currentKnockback = baseKnockback,
        currentArea = baseArea,
        currentCritChance = baseCritChance,
        currentCritDamage = baseCritDamage,
        currentDuration = baseDuration,
        currentBounce = baseBounce;

  WeaponDefinition copy() {
    return WeaponDefinition(
      id: id,
      nameKo: nameKo,
      nameEn: nameEn,
      description: description,
      assetPath: assetPath,
      weaponType: weaponType,
      baseDamage: baseDamage,
      damageGrowth: damageGrowth,
      baseAmount: baseAmount,
      amountGrowth: amountGrowth,
      baseSpeed: baseSpeed,
      speedGrowth: speedGrowth,
      baseCooldown: baseCooldown,
      cooldownGrowth: cooldownGrowth,
      baseKnockback: baseKnockback,
      knockbackGrowth: knockbackGrowth,
      baseArea: baseArea,
      areaGrowth: areaGrowth,
      baseCritChance: baseCritChance,
      critChanceGrowth: critChanceGrowth,
      baseCritDamage: baseCritDamage,
      critDamageGrowth: critDamageGrowth,
      baseDuration: baseDuration,
      durationGrowth: durationGrowth,
      baseBounce: baseBounce,
      bounceGrowth: bounceGrowth,
      level: level,
    )
      ..currentDamage = currentDamage
      ..currentAmount = currentAmount
      ..currentSpeed = currentSpeed
      ..currentCooldown = currentCooldown
      ..currentKnockback = currentKnockback
      ..currentArea = currentArea
      ..currentCritChance = currentCritChance
      ..currentCritDamage = currentCritDamage
      ..currentDuration = currentDuration
      ..currentBounce = currentBounce;
  }

  bool get isMaxLevel => level >= 40;

  void upgrade(Rarity rarity, [Random? rng]) {
    if (isMaxLevel) return;
    level++;
    final mult = rarity.multiplier;
    final statCount = rarity.rollStatCount(rng);

    // List of upgradable stats for this weapon
    final possibleStats = <String>[];
    if (damageGrowth > 0) possibleStats.add('damage');
    if (amountGrowth > 0) possibleStats.add('amount');
    if (speedGrowth > 0) possibleStats.add('speed');
    if (knockbackGrowth > 0) possibleStats.add('knockback');
    if (areaGrowth > 0) possibleStats.add('area');
    if (critChanceGrowth > 0) possibleStats.add('critChance');
    if (critDamageGrowth > 0) possibleStats.add('critDamage');
    if (durationGrowth > 0) possibleStats.add('duration');
    if (bounceGrowth > 0) possibleStats.add('bounce');

    if (possibleStats.isEmpty) {
      currentDamage += damageGrowth * mult;
      return;
    }

    final rand = rng ?? Random();
    possibleStats.shuffle(rand);
    final selected = possibleStats.take(statCount);

    for (final s in selected) {
      switch (s) {
        case 'damage':
          currentDamage += damageGrowth * mult;
          break;
        case 'amount':
          currentAmount += (amountGrowth * mult).round().clamp(1, 10);
          break;
        case 'speed':
          currentSpeed += speedGrowth * mult;
          break;
        case 'knockback':
          currentKnockback += knockbackGrowth * mult;
          break;
        case 'area':
          currentArea += areaGrowth * mult;
          break;
        case 'critChance':
          currentCritChance += critChanceGrowth * mult;
          break;
        case 'critDamage':
          currentCritDamage += critDamageGrowth * mult;
          break;
        case 'duration':
          currentDuration += durationGrowth * mult;
          break;
        case 'bounce':
          currentBounce += (bounceGrowth * mult).round();
          break;
      }
    }
  }
}

class WeaponRegistry {
  static final List<WeaponDefinition> allWeapons = [
    WeaponDefinition(
      id: 'fiery_orb',
      nameKo: '화염구',
      nameEn: 'FIERY ORB',
      description: '충돌 시 폭발하는 불덩이를 발사합니다. 범위 피해를 입힙니다.',
      assetPath: 'assets/sprites/items/fiery_orb.png',
      weaponType: WeaponType.projectile,
      baseDamage: 10.0,
      damageGrowth: 2.5,
      baseAmount: 1,
      amountGrowth: 1,
      baseSpeed: 0.5,
      speedGrowth: 0.1,
      baseArea: 1.0,
      areaGrowth: 0.26,
      baseCooldown: 1.2,
    ),
    WeaponDefinition(
      id: 'crystal_bow',
      nameKo: '마법궁',
      nameEn: 'CRYSTAL BOW',
      description: '적을 관통하는 화살을 부채꼴로 일제 발사합니다.',
      assetPath: 'assets/sprites/items/crystal_bow.png',
      weaponType: WeaponType.projectile,
      baseDamage: 9.0,
      damageGrowth: 1.8,
      baseAmount: 1,
      amountGrowth: 1,
      baseSpeed: 1.5,
      speedGrowth: 0.8,
      baseArea: 1.0,
      areaGrowth: 0.2,
      baseCritChance: 5.0,
      critChanceGrowth: 8.0,
      baseCritDamage: 2.0,
      critDamageGrowth: 0.18,
      baseCooldown: 1.0,
    ),
    WeaponDefinition(
      id: 'ghostly_daggers',
      nameKo: '유령 단검',
      nameEn: 'GHOSTLY DAGGERS',
      description: '가장 가까운 적에게 피해를 주는 유령 단검을 초고속 발사합니다.',
      assetPath: 'assets/sprites/items/ghostly_daggers.png',
      weaponType: WeaponType.projectile,
      baseDamage: 11.0,
      damageGrowth: 2.2,
      baseAmount: 1,
      amountGrowth: 1,
      baseCritChance: 8.0,
      critChanceGrowth: 8.0,
      baseCritDamage: 2.0,
      critDamageGrowth: 0.20,
      baseArea: 1.0,
      areaGrowth: 0.20,
      baseCooldown: 0.8,
    ),
    WeaponDefinition(
      id: 'lightning_gauntlet',
      nameKo: '낙뢰',
      nameEn: 'LIGHTNING GAUNTLET',
      description: '무작위 주변 적에게 번개를 소환해 즉발 타격합니다.',
      assetPath: 'assets/sprites/items/lightning_gauntlet.png',
      weaponType: WeaponType.area,
      baseDamage: 7.0,
      damageGrowth: 2.0,
      baseBounce: 0,
      bounceGrowth: 1,
      baseAmount: 1,
      amountGrowth: 1,
      baseArea: 1.0,
      areaGrowth: 0.20,
      baseCooldown: 1.4,
    ),
    WeaponDefinition(
      id: 'frozen_shard',
      nameKo: '빙결진',
      nameEn: 'FROZEN SHARD',
      description: '주변 지대를 얼려 지속 피해를 주고 적을 둔화시킵니다.',
      assetPath: 'assets/sprites/items/frozen_shard.png',
      weaponType: WeaponType.area,
      baseDamage: 9.0,
      damageGrowth: 2.0,
      baseDuration: 1.6,
      durationGrowth: 0.12,
      baseArea: 1.0,
      areaGrowth: 0.10,
      baseCooldown: 2.0,
    ),
    WeaponDefinition(
      id: 'reflective_shield',
      nameKo: '수호판',
      nameEn: 'REFLECTIVE SHIELD',
      description: '플레이어 주위를 공전하며 접근하는 적을 강하게 넉백합니다.',
      assetPath: 'assets/sprites/items/reflective_shield.png',
      weaponType: WeaponType.orbit,
      baseDamage: 10.0,
      damageGrowth: 2.0,
      baseKnockback: 3.0,
      knockbackGrowth: 0.8,
      baseAmount: 2,
      amountGrowth: 1,
      baseArea: 1.0,
      areaGrowth: 0.15,
      baseCooldown: 0.1,
    ),
    WeaponDefinition(
      id: 'vampire_dagger',
      nameKo: '참격',
      nameEn: 'VAMPIRE SLASH',
      description: '전방에 부채꼴 검격을 휘둘러 적을 베어냅니다.',
      assetPath: 'assets/sprites/items/vampire_dagger.png',
      weaponType: WeaponType.melee,
      baseDamage: 11.0,
      damageGrowth: 2.0,
      baseKnockback: 2.0,
      knockbackGrowth: 0.5,
      baseAmount: 1,
      amountGrowth: 1,
      baseArea: 1.0,
      areaGrowth: 0.20,
      baseCooldown: 1.1,
    ),
  ];
}
