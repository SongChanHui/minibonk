import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/economy_tables.dart';
import '../models/item_definition.dart';
import '../models/rarity.dart';
import '../models/stats.dart';
import '../models/upgrade_card_definition.dart';
import '../models/weapon_definition.dart';
import 'components/drop_item.dart';
import 'components/field_object.dart';
import 'components/floating_damage_text.dart';
import 'components/game_map.dart';
import 'components/monster.dart';
import 'components/player.dart';
import 'components/projectile.dart';
import 'managers/inventory_manager.dart';

class MinibonkGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapCallbacks {
  final int maxWeaponSlots;
  final int maxCardSlots;
  final WeaponDefinition startingWeapon;

  MinibonkGame({
    this.maxWeaponSlots = 4,
    this.maxCardSlots = 4,
    WeaponDefinition? initialWeapon,
  }) : startingWeapon = initialWeapon ?? WeaponRegistry.allWeapons.first;

  // Managers & Core State
  late final PlayerStats stats;
  late final InventoryManager inventory;
  late final PlayerComponent player;
  late final GameMapComponent map;

  int currentStage = 1;
  double elapsedTime = 0.0;
  int killCount = 0;
  int gold = 0;
  int playerLevel = 1;
  int currentExp = 0;
  int targetExp = 7;
  int chestOpenCount = 0;
  int rerollCount = 1;
  int skipCount = 1;

  // Boss & Teleporter
  FieldObjectComponent? teleporter;
  bool isBossSpawned = false;
  bool isBossDefeated = false;

  // Weapon timers
  final Map<String, double> _weaponCooldowns = {};

  // Spawning timers
  double _spawnTimer = 0.0;
  final Random _rng = Random();

  // Active level-up choices for overlay
  List<LevelUpOption> currentLevelUpOptions = [];
  bool isChestRewardModal = false;

  // Zone upgrade choices for overlay
  List<UpgradeCardDefinition> currentZoneOptions = [];
  bool isZoneUpgradeModal = false;

  // Radar
  double teleporterAngle = 0.0;
  bool isTeleporterDiscovered = false;

  // HUD Update notifier - signals HUD to rebuild smoothly on every frame (keyboard or touch)
  final ValueNotifier<int> hudNotifier = ValueNotifier<int>(0);
  final List<String> eventLogs = [];

  // Debug & Pause state
  bool isGodMode = false;
  double gameTimeScale = 1.0;
  double currentFps = 60.0;
  double _fpsTimer = 0.0;
  int _fpsFrames = 0;

  FieldObjectComponent? get nearbyChest {
    FieldObjectComponent? nearest;
    var nearestDistance = 52.0;
    for (final obj in world.children.whereType<FieldObjectComponent>()) {
      if (obj.isActivated ||
          (obj.type != FieldObjectType.chestPaid &&
              obj.type != FieldObjectType.chestGolden)) continue;
      final distance = (obj.position - player.position).length;
      if (distance <= nearestDistance) {
        nearest = obj;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  int get nearbyChestCost => EconomyTables.getChestCost(chestOpenCount + 1);

  void logEvent(String message) {
    final minutes = (elapsedTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedTime % 60).floor().toString().padLeft(2, '0');
    final entry = '[$minutes:$seconds] $message';
    eventLogs.insert(0, entry);
    if (eventLogs.length > 6) eventLogs.removeLast();
    debugPrint(entry);
    hudNotifier.value++;
  }

  @override
  Color backgroundColor() => const Color(0xFF0F141F);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    stats = PlayerStats(rng: _rng);
    inventory = InventoryManager(
      stats: stats,
      maxWeaponSlots: maxWeaponSlots,
      maxCardSlots: maxCardSlots,
      rng: _rng,
    );

    // Equip starting weapon
    inventory.addWeapon(startingWeapon);
    targetExp = EconomyTables.getCumulativeExpForLevel(playerLevel);

    // Create Map & Player
    map = GameMapComponent();
    world.add(map);

    player = PlayerComponent(
      stats: stats,
      position: Vector2.zero(),
    );
    world.add(player);

    // Setup Camera
    camera.follow(player);

    // Generate 128 Field Objects
    _generateFieldObjects();
    logEvent('게임을 시작했습니다.');
  }

  void _generateFieldObjects() {
    const half = 1100.0;
    // 1. Teleporter in center 85% area
    final tpX = (_rng.nextDouble() * 2 - 1) * (half * 0.85);
    final tpY = (_rng.nextDouble() * 2 - 1) * (half * 0.85);
    teleporter = FieldObjectComponent(
      type: FieldObjectType.teleporter,
      position: Vector2(tpX, tpY),
    );
    world.add(teleporter!);

    // Helper to spawn randomly
    Vector2 randomPos() {
      return Vector2(
        (_rng.nextDouble() * 2 - 1) * half,
        (_rng.nextDouble() * 2 - 1) * half,
      );
    }

    // 15 Enhancement Zones (10% golden)
    for (int i = 0; i < 15; i++) {
      final isGolden = _rng.nextDouble() < 0.10;
      world.add(FieldObjectComponent(
        type: isGolden
            ? FieldObjectType.goldenZone
            : FieldObjectType.enhancementZone,
        position: randomPos(),
      ));
    }

    // 40 Paid Chests & 5 Golden Chests
    for (int i = 0; i < 40; i++) {
      world.add(FieldObjectComponent(
        type: FieldObjectType.chestPaid,
        position: randomPos(),
      ));
    }
    for (int i = 0; i < 5; i++) {
      world.add(FieldObjectComponent(
        type: FieldObjectType.chestGolden,
        position: randomPos(),
      ));
    }

    // 44 Jars (28 small, 10 large, 6 hp)
    for (int i = 0; i < 28; i++) {
      world.add(FieldObjectComponent(
        type: FieldObjectType.jarSmall,
        position: randomPos(),
      ));
    }
    for (int i = 0; i < 10; i++) {
      world.add(FieldObjectComponent(
        type: FieldObjectType.jarLarge,
        position: randomPos(),
      ));
    }
    for (int i = 0; i < 6; i++) {
      world.add(FieldObjectComponent(
        type: FieldObjectType.jarHp,
        position: randomPos(),
      ));
    }

    // 1 Shop
    world.add(FieldObjectComponent(
      type: FieldObjectType.shop,
      position: randomPos(),
    ));

    // 2 Duplicators & 2 Converters
    for (int i = 0; i < 2; i++) {
      world.add(FieldObjectComponent(
        type: FieldObjectType.duplicator,
        position: randomPos(),
      ));
      world.add(FieldObjectComponent(
        type: FieldObjectType.converter,
        position: randomPos(),
      ));
    }

    // 3 Magnet statues, 8 Curse totems, 3 Trial totems
    for (int i = 0; i < 3; i++) {
      world.add(FieldObjectComponent(
        type: FieldObjectType.magnetStatue,
        position: randomPos(),
      ));
      world.add(FieldObjectComponent(
        type: FieldObjectType.trialTotem,
        position: randomPos(),
      ));
    }
    for (int i = 0; i < 8; i++) {
      world.add(FieldObjectComponent(
        type: FieldObjectType.curseTotem,
        position: randomPos(),
      ));
    }
  }

  @override
  void update(double dt) {
    final scaledDt = dt * gameTimeScale;
    super.update(scaledDt);

    // Frame-by-frame HUD update notification
    hudNotifier.value++;

    // Calculate real FPS
    _fpsFrames++;
    _fpsTimer += dt;
    if (_fpsTimer >= 0.5) {
      currentFps = _fpsFrames / _fpsTimer;
      _fpsFrames = 0;
      _fpsTimer = 0.0;
    }

    if (player.isDead) {
      pauseEngine();
      overlays.add('game_over');
      return;
    }

    elapsedTime += scaledDt;

    // Check Teleporter Radar
    if (teleporter != null) {
      final diff = teleporter!.position - player.position;
      if (!isTeleporterDiscovered && diff.length < 350.0) {
        isTeleporterDiscovered = true;
        teleporter!.isDiscovered = true;
      }
      if (isTeleporterDiscovered) {
        teleporterAngle = atan2(diff.y, diff.x);
      }
    }

    // Spawning logic based on timer & events
    _updateMonsterSpawns(scaledDt);

    // Auto-fire weapons
    _updateWeapons(scaledDt);

    // Monster movement & collisions
    _updateMonstersAndCollisions(scaledDt);

    // Pickups attraction & collection
    _updatePickups(scaledDt);

    // Field Objects interaction
    _updateFieldObjects(scaledDt);
  }

  void _updateMonsterSpawns(double dt) {
    _spawnTimer += dt;

    // Wave check: 4:00 (240s) and 7:00 (420s) waves last 30s with 3x spawn
    final isWave = (elapsedTime >= 240 && elapsedTime <= 270) ||
        (elapsedTime >= 420 && elapsedTime <= 450);
    double interval = isWave ? 0.35 : 1.1;

    // Swarm start at 10:00 (600s)
    final isSwarmTime = elapsedTime >= 600;
    if (isSwarmTime) {
      interval *= 0.6;
    }

    if (_spawnTimer >= interval) {
      _spawnTimer = 0.0;
      _spawnRandomMonster(isSwarmTime);
    }

    // Midboss spawns at 3:00 (180s) and 8:00 (480s)
    if ((elapsedTime >= 180 && elapsedTime <= 181) ||
        (elapsedTime >= 480 && elapsedTime <= 481)) {
      _spawnMidboss();
    }
  }

  void _spawnRandomMonster(bool isSwarmTime) {
    // 8% elite spawn rate across all stages
    final isElite = _rng.nextDouble() < 0.08;
    final rank = isElite
        ? MonsterRank.elite
        : (isSwarmTime && _rng.nextBool()
            ? MonsterRank.swarm
            : MonsterRank.normal);

    final angle = _rng.nextDouble() * 2 * pi;
    final distance = 420.0 + _rng.nextDouble() * 120.0;
    final pos =
        player.position + Vector2(cos(angle) * distance, sin(angle) * distance);

    final diffScale = stats.difficultyMultiplier;
    world.add(MonsterComponent(
      rank: rank,
      stage: currentStage,
      position: pos,
      hpMultiplier: diffScale,
      damageMultiplier: diffScale,
    ));
  }

  void _spawnMidboss() {
    logEvent('중간 보스가 출현했습니다!');
    final angle = _rng.nextDouble() * 2 * pi;
    final pos =
        player.position + Vector2(cos(angle) * 350.0, sin(angle) * 350.0);
    world.add(MonsterComponent(
      rank: MonsterRank.midboss,
      stage: currentStage,
      position: pos,
      hpMultiplier: stats.difficultyMultiplier,
      damageMultiplier: stats.difficultyMultiplier,
    ));
  }

  void spawnStageBoss() {
    isBossSpawned = true;
    logEvent('스테이지 $currentStage 보스가 출현했습니다!');
    final pos = teleporter!.position + Vector2(0, -60);
    world.add(MonsterComponent(
      rank: MonsterRank.stageBoss,
      stage: currentStage,
      position: pos,
      hpMultiplier: stats.difficultyMultiplier,
      damageMultiplier: stats.difficultyMultiplier,
    ));
  }

  void _updateWeapons(double dt) {
    for (final weapon in inventory.equippedWeapons) {
      _weaponCooldowns[weapon.id] =
          (_weaponCooldowns[weapon.id] ?? 0.0) + dt * stats.attackSpeedMultiplier;

      final cd = weapon.currentCooldown;
      if ((_weaponCooldowns[weapon.id] ?? 0.0) >= cd) {
        _weaponCooldowns[weapon.id] = 0.0;
        _fireWeapon(weapon);
      }
    }
  }

  void _fireWeapon(WeaponDefinition weapon) {
    final monsters = world.children.whereType<MonsterComponent>().toList();
    if (monsters.isEmpty && weapon.weaponType != WeaponType.orbit) return;

    // Find closest monster
    MonsterComponent? closest;
    double closestDist = double.infinity;
    for (final m in monsters) {
      final dist = (m.position - player.position).length;
      if (dist < closestDist) {
        closestDist = dist;
        closest = m;
      }
    }

    final targetDir = (closest != null)
        ? (closest.position - player.position).normalized()
        : player.facingDirection;

    final critRes =
        stats.rollCritHit(weaponBonusCritChance: weapon.currentCritChance);
    final rawDmg = weapon.currentDamage * stats.damageMultiplier;
    final totalAmount =
        stats.rollExtraAmount(weapon.currentAmount.toDouble());

    switch (weapon.id) {
      case 'fiery_orb':
        for (int i = 0; i < totalAmount; i++) {
          final spread = (i - (totalAmount - 1) / 2) * 0.25;
          final dir = Vector2(
            targetDir.x * cos(spread) - targetDir.y * sin(spread),
            targetDir.x * sin(spread) + targetDir.y * cos(spread),
          );
          world.add(Projectile(
            kind: ProjectileKind.fireball,
            damage: rawDmg,
            isCrit: critRes.isCrit,
            critStage: critRes.stage,
            critMult: critRes.multiplier,
            speed: 260.0 * stats.projectileSpeedMultiplier,
            knockback: weapon.currentKnockback * stats.knockbackMultiplier,
            areaSize: weapon.currentArea * stats.sizeMultiplier,
            duration: 2.5 * stats.durationMultiplier,
            position: player.position.clone(),
            direction: dir,
            isExplosion: true,
          ));
        }
        break;

      case 'crystal_bow':
        for (int i = 0; i < totalAmount; i++) {
          final spread = (i - (totalAmount - 1) / 2) * 0.15;
          final dir = Vector2(
            targetDir.x * cos(spread) - targetDir.y * sin(spread),
            targetDir.x * sin(spread) + targetDir.y * cos(spread),
          );
          world.add(Projectile(
            kind: ProjectileKind.arrow,
            damage: rawDmg,
            isCrit: critRes.isCrit,
            critStage: critRes.stage,
            critMult: critRes.multiplier,
            speed: 380.0 * stats.projectileSpeedMultiplier,
            knockback: weapon.currentKnockback * stats.knockbackMultiplier,
            areaSize: weapon.currentArea * stats.sizeMultiplier,
            duration: 1.8 * stats.durationMultiplier,
            position: player.position.clone(),
            direction: dir,
            pierceCount: 4,
          ));
        }
        break;

      case 'ghostly_daggers':
        world.add(Projectile(
          kind: ProjectileKind.dagger,
          damage: rawDmg,
          isCrit: critRes.isCrit,
          critStage: critRes.stage,
          critMult: critRes.multiplier,
          speed: 460.0 * stats.projectileSpeedMultiplier,
          knockback: weapon.currentKnockback * stats.knockbackMultiplier,
          areaSize: weapon.currentArea * stats.sizeMultiplier,
          duration: 1.2 * stats.durationMultiplier,
          position: player.position.clone(),
          direction: targetDir,
          pierceCount: 1,
        ));
        break;

      case 'lightning_gauntlet':
        if (closest != null) {
          world.add(Projectile(
            kind: ProjectileKind.lightningBolt,
            damage: rawDmg,
            isCrit: critRes.isCrit,
            critStage: critRes.stage,
            critMult: critRes.multiplier,
            speed: 0.0,
            knockback: weapon.currentKnockback * stats.knockbackMultiplier,
            areaSize: weapon.currentArea * stats.sizeMultiplier,
            duration: 0.35,
            position: closest.position.clone(),
            isExplosion: true,
          ));
        }
        break;

      case 'frozen_shard':
        world.add(Projectile(
          kind: ProjectileKind.frostTrap,
          damage: rawDmg,
          isCrit: critRes.isCrit,
          critStage: critRes.stage,
          critMult: critRes.multiplier,
          speed: 0.0,
          knockback: 0.5,
          areaSize: 2.2 * weapon.currentArea * stats.sizeMultiplier,
          duration: weapon.currentDuration * stats.durationMultiplier,
          position: player.position.clone(),
        ));
        break;

      case 'reflective_shield':
        final existing = world.children
            .whereType<Projectile>()
            .where((p) => p.kind == ProjectileKind.orbitShield)
            .length;
        if (existing < totalAmount) {
          world.add(Projectile(
            kind: ProjectileKind.orbitShield,
            damage: rawDmg,
            isCrit: critRes.isCrit,
            critStage: critRes.stage,
            critMult: critRes.multiplier,
            speed: 0.0,
            knockback: 4.0 * stats.knockbackMultiplier,
            areaSize: weapon.currentArea * stats.sizeMultiplier,
            duration: 9999.0,
            position: player.position.clone(),
            orbitDistance: 55.0,
          ));
        }
        break;

      default:
        // Default slash / projectile
        world.add(Projectile(
          kind: ProjectileKind.dagger,
          damage: rawDmg,
          isCrit: critRes.isCrit,
          critStage: critRes.stage,
          critMult: critRes.multiplier,
          speed: 300.0 * stats.projectileSpeedMultiplier,
          knockback: weapon.currentKnockback * stats.knockbackMultiplier,
          areaSize: weapon.currentArea * stats.sizeMultiplier,
          duration: 1.5 * stats.durationMultiplier,
          position: player.position.clone(),
          direction: targetDir,
        ));
    }
  }

  void _updateMonstersAndCollisions(double dt) {
    final monsters = world.children.whereType<MonsterComponent>().toList();
    final projectiles = world.children.whereType<Projectile>().toList();

    // Update Orbiting Projectiles
    int shieldIndex = 0;
    for (final proj in projectiles) {
      if (proj.kind == ProjectileKind.orbitShield ||
          proj.kind == ProjectileKind.orbitRock) {
        proj.orbitAngle += dt * 3.5;
        final offsetAngle = proj.orbitAngle + shieldIndex * (2 * pi / 3);
        proj.position = player.position +
            Vector2(cos(offsetAngle) * proj.orbitDistance,
                sin(offsetAngle) * proj.orbitDistance);
        shieldIndex++;
      } else if (proj.kind == ProjectileKind.boomerang && proj.isReturning) {
        final toPlayer = (player.position - proj.position).normalized();
        proj.position += toPlayer * proj.speed * dt;
        if ((player.position - proj.position).length < 20.0) {
          proj.removeFromParent();
        }
      }
    }

    // Monster movement & Projectile hit checks
    for (final monster in monsters) {
      if (monster.isDead) continue;

      // Move toward player
      final toPlayer = (player.position - monster.position).normalized();
      monster.position += toPlayer * monster.speed * dt;

      // Check contact damage with player
      final distToPlayer = (monster.position - player.position).length;
      if (distToPlayer < (player.size.x / 2 + monster.size.x / 2)) {
        final damaged = player.takeDamage(monster.touchDamage);
        if (damaged) {
          // Thorns reflection
          if (stats.thorns > 0) {
            monster.takeDamage(stats.thorns);
            world.add(FloatingDamageText(
              text: stats.thorns.toInt().toString(),
              position: monster.position.clone(),
            ));
          }
        }
      }

      // Check Projectile hits
      for (final proj in projectiles) {
        if (proj.hitMonsterIds.contains(monster.monsterId)) continue;

        final hitDist = (proj.position - monster.position).length;
        final maxHitRadius = (proj.size.x / 2 + monster.size.x / 2);

        if (hitDist <= maxHitRadius) {
          proj.hitMonsterIds.add(monster.monsterId);
          final finalDmg = proj.damage * (proj.isCrit ? proj.critMult : 1.0);
          final kbDir = (monster.position - player.position).normalized();

          monster.takeDamage(
            finalDmg,
            knockbackDir: kbDir,
            knockbackForce: proj.knockback,
          );

          // Lifesteal roll
          if (stats.lifesteal > 0 &&
              _rng.nextDouble() * 100.0 < stats.lifesteal) {
            player.heal(1.0);
          }

          // Damage text
          world.add(FloatingDamageText(
            text: finalDmg.round().toString(),
            position: monster.position.clone() + Vector2(0, -12),
            isCrit: proj.isCrit,
            critStage: proj.critStage,
          ));

          // Splash explosion
          if (proj.isExplosion) {
            final splashRadius = 55.0 * proj.areaSize;
            for (final other in monsters) {
              if (other.monsterId != monster.monsterId &&
                  (other.position - proj.position).length <= splashRadius) {
                other.takeDamage(finalDmg * 0.7);
              }
            }
          }

          // Pierce count decrement
          proj.pierceCount--;
          if (proj.pierceCount <= 0 &&
              proj.kind != ProjectileKind.orbitShield &&
              proj.kind != ProjectileKind.orbitRock &&
              proj.kind != ProjectileKind.frostTrap) {
            proj.removeFromParent();
          }
        }
      }

      // Check Monster death
      if (monster.isDead) {
        monster.removeFromParent();
        killCount++;

        // Drops based on rank
        _onMonsterKilled(monster);
      }
    }
  }

  void _onMonsterKilled(MonsterComponent monster) {
    final pos = monster.position.clone();

    if (monster.rank == MonsterRank.stageBoss) {
      isBossDefeated = true;
      teleporter?.isActivated = true;
      logEvent('스테이지 $currentStage 보스를 처치했습니다. 포탈에서 E키를 누르세요.');
      world.add(DropItem(type: DropType.expLarge, value: 100, position: pos));
      world.add(DropItem(type: DropType.goldCoin, value: 100, position: pos));
      if (currentStage >= 3) {
        pauseEngine();
        overlays.add('victory');
      }
      return;
    }

    if (monster.rank == MonsterRank.midboss) {
      world.add(DropItem(type: DropType.expLarge, value: 50, position: pos));
      world.add(DropItem(type: DropType.goldCoin, value: 50, position: pos));
      world.add(DropItem(type: DropType.droppedChest, value: 1, position: pos));
      return;
    }

    if (monster.rank == MonsterRank.elite) {
      world.add(DropItem(type: DropType.expMedium, value: 10, position: pos));
      world.add(DropItem(type: DropType.goldCoin, value: 10, position: pos));
      if (_rng.nextDouble() < 0.30) {
        world.add(
            DropItem(type: DropType.droppedChest, value: 1, position: pos));
      }
      return;
    }

    // Normal / Swarm
    world.add(DropItem(type: DropType.expSmall, value: 1, position: pos));
    if (_rng.nextDouble() < 0.40) {
      world.add(DropItem(type: DropType.goldCoin, value: 1, position: pos));
    }
    // 2% chance for health potion
    if (_rng.nextDouble() < 0.02) {
      world.add(DropItem(type: DropType.healthPotion, value: 15, position: pos));
    }
  }

  void _updatePickups(double dt) {
    final drops = world.children.whereType<DropItem>().toList();
    final pickupR = stats.pickupRange;

    for (final drop in drops) {
      final dist = (drop.position - player.position).length;
      if (dist <= pickupR) {
        drop.isBeingAttracted = true;
      }

      if (drop.isBeingAttracted) {
        final dir = (player.position - drop.position).normalized();
        drop.position += dir * (320.0 * dt);

        if (dist < 18.0) {
          drop.removeFromParent();
          _collectDrop(drop);
        }
      }
    }
  }

  void _collectDrop(DropItem drop) {
    switch (drop.type) {
      case DropType.expSmall:
      case DropType.expMedium:
      case DropType.expLarge:
        final gainedExp = (drop.value * stats.xpGainMultiplier).round();
        currentExp += gainedExp;
        if (currentExp >= targetExp) {
          _triggerLevelUp();
        }
        break;

      case DropType.goldCoin:
        final gainedGold = (drop.value * stats.goldGainMultiplier).round();
        gold += gainedGold;
        break;

      case DropType.pinkCoin:
        final gainedGold = (drop.value * 8 * stats.goldGainMultiplier).round();
        gold += gainedGold;
        break;

      case DropType.healthPotion:
        player.heal(drop.value.toDouble());
        break;

      case DropType.droppedChest:
        _openFreeChest();
        break;
    }
  }

  void _triggerLevelUp() {
    playerLevel++;
    logEvent('레벨이 $playerLevel로 올랐습니다. 능력을 선택하세요.');
    currentExp -= targetExp;
    targetExp = EconomyTables.getExpToNextLevel(playerLevel);

    currentLevelUpOptions = inventory.generateLevelUpOptions(4);
    if (currentLevelUpOptions.isNotEmpty) {
      pauseEngine();
      overlays.add('upgrade');
    }
  }

  void _openFreeChest() {
    _showChestRewards();
  }

  void _showChestRewards() {
    final items = List<PassiveItemDefinition>.from(ItemRegistry.allItems)
      ..shuffle(_rng);
    isChestRewardModal = true;
    isZoneUpgradeModal = false;
    currentLevelUpOptions = items.take(3).map((item) {
      final rarity = Rarity.rollWithLuck(stats.luck, _rng);
      final increase = item.baseStatValue * rarity.multiplier;
      return LevelUpOption(
        isWeapon: false,
        passiveItem: item,
        rarity: rarity,
        isNew: true,
        title: item.nameKo,
        levelText: '${rarity.nameKo} 아이템',
        description: '${item.description} 능력치 +${increase.toStringAsFixed(1)}',
        assetPath: item.assetPath,
      );
    }).toList();
    logEvent('상자 보상 3개 중 아이템을 선택하세요.');
    pauseEngine();
    overlays.add('upgrade');
  }

  void _updateFieldObjects(double dt) {
    final objects = world.children.whereType<FieldObjectComponent>().toList();

    for (final obj in objects) {
      final dist = (obj.position - player.position).length;

      // Teleporter Interaction
      if (obj.type == FieldObjectType.teleporter) {
        if (dist < 40.0) {
          if (!isBossSpawned) {
            spawnStageBoss();
          } else if (isBossDefeated && obj.isActivated) {
            _advanceToNextStage();
          }
        }
      }

      // Enhancement Zone
      else if (obj.type == FieldObjectType.enhancementZone ||
          obj.type == FieldObjectType.goldenZone) {
        if (!obj.isActivated && dist < 32.0) {
          obj.chargeTimer += dt;
          if (obj.chargeTimer >= obj.chargeDuration) {
            obj.isActivated = true;
            logEvent(obj.type == FieldObjectType.goldenZone
                ? '황금 강화 구역을 활성화했습니다.'
                : '강화 구역을 활성화했습니다.');
            _triggerZoneUpgrade(obj.type == FieldObjectType.goldenZone);
          }
        } else if (!obj.isActivated) {
          obj.chargeTimer = max(0.0, obj.chargeTimer - dt * 0.5);
        }
      }

      // Breakable Jars
      else if (obj.type == FieldObjectType.jarSmall ||
          obj.type == FieldObjectType.jarLarge ||
          obj.type == FieldObjectType.jarHp) {
        if (!obj.isActivated && dist < 26.0) {
          obj.isActivated = true;
          obj.removeFromParent();
          _breakJar(obj);
        }
      }

      // Magnet Statue
      else if (obj.type == FieldObjectType.magnetStatue &&
          !obj.isActivated &&
          dist < 30.0) {
        obj.isActivated = true;
        _pullAllGems();
      }

      // Curse Totem
      else if (obj.type == FieldObjectType.curseTotem &&
          !obj.isActivated &&
          dist < 30.0) {
        obj.isActivated = true;
        stats.addCardStat(StatType.difficulty, 5.0);
      }
    }
  }

  void _breakJar(FieldObjectComponent jar) {
    final isLarge = jar.type == FieldObjectType.jarLarge;
    final isHp = jar.type == FieldObjectType.jarHp;

    if (isHp) {
      world.add(DropItem(
          type: DropType.healthPotion, value: 25, position: jar.position));
      return;
    }

    final goldAmount = isLarge ? 20 : 10;
    world.add(DropItem(
        type: DropType.goldCoin, value: goldAmount, position: jar.position));
    world.add(DropItem(
        type: DropType.expSmall,
        value: isLarge ? 5 : 2,
        position: jar.position));

    // Pink coin chance
    final pinkChance = isLarge ? 0.20 : 0.10;
    if (_rng.nextDouble() < pinkChance) {
      world.add(DropItem(
          type: DropType.pinkCoin,
          value: goldAmount * 5,
          position: jar.position));
    }
  }

  void _pullAllGems() {
    for (final drop in world.children.whereType<DropItem>()) {
      drop.isBeingAttracted = true;
    }
  }

  void _triggerZoneUpgrade(bool isGolden) {
    final shuffled = List<UpgradeCardDefinition>.from(UpgradeCards.allCards)
      ..shuffle(_rng);
    currentZoneOptions = shuffled.take(3).toList();
    isZoneUpgradeModal = true;
    currentLevelUpOptions = currentZoneOptions.map((card) {
      final rarity =
          isGolden ? Rarity.legendary : Rarity.rollWithLuck(stats.luck, _rng);
      final inc = card.baseZoneIncrease * rarity.multiplier;
      return LevelUpOption(
        isWeapon: false,
        card: card,
        rarity: rarity,
        isNew: false,
        title: card.nameEn,
        levelText: '강화 존 보너스',
        description: '${card.nameKo} +${inc.toStringAsFixed(1)}',
        assetPath: card.assetPath,
      );
    }).toList();

    pauseEngine();
    overlays.add('upgrade');
  }

  void selectLevelUpOption(LevelUpOption option) {
    if (option.passiveItem != null && isChestRewardModal) {
      final item = option.passiveItem!;
      final stat = item.primaryStat;
      if (stat != null) {
        final before = stats.getRawStatSum(stat);
        final increase = item.baseStatValue * option.rarity.multiplier;
        stats.addItemStat(stat, increase);
        final after = stats.getRawStatSum(stat);
        logEvent('${item.nameKo} 획득: ${stat.nameKo} ${before.toStringAsFixed(1)} → ${after.toStringAsFixed(1)}');
      }
      gold += 50;
      logEvent('상자 보상 골드 +50');
    } else if (option.isWeapon && option.weapon != null) {
      if (option.isNew) {
        inventory.addWeapon(option.weapon!, rarity: option.rarity);
      } else {
        option.weapon!.upgrade(option.rarity, _rng);
      }
      logEvent('${option.title} 무기 강화가 적용되었습니다.');
    } else if (option.card != null) {
      final stat = option.card!.targetStat;
      final before = stats.getRawStatSum(stat);
      if (isZoneUpgradeModal) {
        inventory.applyZoneUpgrade(option.card!, option.rarity);
      } else {
        inventory.applyCard(option.card!, option.rarity);
      }
      final after = stats.getRawStatSum(stat);
      logEvent('${stat.nameKo} ${before.toStringAsFixed(1)} → ${after.toStringAsFixed(1)}');
    }

    isChestRewardModal = false;
    isZoneUpgradeModal = false;
    overlays.remove('upgrade');
    resumeEngine();
  }

  void rerollUpgradeOptions() {
    if (rerollCount > 0) {
      rerollCount--;
      currentLevelUpOptions = inventory.generateLevelUpOptions(4);
    }
  }

  void skipUpgradeOptions() {
    if (!isChestRewardModal && skipCount > 0) {
      skipCount--;
      isZoneUpgradeModal = false;
      overlays.remove('upgrade');
      resumeEngine();
    }
  }

  void _advanceToNextStage() {
    if (currentStage >= 3) {
      pauseEngine();
      overlays.add('victory');
      return;
    }
    currentStage++;
    logEvent('$currentStage 스테이지로 이동했습니다.');
    isBossSpawned = false;
    isBossDefeated = false;

    // Clear enemies and field objects
    for (final m in world.children.whereType<MonsterComponent>().toList()) {
      m.removeFromParent();
    }
    for (final obj in world.children.whereType<FieldObjectComponent>().toList()) {
      obj.removeFromParent();
    }
    for (final d in world.children.whereType<DropItem>().toList()) {
      d.removeFromParent();
    }

    player.position = Vector2.zero();
    _generateFieldObjects();
  }

  // --- Pause & Debug System Methods ---

  void togglePause() {
    if (overlays.isActive('pause')) {
      resumeGame();
    } else {
      if (overlays.isActive('upgrade') ||
          overlays.isActive('game_over') ||
          overlays.isActive('victory')) {
        return;
      }
      pauseGame();
    }
  }

  void pauseGame() {
    pauseEngine();
    overlays.add('pause');
  }

  void resumeGame() {
    overlays.remove('pause');
    resumeEngine();
  }

  void toggleDebugOverlay() {
    if (overlays.isActive('debug')) {
      overlays.remove('debug');
    } else {
      overlays.add('debug');
    }
  }

  void debugLevelUp() {
    currentExp = targetExp;
    _triggerLevelUp();
  }

  void debugAddExp([int amount = 500]) {
    currentExp += amount;
    while (currentExp >= targetExp) {
      _triggerLevelUp();
    }
  }

  void debugAddGold([int amount = 1000]) {
    gold += amount;
  }

  void debugHealFull() {
    player.currentHp = player.maxHp;
  }

  void debugToggleGodMode() {
    isGodMode = !isGodMode;
    player.isGodMode = isGodMode;
  }

  void debugKillAllMonsters() {
    for (final m in world.children.whereType<MonsterComponent>().toList()) {
      m.takeDamage(999999);
    }
  }

  void debugSpawnMidboss() {
    _spawnMidboss();
  }

  void debugSpawnBoss() {
    if (teleporter != null) {
      spawnStageBoss();
    }
  }

  void debugNextStage() {
    _advanceToNextStage();
  }

  void debugTriggerZone([bool isGolden = false]) {
    _triggerZoneUpgrade(isGolden);
  }

  void debugAddRollsAndSkips([int amount = 5]) {
    rerollCount += amount;
    skipCount += amount;
  }

  void debugSetTimeScale(double scale) {
    gameTimeScale = scale;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final isDown = event is KeyDownEvent || event is KeyRepeatEvent;
    final isOnlyDown = event is KeyDownEvent;

    // Toggle Pause with Escape
    if (isOnlyDown && event.logicalKey == LogicalKeyboardKey.escape) {
      togglePause();
      return KeyEventResult.handled;
    }

    // Toggle Debug with F1 or Backquote (` ~)
    if (isOnlyDown &&
        (event.logicalKey == LogicalKeyboardKey.f1 ||
            event.logicalKey == LogicalKeyboardKey.backquote)) {
      toggleDebugOverlay();
      return KeyEventResult.handled;
    }

    if (isOnlyDown && event.logicalKey == LogicalKeyboardKey.keyE) {
      _interactWithNearbyChest();
    }

    // If modal overlays are active, ignore gameplay directional input
    if (overlays.isActive('pause') ||
        overlays.isActive('upgrade') ||
        overlays.isActive('game_over') ||
        overlays.isActive('victory')) {
      player.keyboardInput = Vector2.zero();
      return KeyEventResult.handled;
    }

    Vector2 dir = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      dir.y -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS) ||
        keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      dir.y += 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      dir.x -= 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      dir.x += 1;
    }

    player.keyboardInput = dir;

    if (isDown && keysPressed.contains(LogicalKeyboardKey.space)) {
      player.triggerDash();
    }

    return KeyEventResult.handled;
  }

  void _interactWithNearbyChest() {
    if (overlays.isActive('pause') ||
        overlays.isActive('upgrade') ||
        overlays.isActive('game_over') ||
        overlays.isActive('victory')) {
      return;
    }

    final chest = nearbyChest;

    if (chest == null) return;
    final isPaid = chest.type == FieldObjectType.chestPaid;
    final cost = EconomyTables.getChestCost(chestOpenCount + 1);
    if (isPaid && gold < cost) {
      logEvent('골드가 부족합니다. 상자 가격 $cost G / 보유 골드 $gold G');
      return;
    }

    if (isPaid) {
      gold -= cost;
      chestOpenCount++;
    }
    chest.isActivated = true;
    logEvent(isPaid ? '상자를 열었습니다. 비용 $cost G' : '황금 상자를 열었습니다.');
    _openFreeChest();
    hudNotifier.value++;
  }
}
