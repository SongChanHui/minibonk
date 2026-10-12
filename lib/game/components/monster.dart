import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum MonsterRank {
  normal,
  elite,
  swarm,
  midboss,
  stageBoss,
}

class MonsterComponent extends PositionComponent {
  static int _idCounter = 0;
  final int monsterId;

  final MonsterRank rank;
  final int stage;
  double maxHp;
  double currentHp;
  double speed;
  double touchDamage;
  final Color neonColor;
  final Color darkBodyColor;

  double _flashTimer = 0.0;
  double _animationPhase = 0.0;

  MonsterComponent({
    required this.rank,
    required this.stage,
    required Vector2 position,
    double hpMultiplier = 1.0,
    double speedMultiplier = 1.0,
    double damageMultiplier = 1.0,
  })  : monsterId = ++_idCounter,
        maxHp = _calcHp(rank, stage) * hpMultiplier,
        currentHp = _calcHp(rank, stage) * hpMultiplier,
        speed = _calcSpeed(rank) * speedMultiplier,
        touchDamage = _calcDamage(rank, stage) * damageMultiplier,
        neonColor = _calcNeonColor(rank),
        darkBodyColor = _calcDarkBodyColor(rank),
        super(
          position: position,
          size: _calcSize(rank),
          anchor: Anchor.center,
        ) {
    _animationPhase = Random().nextDouble() * pi * 2;
  }

  static double _calcHp(MonsterRank rank, int stage) {
    final stageScale = 1.0 + (stage - 1) * 0.8;
    switch (rank) {
      case MonsterRank.normal:
        return 20.0 * stageScale;
      case MonsterRank.swarm:
        return 12.0 * stageScale;
      case MonsterRank.elite:
        return 140.0 * stageScale;
      case MonsterRank.midboss:
        return 500.0 * stageScale;
      case MonsterRank.stageBoss:
        return 1500.0 * stageScale;
    }
  }

  static double _calcSpeed(MonsterRank rank) {
    switch (rank) {
      case MonsterRank.normal:
        return 45.0;
      case MonsterRank.swarm:
        return 75.0;
      case MonsterRank.elite:
        return 40.0;
      case MonsterRank.midboss:
        return 35.0;
      case MonsterRank.stageBoss:
        return 38.0;
    }
  }

  static double _calcDamage(MonsterRank rank, int stage) {
    final stageScale = 1.0 + (stage - 1) * 0.5;
    switch (rank) {
      case MonsterRank.normal:
        return 8.0 * stageScale;
      case MonsterRank.swarm:
        return 6.0 * stageScale;
      case MonsterRank.elite:
        return 18.0 * stageScale;
      case MonsterRank.midboss:
        return 28.0 * stageScale;
      case MonsterRank.stageBoss:
        return 40.0 * stageScale;
    }
  }

  static Vector2 _calcSize(MonsterRank rank) {
    switch (rank) {
      case MonsterRank.swarm:
        return Vector2(16, 16);
      case MonsterRank.normal:
        return Vector2(22, 22);
      case MonsterRank.elite:
        return Vector2(34, 34);
      case MonsterRank.midboss:
        return Vector2(46, 46);
      case MonsterRank.stageBoss:
        return Vector2(60, 60);
    }
  }

  static Color _calcNeonColor(MonsterRank rank) {
    switch (rank) {
      case MonsterRank.swarm:
        return const Color(0xFFFFD600); // Electric Neon Yellow
      case MonsterRank.normal:
        return const Color(0xFFFF1744); // Neon Crimson
      case MonsterRank.elite:
        return const Color(0xFFD500F9); // Neon Purple / Violet
      case MonsterRank.midboss:
        return const Color(0xFFFF007F); // Neon Hot Pink / Rose
      case MonsterRank.stageBoss:
        return const Color(0xFFFF0055); // Dread Neon Scarlet
    }
  }

  static Color _calcDarkBodyColor(MonsterRank rank) {
    switch (rank) {
      case MonsterRank.swarm:
        return const Color(0xFF141208); // Dark Amber Charcoal
      case MonsterRank.normal:
        return const Color(0xFF160A0D); // Dark Crimson Obsidian
      case MonsterRank.elite:
        return const Color(0xFF100918); // Dark Void Violet
      case MonsterRank.midboss:
        return const Color(0xFF180A14); // Dark Magma Rose
      case MonsterRank.stageBoss:
        return const Color(0xFF140509); // Deep Abyssal Black
    }
  }

  bool get isDead => currentHp <= 0;

  void takeDamage(double amount, {Vector2? knockbackDir, double knockbackForce = 0.0}) {
    currentHp -= amount;
    _flashTimer = 0.12;
    if (knockbackDir != null && knockbackForce > 0) {
      position += knockbackDir * (knockbackForce * 4.0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animationPhase += dt * 5;
    if (_flashTimer > 0) {
      _flashTimer -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);
    final isFlashing = _flashTimer > 0;
    final pulse = 0.5 + 0.5 * sin(_animationPhase);

    if (isFlashing) {
      // Hit flash: bright white-hot burst
      canvas.drawCircle(
        center,
        size.x / 2 + 2,
        Paint()
          ..color = Colors.white
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(center, size.x / 2, Paint()..color = Colors.white);
      return;
    }

    // 1. Neon Aura Bloom (Multi-layered emissive blur)
    final auraRadius = (size.x / 2) + 3.0 + (rank == MonsterRank.stageBoss ? 4.0 : 0.0);
    final auraPaint = Paint()
      ..color = neonColor.withValues(alpha: 0.25 + pulse * 0.2)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, rank == MonsterRank.stageBoss ? 12 : 8);
    canvas.drawCircle(center, auraRadius, auraPaint);

    // 2. Boss & Elite Extra Neon Outer Shock-Rings / Spikes
    if (rank == MonsterRank.elite || rank == MonsterRank.midboss || rank == MonsterRank.stageBoss) {
      final ringPaint = Paint()
        ..color = neonColor.withValues(alpha: 0.7 + pulse * 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (rank == MonsterRank.stageBoss) ? 2.5 : 1.6;
      canvas.drawCircle(center, (size.x / 2) + 3.0, ringPaint);

      // Rotating neon rune nodes
      final nodeCount = (rank == MonsterRank.stageBoss) ? 6 : 4;
      for (int i = 0; i < nodeCount; i++) {
        final angle = _animationPhase * 0.8 + (i * 2 * pi / nodeCount);
        final dist = (size.x / 2) + 4.5;
        final nodePos = Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist);
        canvas.drawCircle(nodePos, 2.0, Paint()..color = neonColor);
      }
    }

    // 3. Dark Shadow Shell / Abyssal Body (Dark obsidian texture)
    final bodyPaint = Paint()..color = darkBodyColor;
    canvas.drawCircle(center, size.x / 2, bodyPaint);

    // 4. Sharp Neon Perimeter Rim (Crisp high-voltage edge)
    final rimPaint = Paint()
      ..color = neonColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (rank == MonsterRank.stageBoss) ? 2.0 : 1.2;
    canvas.drawCircle(center, (size.x / 2) - 0.5, rimPaint);

    // 5. Pulsing Neon Core Fissure / Energy Veins
    final fissurePaint = Paint()
      ..color = neonColor.withValues(alpha: 0.4 + pulse * 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(center.dx - size.x * 0.25, center.dy + size.y * 0.15),
      Offset(center.dx + size.x * 0.25, center.dy - size.y * 0.1),
      fissurePaint,
    );

    // 6. Sinister Neon Eyes (Angular cyber-glowing slits with white center)
    final eyeOffset = size.x * 0.22;
    final eyeY = center.dy - size.y * 0.08;
    final eyeSize = size.x * 0.1;

    // Glowing neon eye aura
    final eyeGlowPaint = Paint()
      ..color = neonColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(Offset(center.dx - eyeOffset, eyeY), eyeSize * 1.4, eyeGlowPaint);
    canvas.drawCircle(Offset(center.dx + eyeOffset, eyeY), eyeSize * 1.4, eyeGlowPaint);

    // Sharp neon eye shape (Aggressive angled slit)
    final leftEyePath = Path()
      ..moveTo(center.dx - eyeOffset - eyeSize, eyeY)
      ..lineTo(center.dx - eyeOffset, eyeY - eyeSize * 0.8)
      ..lineTo(center.dx - eyeOffset + eyeSize * 0.8, eyeY)
      ..lineTo(center.dx - eyeOffset, eyeY + eyeSize * 0.6)
      ..close();
    final rightEyePath = Path()
      ..moveTo(center.dx + eyeOffset + eyeSize, eyeY)
      ..lineTo(center.dx + eyeOffset, eyeY - eyeSize * 0.8)
      ..lineTo(center.dx + eyeOffset - eyeSize * 0.8, eyeY)
      ..lineTo(center.dx + eyeOffset, eyeY + eyeSize * 0.6)
      ..close();

    final eyeCorePaint = Paint()..color = Colors.white;
    canvas.drawPath(leftEyePath, eyeCorePaint);
    canvas.drawPath(rightEyePath, eyeCorePaint);

    // 7. HP Bar for Elite & Bosses (Sharp, luxury dark theme)
    if (rank != MonsterRank.swarm && rank != MonsterRank.normal) {
      final barWidth = size.x * 1.1;
      const barHeight = 3.5;
      final barY = -9.0;
      final barX = (size.x - barWidth) / 2;

      // Dark background with sharp border
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        Paint()..color = const Color(0xFF0A0E18),
      );
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barWidth, barHeight),
        Paint()
          ..color = const Color(0xFF263238)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Health fill with bright neon
      final fillRatio = (currentHp / maxHp).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTWH(barX, barY, barWidth * fillRatio, barHeight),
        Paint()..color = neonColor,
      );
    }
  }
}
