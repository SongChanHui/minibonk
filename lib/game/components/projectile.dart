import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum ProjectileKind {
  fireball,
  arrow,
  dagger,
  orbitShield,
  orbitRock,
  lightningBolt,
  frostTrap,
  boomerang,
}

class Projectile extends PositionComponent {
  final ProjectileKind kind;
  final double damage;
  final bool isCrit;
  final int critStage;
  final double critMult;
  final double speed;
  final double knockback;
  final double areaSize;
  final double duration;
  Vector2 direction;
  int pierceCount;
  final bool isExplosion;

  double _lifeTimer = 0.0;
  final Set<int> hitMonsterIds = {};

  // For Boomerang
  bool isReturning = false;
  Vector2? origin;

  // For Orbiting
  double orbitAngle = 0.0;
  final double orbitDistance;

  Projectile({
    required this.kind,
    required this.damage,
    required this.isCrit,
    required this.critStage,
    required this.critMult,
    required this.speed,
    required this.knockback,
    required this.areaSize,
    required this.duration,
    required Vector2 position,
    Vector2? direction,
    this.pierceCount = 1,
    this.isExplosion = false,
    this.orbitDistance = 50.0,
  })  : direction = direction ?? Vector2(1, 0),
        super(position: position, size: Vector2(16, 16), anchor: Anchor.center) {
    size = Vector2(16 * areaSize, 16 * areaSize);
    origin = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTimer += dt;
    if (_lifeTimer >= duration) {
      removeFromParent();
      return;
    }

    switch (kind) {
      case ProjectileKind.fireball:
      case ProjectileKind.arrow:
      case ProjectileKind.dagger:
        position += direction * speed * dt;
        break;
      case ProjectileKind.boomerang:
        if (_lifeTimer > duration / 2) {
          isReturning = true;
        }
        if (!isReturning) {
          position += direction * speed * dt;
        }
        break;
      case ProjectileKind.orbitShield:
      case ProjectileKind.orbitRock:
      case ProjectileKind.frostTrap:
      case ProjectileKind.lightningBolt:
        // Handled by parent or stationary
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);

    switch (kind) {
      case ProjectileKind.fireball:
        // Dark Obsidian Plasma Core wrapped in Blinding Neon Orange/Crimson
        final neonFlameColor =
            isCrit ? const Color(0xFFFFD700) : const Color(0xFFFF3D00);

        // Outer neon aura bloom
        final flameGlow = Paint()
          ..color = neonFlameColor.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(center, size.x * 0.65, flameGlow);

        // Dark obsidian core
        final darkCore = Paint()..color = const Color(0xFF140806);
        canvas.drawCircle(center, size.x * 0.45, darkCore);

        // Neon flame corona ring
        final coronaPaint = Paint()
          ..color = neonFlameColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6;
        canvas.drawCircle(center, size.x * 0.45, coronaPaint);

        // White-hot plasma spark in center
        final sparkPaint = Paint()
          ..color = isCrit ? Colors.white : const Color(0xFFFFEB3B);
        canvas.drawCircle(center, size.x * 0.2, sparkPaint);
        break;

      case ProjectileKind.arrow:
        // Dark kinetic dart with radiant Neon Cyan photon blades
        final neonArrowColor =
            isCrit ? const Color(0xFFFFD700) : const Color(0xFF00E5FF);
        final angle = atan2(direction.y, direction.x);

        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(angle);

        // Neon photon blur halo
        final arrowGlow = Paint()
          ..color = neonArrowColor.withValues(alpha: 0.7)
          ..strokeWidth = 5.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawLine(const Offset(-12, 0), const Offset(12, 0), arrowGlow);

        // Dark shaft core
        final darkShaft = Paint()
          ..color = const Color(0xFF060910)
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.square;
        canvas.drawLine(const Offset(-12, 0), const Offset(10, 0), darkShaft);

        // Sharp neon photon blade edges
        final bladePaint = Paint()
          ..color = neonArrowColor
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(-12, 0), const Offset(12, 0), bladePaint);
        canvas.drawLine(const Offset(4, -5), const Offset(12, 0), bladePaint);
        canvas.drawLine(const Offset(4, 5), const Offset(12, 0), bladePaint);

        // White-hot tip
        canvas.drawCircle(const Offset(12, 0), 1.6, Paint()..color = Colors.white);

        canvas.restore();
        break;

      case ProjectileKind.dagger:
        // Dark Shadow Kunai etched with Neon Violet / Magenta Void Energy
        final neonDaggerColor =
            isCrit ? const Color(0xFFFFD700) : const Color(0xFFD500F9);
        final angle = atan2(direction.y, direction.x);

        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(angle);

        // Neon void aura bloom
        final daggerGlow = Paint()
          ..color = neonDaggerColor.withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        final glowPath = Path()
          ..moveTo(-10, 0)
          ..lineTo(2, -4)
          ..lineTo(10, 0)
          ..lineTo(2, 4)
          ..close();
        canvas.drawPath(glowPath, daggerGlow);

        // Dark obsidian blade body
        final bladeBody = Paint()..color = const Color(0xFF0D0614);
        canvas.drawPath(glowPath, bladeBody);

        // Neon runic edge outline
        final edgePaint = Paint()
          ..color = neonDaggerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawPath(glowPath, edgePaint);

        // Central neon vein
        canvas.drawLine(
          const Offset(-8, 0),
          const Offset(8, 0),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 1.0,
        );

        canvas.restore();
        break;

      case ProjectileKind.orbitShield:
        // Dark Titanium Matrix Barrier with Radiant Neon Electric Blue Forcefield
        final neonShieldColor = const Color(0xFF00E5FF);

        // Neon forcefield bloom
        final shieldGlow = Paint()
          ..color = neonShieldColor.withValues(alpha: 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        final shieldRect = Rect.fromCenter(center: center, width: 14, height: 22);
        canvas.drawRRect(
          RRect.fromRectAndRadius(shieldRect, const Radius.circular(3)),
          shieldGlow,
        );

        // Dark barrier plate
        final darkPlate = Paint()..color = const Color(0xFF0A0F1D);
        canvas.drawRRect(
          RRect.fromRectAndRadius(shieldRect, const Radius.circular(3)),
          darkPlate,
        );

        // Neon border rim
        final shieldRim = Paint()
          ..color = neonShieldColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawRRect(
          RRect.fromRectAndRadius(shieldRect, const Radius.circular(3)),
          shieldRim,
        );

        // Central neon power core
        canvas.drawCircle(center, 2.5, Paint()..color = Colors.white);
        break;

      case ProjectileKind.orbitRock:
        // Dark Void Asteroid with Radiant Neon Emerald Fissures
        final neonRockColor = const Color(0xFF00E676);

        // Neon aura
        final rockGlow = Paint()
          ..color = neonRockColor.withValues(alpha: 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(center, 9.0, rockGlow);

        // Dark cosmic meteorite body
        final rockBody = Paint()..color = const Color(0xFF0B1410);
        canvas.drawCircle(center, 8.5, rockBody);

        // Neon jagged crust rim
        final rockRim = Paint()
          ..color = neonRockColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawCircle(center, 8.0, rockRim);

        // Glowing internal crystal veins
        final fissurePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.0;
        canvas.drawLine(
          Offset(center.dx - 4, center.dy - 3),
          Offset(center.dx + 4, center.dy + 3),
          fissurePaint,
        );
        break;

      case ProjectileKind.lightningBolt:
        // Dark Ion Channel with Ultra-Bright Neon Violet/Cyan Electric Discharge
        final neonVoltColor = const Color(0xFF00E5FF);

        // Wide electric bloom
        final boltGlow = Paint()
          ..color = const Color(0xFF7C4DFF).withValues(alpha: 0.7)
          ..strokeWidth = 6.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawLine(
          Offset(center.dx, -60),
          Offset(center.dx, center.dy),
          boltGlow,
        );

        // Neon electric channel
        final boltChannel = Paint()
          ..color = neonVoltColor
          ..strokeWidth = 3.0;
        canvas.drawLine(
          Offset(center.dx, -60),
          Offset(center.dx, center.dy),
          boltChannel,
        );

        // Blinding white core discharge
        canvas.drawLine(
          Offset(center.dx, -60),
          Offset(center.dx, center.dy),
          Paint()
            ..color = Colors.white
            ..strokeWidth = 1.2,
        );

        // Ground impact neon blast ring
        final impactGlow = Paint()
          ..color = neonVoltColor.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(center, 14.0, impactGlow);
        canvas.drawCircle(
          center,
          10.0,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        break;

      case ProjectileKind.frostTrap:
        // Dark Cryo-Matrix with Radiant Neon Cyan Runic Ring
        final neonFrostColor = const Color(0xFF00E5FF);

        // Dark frosty field
        final darkTrap = Paint()..color = const Color(0x66060E18);
        canvas.drawCircle(center, size.x / 2, darkTrap);

        // Neon frost bloom ring
        final frostGlow = Paint()
          ..color = neonFrostColor.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawCircle(center, size.x / 2, frostGlow);

        // Sharp neon geometric rune perimeter
        final frostRim = Paint()
          ..color = neonFrostColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;
        canvas.drawCircle(center, size.x / 2, frostRim);

        // Inner glowing cryo-cross
        final innerCross = Paint()
          ..color = Colors.white.withValues(alpha: 0.8)
          ..strokeWidth = 1.2;
        canvas.drawLine(
          Offset(center.dx - 6, center.dy),
          Offset(center.dx + 6, center.dy),
          innerCross,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - 6),
          Offset(center.dx, center.dy + 6),
          innerCross,
        );
        break;

      case ProjectileKind.boomerang:
        // Dark Stealth Razor Glaive with Radiant Neon Toxic Lime Plasma Edge
        final neonLimeColor = const Color(0xFF76FF03);

        // Neon spinning bloom
        final bGlow = Paint()
          ..color = neonLimeColor.withValues(alpha: 0.6)
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 8.0),
          _lifeTimer * 12,
          pi * 1.1,
          false,
          bGlow,
        );

        // Dark blade spine
        final darkBlade = Paint()
          ..color = const Color(0xFF0A1406)
          ..strokeWidth = 3.5
          ..style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 8.0),
          _lifeTimer * 12,
          pi * 1.1,
          false,
          darkBlade,
        );

        // Neon razor edge
        final razorEdge = Paint()
          ..color = neonLimeColor
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: 8.0),
          _lifeTimer * 12,
          pi * 1.1,
          false,
          razorEdge,
        );
        break;
    }
  }
}
