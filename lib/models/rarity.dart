import 'dart:math';
import 'package:flutter/material.dart';

enum Rarity {
  common,
  uncommon,
  rare,
  epic,
  legendary;

  String get nameKo {
    switch (this) {
      case Rarity.common:
        return '커먼';
      case Rarity.uncommon:
        return '언커먼';
      case Rarity.rare:
        return '레어';
      case Rarity.epic:
        return '에픽';
      case Rarity.legendary:
        return '레전더리';
    }
  }

  Color get color {
    switch (this) {
      case Rarity.common:
        return const Color(0xFFB0BEC5);
      case Rarity.uncommon:
        return const Color(0xFF4CAF50);
      case Rarity.rare:
        return const Color(0xFF2196F3);
      case Rarity.epic:
        return const Color(0xFFAB47BC);
      case Rarity.legendary:
        return const Color(0xFFFFB300);
    }
  }

  double get baseWeight {
    switch (this) {
      case Rarity.common:
        return 650.0;
      case Rarity.uncommon:
        return 200.0;
      case Rarity.rare:
        return 100.0;
      case Rarity.epic:
        return 40.0;
      case Rarity.legendary:
        return 10.0;
    }
  }

  double get efficiency {
    switch (this) {
      case Rarity.common:
        return 0.0;
      case Rarity.uncommon:
        return 0.1;
      case Rarity.rare:
        return 0.3;
      case Rarity.epic:
        return 1.0;
      case Rarity.legendary:
        return 15.0;
    }
  }

  double get multiplier {
    switch (this) {
      case Rarity.common:
        return 1.0;
      case Rarity.uncommon:
        return 1.2;
      case Rarity.rare:
        return 1.4;
      case Rarity.epic:
        return 1.6;
      case Rarity.legendary:
        return 2.0;
    }
  }

  /// Calculates weight with player luck
  double getFinalWeight(double luckPercent) {
    return baseWeight * (1.0 + (luckPercent / 100.0) * efficiency);
  }

  /// Roll number of simultaneously upgraded stats for weapons
  int rollStatCount([Random? rng]) {
    final rand = rng ?? Random();
    final roll = rand.nextDouble() * 100.0;
    switch (this) {
      case Rarity.common:
        if (roll < 60.0) return 1;
        if (roll < 95.0) return 2;
        return 3;
      case Rarity.uncommon:
        if (roll < 45.0) return 1;
        if (roll < 85.0) return 2;
        return 3;
      case Rarity.rare:
        if (roll < 20.0) return 1;
        if (roll < 65.0) return 2;
        return 3;
      case Rarity.epic:
        if (roll < 5.0) return 1;
        if (roll < 40.0) return 2;
        return 3;
      case Rarity.legendary:
        if (roll < 10.0) return 2;
        return 3;
    }
  }

  static Rarity rollWithLuck(double luckPercent, [Random? rng]) {
    final rand = rng ?? Random();
    final weights = {
      for (final r in Rarity.values) r: r.getFinalWeight(luckPercent),
    };
    final totalWeight = weights.values.fold(0.0, (a, b) => a + b);
    double pick = rand.nextDouble() * totalWeight;
    for (final entry in weights.entries) {
      pick -= entry.value;
      if (pick <= 0) {
        return entry.key;
      }
    }
    return Rarity.common;
  }
}
