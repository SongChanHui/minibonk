import 'dart:math';
import '../../models/stats.dart';
import '../../models/rarity.dart';
import '../../models/weapon_definition.dart';
import '../../models/upgrade_card_definition.dart';

class LevelUpOption {
  final bool isWeapon;
  final WeaponDefinition? weapon;
  final UpgradeCardDefinition? card;
  final Rarity rarity;
  final bool isNew;
  final String title;
  final String levelText;
  final String description;
  final String assetPath;

  const LevelUpOption({
    required this.isWeapon,
    this.weapon,
    this.card,
    required this.rarity,
    required this.isNew,
    required this.title,
    required this.levelText,
    required this.description,
    required this.assetPath,
  });
}

class InventoryManager {
  final PlayerStats stats;
  final int maxWeaponSlots;
  final int maxCardSlots;
  final Random _rng;

  final List<WeaponDefinition> equippedWeapons = [];
  final Map<String, int> cardLevels = {};
  final List<UpgradeCardDefinition> equippedCards = [];

  InventoryManager({
    required this.stats,
    this.maxWeaponSlots = 4,
    this.maxCardSlots = 4,
    Random? rng,
  }) : _rng = rng ?? Random();

  bool get canAddWeapon => equippedWeapons.length < maxWeaponSlots;
  bool get canAddCard => equippedCards.length < maxCardSlots;

  bool get areWeaponsMaxedOut {
    if (canAddWeapon && availableNewWeapons.isNotEmpty) return false;
    return equippedWeapons.every((w) => w.isMaxLevel);
  }

  bool get areCardsMaxedOut {
    if (canAddCard && availableNewCards.isNotEmpty) return false;
    return equippedCards.every((c) => (cardLevels[c.id] ?? 0) >= 99);
  }

  bool get isAllMaxedOut {
    return areWeaponsMaxedOut && areCardsMaxedOut;
  }

  List<WeaponDefinition> get availableNewWeapons {
    final equippedIds = equippedWeapons.map((w) => w.id).toSet();
    return WeaponRegistry.allWeapons
        .where((w) => !equippedIds.contains(w.id))
        .toList();
  }

  List<UpgradeCardDefinition> get availableNewCards {
    final equippedIds = equippedCards.map((c) => c.id).toSet();
    return UpgradeCards.allCards
        .where((c) => !equippedIds.contains(c.id))
        .toList();
  }

  List<WeaponDefinition> get upgradableWeapons {
    return equippedWeapons.where((w) => !w.isMaxLevel).toList();
  }

  List<UpgradeCardDefinition> get upgradableCards {
    return equippedCards.where((c) => (cardLevels[c.id] ?? 0) < 99).toList();
  }

  void addWeapon(WeaponDefinition weapon, {Rarity rarity = Rarity.common}) {
    if (!canAddWeapon) return;
    final instance = weapon.copy();
    instance.level = 1;
    if (rarity.multiplier > 1.0) {
      instance.currentDamage *= rarity.multiplier;
    }
    equippedWeapons.add(instance);
  }

  void applyCard(UpgradeCardDefinition card, Rarity rarity) {
    final currentLvl = cardLevels[card.id] ?? 0;
    if (currentLvl >= 99) return;

    if (!cardLevels.containsKey(card.id)) {
      if (!canAddCard) return;
      equippedCards.add(card);
    }

    cardLevels[card.id] = currentLvl + 1;
    final inc = card.baseCardIncrease * rarity.multiplier;
    stats.addCardStat(card.targetStat, inc);
  }

  void applyZoneUpgrade(UpgradeCardDefinition card, Rarity rarity) {
    final inc = card.baseZoneIncrease * rarity.multiplier;
    stats.addZoneStat(card.targetStat, inc);
  }

  List<LevelUpOption> generateLevelUpOptions([int count = 3]) {
    if (isAllMaxedOut) {
      return [];
    }

    final options = <LevelUpOption>[];
    final usedCardIds = <String>{};
    final usedWeaponIds = <String>{};

    for (int i = 0; i < count; i++) {
      // Step 1: Roll Type (Existing enhance vs New acquisition)
      final hasSlots = canAddWeapon || canAddCard;
      final hasExisting = upgradableWeapons.isNotEmpty || upgradableCards.isNotEmpty;
      final hasNew = availableNewWeapons.isNotEmpty || availableNewCards.isNotEmpty;

      if (!hasExisting && !hasNew) break;

      bool rollNew = true;
      if (!hasSlots || !hasNew) {
        rollNew = false;
      } else if (!hasExisting) {
        rollNew = true;
      } else {
        // 33% existing / 67% new
        rollNew = _rng.nextDouble() < 0.67;
      }

      // Step 2: Category decision (Weapon vs Upgrade Card)
      bool chooseWeapon = true;
      if (rollNew) {
        final canNewWeapon = canAddWeapon &&
            availableNewWeapons.any((w) => !usedWeaponIds.contains(w.id));
        final canNewCard = canAddCard &&
            availableNewCards.any((c) => !usedCardIds.contains(c.id));

        if (canNewWeapon && canNewCard) {
          chooseWeapon = _rng.nextBool();
        } else if (canNewWeapon) {
          chooseWeapon = true;
        } else if (canNewCard) {
          chooseWeapon = false;
        } else {
          // Fallback to upgrade existing
          rollNew = false;
          chooseWeapon = upgradableWeapons.isNotEmpty &&
              (!upgradableCards.isNotEmpty || _rng.nextBool());
        }
      }

      if (!rollNew) {
        final canUpWeapon = upgradableWeapons.any((w) => !usedWeaponIds.contains(w.id));
        final canUpCard = upgradableCards.any((c) => !usedCardIds.contains(c.id));

        if (canUpWeapon && canUpCard) {
          chooseWeapon = _rng.nextBool();
        } else if (canUpWeapon) {
          chooseWeapon = true;
        } else if (canUpCard) {
          chooseWeapon = false;
        } else {
          // If no unused available, pick from any remaining
          if (upgradableWeapons.isNotEmpty) {
            chooseWeapon = true;
          } else if (upgradableCards.isNotEmpty) {
            chooseWeapon = false;
          } else {
            break;
          }
        }
      }

      // Step 3: Draw uniform from candidate pool
      final rarity = Rarity.rollWithLuck(stats.luck, _rng);

      if (chooseWeapon) {
        if (rollNew) {
          final pool = availableNewWeapons
              .where((w) => !usedWeaponIds.contains(w.id))
              .toList();
          final cand = pool.isNotEmpty ? pool[_rng.nextInt(pool.length)] : availableNewWeapons.first;
          usedWeaponIds.add(cand.id);
          options.add(LevelUpOption(
            isWeapon: true,
            weapon: cand,
            rarity: rarity,
            isNew: true,
            title: cand.nameEn,
            levelText: 'NEW!! Lv. 1',
            description: cand.description,
            assetPath: cand.assetPath,
          ));
        } else {
          final pool = upgradableWeapons
              .where((w) => !usedWeaponIds.contains(w.id))
              .toList();
          final cand = pool.isNotEmpty ? pool[_rng.nextInt(pool.length)] : upgradableWeapons.first;
          usedWeaponIds.add(cand.id);
          options.add(LevelUpOption(
            isWeapon: true,
            weapon: cand,
            rarity: rarity,
            isNew: false,
            title: cand.nameEn,
            levelText: 'Lv. ${cand.level} -> ${cand.level + 1}',
            description: '${cand.nameKo} 공격력이 대폭 강화됩니다.',
            assetPath: cand.assetPath,
          ));
        }
      } else {
        if (rollNew) {
          final pool = availableNewCards
              .where((c) => !usedCardIds.contains(c.id))
              .toList();
          final cand = pool.isNotEmpty ? pool[_rng.nextInt(pool.length)] : availableNewCards.first;
          usedCardIds.add(cand.id);
          final inc = cand.baseCardIncrease * rarity.multiplier;
          options.add(LevelUpOption(
            isWeapon: false,
            card: cand,
            rarity: rarity,
            isNew: true,
            title: cand.nameEn,
            levelText: 'NEW!! Lv. 1',
            description: '${cand.nameKo} +${inc.toStringAsFixed(1)}',
            assetPath: cand.assetPath,
          ));
        } else {
          final pool = upgradableCards
              .where((c) => !usedCardIds.contains(c.id))
              .toList();
          final cand = pool.isNotEmpty ? pool[_rng.nextInt(pool.length)] : upgradableCards.first;
          usedCardIds.add(cand.id);
          final lvl = cardLevels[cand.id] ?? 1;
          final inc = cand.baseCardIncrease * rarity.multiplier;
          options.add(LevelUpOption(
            isWeapon: false,
            card: cand,
            rarity: rarity,
            isNew: false,
            title: cand.nameEn,
            levelText: 'Lv. $lvl -> ${lvl + 1}',
            description: '${cand.nameKo} +${inc.toStringAsFixed(1)}',
            assetPath: cand.assetPath,
          ));
        }
      }
    }

    return options;
  }
}
