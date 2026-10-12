import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../models/stats.dart';

class PlayerComponent extends PositionComponent {
  final PlayerStats stats;
  double currentHp = 100.0;
  Vector2 velocity = Vector2.zero();
  Vector2 facingDirection = Vector2(1, 0);

  // Dash
  bool isDashing = false;
  double dashDurationTimer = 0.0;
  final double dashDuration = 0.22;
  double dashCooldownTimer = 0.0;
  final double dashCooldown = 2.5;

  // Invulnerability & God mode
  double _invulnerableTimer = 0.0;
  bool isGodMode = false;

  // Movement input
  Vector2 keyboardInput = Vector2.zero();
  Vector2 joystickInput = Vector2.zero();

  // Animation & Trail
  double _animTime = 0.0;
  final List<Vector2> _dashTrail = [];

  PlayerComponent({
    required this.stats,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(30, 30),
          anchor: Anchor.center,
        ) {
    currentHp = stats.maxHp;
  }

  double get maxHp => stats.maxHp;
  bool get isDead => currentHp <= 0;
  double get dashCooldownPercent =>
      (dashCooldownTimer / dashCooldown).clamp(0.0, 1.0);

  void triggerDash() {
    if (dashCooldownTimer <= 0 && !isDashing) {
      isDashing = true;
      dashDurationTimer = dashDuration;
      dashCooldownTimer = dashCooldown;
    }
  }

  bool takeDamage(double rawDamage) {
    if (isGodMode || _invulnerableTimer > 0 || isDashing) return false;

    // Check Evasion
    if (stats.rollEvasion()) {
      return false; // Evaded!
    }

    // Apply Armor reduction
    final finalDamage = stats.applyArmorReduction(rawDamage);
    currentHp = (currentHp - finalDamage).clamp(0.0, stats.maxHp);
    _invulnerableTimer = 0.35; // 0.35s i-frame
    return true;
  }

  void heal(double amount) {
    currentHp = (currentHp + amount).clamp(0.0, stats.maxHp);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt * 6;

    // HP Regen per second
    if (currentHp < stats.maxHp && !isDead) {
      heal(stats.hpRegen * dt);
    }

    // Cooldowns
    if (dashCooldownTimer > 0) {
      dashCooldownTimer -= dt;
    }
    if (_invulnerableTimer > 0) {
      _invulnerableTimer -= dt;
    }

    // Direction input vector
    Vector2 moveDir = keyboardInput + joystickInput;
    if (moveDir.length2 > 1.0) {
      moveDir.normalize();
    }

    if (moveDir.length2 > 0.05) {
      facingDirection = moveDir.clone()..normalize();
    }

    // Handle Dash
    double currentSpeed = 160.0 * stats.moveSpeedMultiplier;
    if (isDashing) {
      dashDurationTimer -= dt;
      currentSpeed *= 3.2;
      _dashTrail.add(position.clone());
      if (_dashTrail.length > 6) {
        _dashTrail.removeAt(0);
      }
      if (dashDurationTimer <= 0) {
        isDashing = false;
        _dashTrail.clear();
      }
    }

    velocity = (isDashing ? facingDirection : moveDir) * currentSpeed;
    position += velocity * dt;

    // Map bounds clamping: 240x240 units map (e.g. -1200 to +1200)
    const mapHalfSize = 1200.0;
    position.x = position.x.clamp(-mapHalfSize + 20, mapHalfSize - 20);
    position.y = position.y.clamp(-mapHalfSize + 20, mapHalfSize - 20);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);

    // Render neon dash trails
    final neonColor = isGodMode
        ? const Color(0xFFFFD700)
        : const Color(0xFF00E5FF);

    for (int i = 0; i < _dashTrail.length; i++) {
      final trailPos = _dashTrail[i] - position;
      final alpha = (i + 1) / (_dashTrail.length + 1) * 0.55;
      final trailOffset = Offset(center.dx + trailPos.x, center.dy + trailPos.y);

      // Outer neon trail bloom
      canvas.drawCircle(
        trailOffset,
        size.x / 2.0,
        Paint()
          ..color = neonColor.withValues(alpha: alpha * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Dark trail core
      canvas.drawCircle(
        trailOffset,
        size.x / 2.4,
        Paint()..color = const Color(0xFF0A0E18).withValues(alpha: alpha * 0.8),
      );
      // Neon rim
      canvas.drawCircle(
        trailOffset,
        size.x / 2.4,
        Paint()
          ..color = neonColor.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    // Blink if invulnerable
    if (_invulnerableTimer > 0 && (_animTime * 4).toInt() % 2 == 0) {
      return;
    }

    // 1. Emissive Neon Bloom Outer Ring (Pulsating)
    final pulse = 0.5 + 0.3 * sin(_animTime);
    final auraGlowPaint = Paint()
      ..color = neonColor.withValues(alpha: isGodMode ? 0.65 : 0.35 + pulse * 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, (size.x / 2) + 4.0, auraGlowPaint);

    // 2. High-Tech Emissive Neon Stroke Ring
    final auraRimPaint = Paint()
      ..color = neonColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, (size.x / 2) + 1.0, auraRimPaint);

    // 3. Dark Stealth Chassis / Nano-Mantle (Dark obsidian tone)
    final darkBodyPaint = Paint()..color = const Color(0xFF0A0E17);
    canvas.drawCircle(center, size.x / 2, darkBodyPaint);

    // 4. Inner Tactical Carbon Armor Shell
    final armorPaint = Paint()
      ..color = isGodMode ? const Color(0xFF2A1C08) : const Color(0xFF121824);
    canvas.drawCircle(center, size.x * 0.42, armorPaint);

    // 5. Neon Energy Circuits on Cloak (Subtle diagonal energy seams)
    final seamPaint = Paint()
      ..color = neonColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final perp = Offset(-facingDirection.y * 6, facingDirection.x * 6);
    canvas.drawLine(center - perp, center + perp, seamPaint);

    // 6. Directional Stealth Visor / Mask
    final faceCenter = Offset(
      center.dx + facingDirection.x * 5.5,
      center.dy + facingDirection.y * 5.5,
    );

    // Dark visor housing
    final visorHousingPaint = Paint()..color = const Color(0xFF05080E);
    canvas.drawCircle(faceCenter, size.x * 0.22, visorHousingPaint);

    // 7. Glowing Neon Visor Optics (Cyber slit / twin laser nodes)
    final eyeOffsetPerp =
        Offset(-facingDirection.y * 3.6, facingDirection.x * 3.6);
    final eyeForward =
        Offset(facingDirection.x * 2.2, facingDirection.y * 2.2);

    // Neon eye bloom
    final eyeGlowPaint = Paint()
      ..color = neonColor.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(faceCenter + eyeOffsetPerp + eyeForward, 2.2, eyeGlowPaint);
    canvas.drawCircle(faceCenter - eyeOffsetPerp + eyeForward, 2.2, eyeGlowPaint);

    // Crisp neon eye core
    final eyeCorePaint = Paint()..color = Colors.white;
    canvas.drawCircle(faceCenter + eyeOffsetPerp + eyeForward, 1.4, eyeCorePaint);
    canvas.drawCircle(faceCenter - eyeOffsetPerp + eyeForward, 1.4, eyeCorePaint);

    // 8. Forward Pointing Neon Energy Chevron
    final chevronTip = faceCenter + Offset(facingDirection.x * 5.0, facingDirection.y * 5.0);
    final chevronWing1 = faceCenter + eyeOffsetPerp * 0.8;
    final chevronWing2 = faceCenter - eyeOffsetPerp * 0.8;
    final chevronPath = Path()
      ..moveTo(chevronWing1.dx, chevronWing1.dy)
      ..lineTo(chevronTip.dx, chevronTip.dy)
      ..lineTo(chevronWing2.dx, chevronWing2.dy);
    final chevronPaint = Paint()
      ..color = neonColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4;
    canvas.drawPath(chevronPath, chevronPaint);
  }
}
