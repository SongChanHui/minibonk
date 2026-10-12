import 'dart:math';

enum StatType {
  maxHp,
  hpRegen,
  armor,
  evasion,
  lifesteal,
  thorns,
  damage,
  critChance,
  critDamage,
  attackSpeed,
  amount,
  projectileSpeed,
  duration,
  size,
  knockback,
  moveSpeed,
  luck,
  pickupRange,
  xpGain,
  goldGain,
  difficulty,
  chaos;

  String get nameKo {
    switch (this) {
      case StatType.maxHp:
        return '최대 체력';
      case StatType.hpRegen:
        return 'HP 회복';
      case StatType.armor:
        return '방어력';
      case StatType.evasion:
        return '회피';
      case StatType.lifesteal:
        return '생명 흡수';
      case StatType.thorns:
        return '가시';
      case StatType.damage:
        return '공격력';
      case StatType.critChance:
        return '치명타 확률';
      case StatType.critDamage:
        return '치명타 피해량';
      case StatType.attackSpeed:
        return '공격 속도';
      case StatType.amount:
        return '투사체 수';
      case StatType.projectileSpeed:
        return '투사체 속도';
      case StatType.duration:
        return '지속 시간';
      case StatType.size:
        return '공격 범위';
      case StatType.knockback:
        return '넉백';
      case StatType.moveSpeed:
        return '이동 속도';
      case StatType.luck:
        return '행운';
      case StatType.pickupRange:
        return '아이템 획득범위';
      case StatType.xpGain:
        return '경험치 증가';
      case StatType.goldGain:
        return '골드 증가';
      case StatType.difficulty:
        return '난이도';
      case StatType.chaos:
        return '혼돈';
    }
  }
}

class CritHitResult {
  final bool isCrit;
  final int stage;
  final double multiplier;

  const CritHitResult({
    required this.isCrit,
    required this.stage,
    required this.multiplier,
  });
}

class PlayerStats {
  final Map<StatType, double> _cardStats = {};
  final Map<StatType, double> _zoneStats = {};
  final Map<StatType, double> _itemStats = {};

  final Random _rng;

  PlayerStats({Random? rng}) : _rng = rng ?? Random();

  void addCardStat(StatType type, double value) {
    _cardStats[type] = (_cardStats[type] ?? 0.0) + value;
  }

  void addZoneStat(StatType type, double value) {
    _zoneStats[type] = (_zoneStats[type] ?? 0.0) + value;
  }

  void addItemStat(StatType type, double value) {
    _itemStats[type] = (_itemStats[type] ?? 0.0) + value;
  }

  double getCardStat(StatType type) => _cardStats[type] ?? 0.0;
  double getZoneStat(StatType type) => _zoneStats[type] ?? 0.0;
  double getItemStat(StatType type) => _itemStats[type] ?? 0.0;

  double getRawStatSum(StatType type) {
    return (_cardStats[type] ?? 0.0) +
        (_zoneStats[type] ?? 0.0) +
        (_itemStats[type] ?? 0.0);
  }

  // --- Diminishing Returns Armor ---
  // n = 0.01 * (Card + Zone + Item)
  // Armor% = n / (0.75 + n) * 100%
  double get armorPercent {
    final rawSum = getRawStatSum(StatType.armor);
    if (rawSum <= 0) return 0.0;
    final n = 0.01 * rawSum;
    return (n / (0.75 + n)) * 100.0;
  }

  double applyArmorReduction(double incomingDamage) {
    final reduction = armorPercent / 100.0;
    return incomingDamage * (1.0 - reduction);
  }

  // --- Diminishing Returns Evasion ---
  // n = 0.01 * (Card + Zone + Item)
  // Evasion% = n / (1.0 + n) * 100%
  double get evasionPercent {
    final rawSum = getRawStatSum(StatType.evasion);
    if (rawSum <= 0) return 0.0;
    final n = 0.01 * rawSum;
    return (n / (1.0 + n)) * 100.0;
  }

  bool rollEvasion() {
    final ev = evasionPercent;
    if (ev <= 0) return false;
    return (_rng.nextDouble() * 100.0) < ev;
  }

  // --- Multiplicative Damage ---
  // 1.0 * (1 + 0.01 * card) * (1 + 0.01 * zone) * (1 + 0.01 * item)
  double get damageMultiplier {
    final card = getCardStat(StatType.damage);
    final zone = getZoneStat(StatType.damage);
    final item = getItemStat(StatType.damage);
    return 1.0 * (1.0 + 0.01 * card) * (1.0 + 0.01 * zone) * (1.0 + 0.01 * item);
  }

  // --- Overcritical Formula ---
  // Base crit damage is 2.0x * (1 + 0.01*zone) * (1 + 0.01*item)
  double get baseCritDamage {
    final zone = getZoneStat(StatType.critDamage);
    final item = getItemStat(StatType.critDamage);
    return 2.0 * (1.0 + 0.01 * zone) * (1.0 + 0.01 * item);
  }

  double get totalCritChance => getRawStatSum(StatType.critChance);

  CritHitResult rollCritHit({double weaponBonusCritChance = 0.0}) {
    final totalChance = totalCritChance + weaponBonusCritChance;
    if (totalChance <= 0.0) {
      return const CritHitResult(isCrit: false, stage: 0, multiplier: 1.0);
    }

    final n = (totalChance / 100.0).floor();
    final remainder = totalChance % 100.0;
    final roll = _rng.nextDouble() * 100.0;

    int stage = n;
    if (roll < remainder) {
      stage = n + 1;
    }

    if (stage <= 0) {
      return const CritHitResult(isCrit: false, stage: 0, multiplier: 1.0);
    }

    double mult;
    if (stage == 1 || stage == 2) {
      mult = baseCritDamage;
    } else if (stage == 3) {
      mult = 4.0;
    } else if (stage == 4) {
      mult = 6.25;
    } else if (stage == 5) {
      mult = 9.0;
    } else {
      mult = pow(stage * 0.5, 2).toDouble() + (stage + 1);
    }

    return CritHitResult(isCrit: true, stage: stage, multiplier: mult);
  }

  // --- Additive & Compound Stats ---
  double get maxHp => 100.0 + getRawStatSum(StatType.maxHp);
  double get hpRegen => 5.0 + getRawStatSum(StatType.hpRegen);
  double get thorns => getRawStatSum(StatType.thorns);
  double get lifesteal => getRawStatSum(StatType.lifesteal);
  double get luck => getRawStatSum(StatType.luck);

  double get attackSpeedMultiplier =>
      (100.0 + getRawStatSum(StatType.attackSpeed)) / 100.0;

  double get moveSpeedMultiplier {
    final raw = 1.0 +
        0.01 * getCardStat(StatType.moveSpeed) +
        0.01 * getZoneStat(StatType.moveSpeed) +
        0.01 * getItemStat(StatType.moveSpeed);
    return raw.clamp(0.2, 5.0);
  }

  double get pickupRange {
    final mult = 1.0 +
        0.01 * getCardStat(StatType.pickupRange) +
        0.01 * getZoneStat(StatType.pickupRange) +
        0.01 * getItemStat(StatType.pickupRange);
    return 60.0 * mult; // In-game screen units
  }

  double get sizeMultiplier {
    return 1.0 *
        (1.0 + 0.01 * getCardStat(StatType.size)) *
        (1.0 + 0.01 * getZoneStat(StatType.size)) *
        (1.0 + 0.01 * getItemStat(StatType.size));
  }

  double get projectileSpeedMultiplier {
    return 1.0 *
        (1.0 + 0.01 * getCardStat(StatType.projectileSpeed)) *
        (1.0 + 0.01 * getZoneStat(StatType.projectileSpeed)) *
        (1.0 + 0.01 * getItemStat(StatType.projectileSpeed));
  }

  double get durationMultiplier {
    return 1.0 *
        (1.0 + 0.01 * getCardStat(StatType.duration)) *
        (1.0 + 0.01 * getZoneStat(StatType.duration)) *
        (1.0 + 0.01 * getItemStat(StatType.duration));
  }

  double get knockbackMultiplier {
    return 1.0 *
        (1.0 + 0.01 * getCardStat(StatType.knockback)) *
        (1.0 + 0.01 * getZoneStat(StatType.knockback)) *
        (1.0 + 0.01 * getItemStat(StatType.knockback));
  }

  double get xpGainMultiplier {
    return 1.0 *
        (1.0 + 0.01 * getCardStat(StatType.xpGain)) *
        (1.0 + 0.01 * getZoneStat(StatType.xpGain)) *
        (1.0 + 0.01 * getItemStat(StatType.xpGain));
  }

  double get goldGainMultiplier {
    return 1.0 *
        (1.0 + 0.01 * getCardStat(StatType.goldGain)) *
        (1.0 + 0.01 * getZoneStat(StatType.goldGain)) *
        (1.0 + 0.01 * getItemStat(StatType.goldGain));
  }

  double get difficultyMultiplier {
    return 1.0 + 0.01 * getRawStatSum(StatType.difficulty);
  }

  int rollExtraAmount(double rawAmount) {
    final guaranteed = rawAmount.floor();
    final frac = rawAmount - guaranteed;
    final bonus = (_rng.nextDouble() < frac) ? 1 : 0;
    return guaranteed + bonus;
  }
}
