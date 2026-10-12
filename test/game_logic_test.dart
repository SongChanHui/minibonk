import 'package:flutter_test/flutter_test.dart';
import 'package:minibonk/models/stats.dart';
import 'package:minibonk/models/rarity.dart';
import 'package:minibonk/models/economy_tables.dart';
import 'package:minibonk/models/weapon_definition.dart';
import 'package:minibonk/models/upgrade_card_definition.dart';
import 'package:minibonk/game/managers/inventory_manager.dart';

void main() {
  group('PlayerStats Formulas Test', () {
    test('Diminishing returns Armor test', () {
      final stats = PlayerStats();
      expect(stats.armorPercent, 0.0);

      // +75 armor: n = 0.75 -> 0.75 / (0.75 + 0.75) * 100% = 50%
      stats.addCardStat(StatType.armor, 75.0);
      expect(stats.armorPercent, closeTo(50.0, 0.01));

      // 100 incoming damage should become 50 damage
      expect(stats.applyArmorReduction(100.0), closeTo(50.0, 0.01));
    });

    test('Diminishing returns Evasion test', () {
      final stats = PlayerStats();
      expect(stats.evasionPercent, 0.0);

      // +100 evasion: n = 1.0 -> 1.0 / (1.0 + 1.0) * 100% = 50%
      stats.addCardStat(StatType.evasion, 100.0);
      expect(stats.evasionPercent, closeTo(50.0, 0.01));
    });

    test('Overcritical formula test', () {
      final stats = PlayerStats();
      // base crit damage is 2.0x
      // 250% crit chance -> guaranteed stage 2, stage 3 is 4.0x
      stats.addCardStat(StatType.critChance, 250.0);
      final hitResult = stats.rollCritHit();
      expect(hitResult.isCrit, isTrue);
      expect(hitResult.stage, isIn([2, 3]));
      if (hitResult.stage == 3) {
        expect(hitResult.multiplier, closeTo(4.0, 0.01));
      }
    });

    test('Multiplicative Damage formula test', () {
      final stats = PlayerStats();
      stats.addCardStat(StatType.damage, 10.0); // +10%
      stats.addZoneStat(StatType.damage, 20.0); // +20%
      stats.addItemStat(StatType.damage, 30.0); // +30%

      // 1.0 * 1.10 * 1.20 * 1.30 = 1.716
      expect(stats.damageMultiplier, closeTo(1.716, 0.001));
    });
  });

  group('Economy & Growth Tests', () {
    test('Early levels 1~10 exp curve and 11+ formula', () {
      expect(EconomyTables.getCumulativeExpForLevel(1), 7);
      expect(EconomyTables.getCumulativeExpForLevel(2), 23);
      expect(EconomyTables.getCumulativeExpForLevel(10), 377);

      // 11 level: 3.5 * 11^2 + 1.5 * 11 = 3.5 * 121 + 16.5 = 423.5 + 16.5 = 440
      expect(EconomyTables.getCumulativeExpForLevel(11), 440);
    });

    test('Chest cost exponential progression', () {
      expect(EconomyTables.getChestCost(1), 30);
      expect(EconomyTables.getChestCost(2), 72);
      expect(EconomyTables.getChestCost(3), 115);
      expect(EconomyTables.getChestCost(33), 40037);
    });

    test('Shop price time scaling', () {
      // 0~5 min
      expect(EconomyTables.getShopItemPrice(Rarity.common, 120), 50);
      expect(EconomyTables.getShopItemPrice(Rarity.legendary, 120), 1200);

      // 25 min (20~30 min tier)
      expect(EconomyTables.getShopItemPrice(Rarity.common, 25 * 60), 1000);
      expect(EconomyTables.getShopItemPrice(Rarity.legendary, 25 * 60), 24000);
    });
  });

  group('Inventory & 3-Step Level-Up Filter Tests', () {
    test('Slot auto-lock and level-up generation', () {
      final stats = PlayerStats();
      final inv = InventoryManager(stats: stats, maxWeaponSlots: 2, maxCardSlots: 2);

      // Initially empty slots
      inv.addWeapon(WeaponRegistry.allWeapons.first);
      expect(inv.equippedWeapons.length, 1);

      // Generate 3 choices
      final options = inv.generateLevelUpOptions();
      expect(options.length, 3);
    });

    test('Max level behavior', () {
      final stats = PlayerStats();
      final inv = InventoryManager(stats: stats, maxWeaponSlots: 1, maxCardSlots: 1);

      inv.addWeapon(WeaponRegistry.allWeapons.first);
      final weapon = inv.equippedWeapons.first;

      // Upgrade weapon to max 40
      for (int i = 1; i < 40; i++) {
        weapon.upgrade(Rarity.common);
      }
      expect(weapon.isMaxLevel, isTrue);

      // Max card to 99
      final card = UpgradeCards.allCards.first;
      for (int i = 0; i < 99; i++) {
        inv.applyCard(card, Rarity.common);
      }
      expect(inv.cardLevels[card.id], 99);
      expect(inv.isAllMaxedOut, isTrue);

      // Level-up options should now be empty
      expect(inv.generateLevelUpOptions(), isEmpty);
    });
  });
}
