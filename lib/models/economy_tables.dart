import 'rarity.dart';

class EconomyTables {
  // Hardcoded early cumulative EXP for levels 1~10
  static const Map<int, int> _earlyLevelExp = {
    1: 7,
    2: 23,
    3: 45,
    4: 74,
    5: 108,
    6: 149,
    7: 196,
    8: 254,
    9: 310,
    10: 377,
  };

  static int getCumulativeExpForLevel(int level) {
    if (level <= 0) return 0;
    if (level <= 10) {
      return _earlyLevelExp[level] ?? 7;
    }
    // Formula for level >= 11: 3.5 * N^2 + 1.5 * N
    final n = level.toDouble();
    return (3.5 * n * n + 1.5 * n).round();
  }

  static int getExpToNextLevel(int currentLevel) {
    return getCumulativeExpForLevel(currentLevel + 1) -
        getCumulativeExpForLevel(currentLevel);
  }

  // Chest costs for 1~33 opens
  static const List<int> _chestCosts = [
    30, // 1
    72, // 2
    115, // 3
    159, // 4
    206, // 5
    256, // 6
    309, // 7
    366, // 8
    427, // 9
    495, // 10
    569, // 11
    952, // 12
    1346, // 13
    1753, // 14
    2175, // 15
    2617, // 16
    3083, // 17
    3577, // 18
    4105, // 19
    4677, // 20
    5301, // 21
    6538, // 22
    7853, // 23
    9262, // 24
    10786, // 25
    12451, // 26
    14288, // 27
    16334, // 28
    18636, // 29
    21249, // 30
    24243, // 31
    34123, // 32
    40037, // 33
  ];

  static int getChestCost(int openCount) {
    if (openCount <= 0) return _chestCosts.first;
    if (openCount <= _chestCosts.length) {
      return _chestCosts[openCount - 1];
    }
    // Beyond 33: continue exponential growth
    final extra = openCount - _chestCosts.length;
    return (_chestCosts.last * (1.0 + 0.15 * extra)).round();
  }

  static int getShopItemPrice(Rarity rarity, num elapsedSeconds) {
    final sec = elapsedSeconds.toDouble();
    int basePrice;

    if (sec < 300) {
      // 0 ~ 5 min
      switch (rarity) {
        case Rarity.common:
          basePrice = 50;
          break;
        case Rarity.uncommon:
          basePrice = 120;
          break;
        case Rarity.rare:
          basePrice = 300;
          break;
        case Rarity.epic:
          basePrice = 600;
          break;
        case Rarity.legendary:
          basePrice = 1200;
          break;
      }
    } else if (sec < 600) {
      // 5 ~ 10 min
      switch (rarity) {
        case Rarity.common:
          basePrice = 120;
          break;
        case Rarity.uncommon:
          basePrice = 300;
          break;
        case Rarity.rare:
          basePrice = 700;
          break;
        case Rarity.epic:
          basePrice = 1400;
          break;
        case Rarity.legendary:
          basePrice = 2800;
          break;
      }
    } else if (sec < 900) {
      // 10 ~ 15 min
      switch (rarity) {
        case Rarity.common:
          basePrice = 250;
          break;
        case Rarity.uncommon:
          basePrice = 600;
          break;
        case Rarity.rare:
          basePrice = 1500;
          break;
        case Rarity.epic:
          basePrice = 3000;
          break;
        case Rarity.legendary:
          basePrice = 6000;
          break;
      }
    } else if (sec < 1200) {
      // 15 ~ 20 min
      switch (rarity) {
        case Rarity.common:
          basePrice = 500;
          break;
        case Rarity.uncommon:
          basePrice = 1200;
          break;
        case Rarity.rare:
          basePrice = 3000;
          break;
        case Rarity.epic:
          basePrice = 6000;
          break;
        case Rarity.legendary:
          basePrice = 12000;
          break;
      }
    } else if (sec < 1800) {
      // 20 ~ 30 min
      switch (rarity) {
        case Rarity.common:
          basePrice = 1000;
          break;
        case Rarity.uncommon:
          basePrice = 2400;
          break;
        case Rarity.rare:
          basePrice = 6000;
          break;
        case Rarity.epic:
          basePrice = 12000;
          break;
        case Rarity.legendary:
          basePrice = 24000;
          break;
      }
    } else {
      // 30 min +
      switch (rarity) {
        case Rarity.common:
          basePrice = 2000;
          break;
        case Rarity.uncommon:
          basePrice = 4800;
          break;
        case Rarity.rare:
          basePrice = 12000;
          break;
        case Rarity.epic:
          basePrice = 24000;
          break;
        case Rarity.legendary:
          basePrice = 48000;
          break;
      }
    }

    return basePrice;
  }
}
