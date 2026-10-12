import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum FieldObjectType {
  teleporter,
  enhancementZone,
  goldenZone,
  chestPaid,
  chestGolden,
  jarSmall,
  jarLarge,
  jarHp,
  shop,
  duplicator,
  converter,
  magnetStatue,
  curseTotem,
  trialTotem,
}

class FieldObjectComponent extends PositionComponent {
  final FieldObjectType type;
  bool isActivated = false;
  bool isDiscovered = false;
  double chargeTimer = 0.0;
  final double chargeDuration = 2.0;
  double _pulse = 0.0;

  FieldObjectComponent({
    required this.type,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(36, 36),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 3;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final center = Offset(size.x / 2, size.y / 2);

    switch (type) {
      case FieldObjectType.teleporter:
        _renderTeleporter(canvas, center);
        break;
      case FieldObjectType.enhancementZone:
      case FieldObjectType.goldenZone:
        _renderZone(canvas, center);
        break;
      case FieldObjectType.chestPaid:
      case FieldObjectType.chestGolden:
        _renderChest(canvas, center);
        break;
      case FieldObjectType.jarSmall:
      case FieldObjectType.jarLarge:
      case FieldObjectType.jarHp:
        _renderJar(canvas, center);
        break;
      case FieldObjectType.shop:
        _renderShop(canvas, center);
        break;
      case FieldObjectType.duplicator:
      case FieldObjectType.converter:
        _renderDevice(canvas, center);
        break;
      case FieldObjectType.magnetStatue:
        _renderMagnetStatue(canvas, center);
        break;
      case FieldObjectType.curseTotem:
      case FieldObjectType.trialTotem:
        _renderTotem(canvas, center);
        break;
    }
  }

  void _renderTeleporter(Canvas canvas, Offset center) {
    final ringPaint = Paint()
      ..color = isActivated
          ? const Color(0xFF00E5FF)
          : const Color(0xFF7C4DFF).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, 22.0 + sin(_pulse) * 2.0, ringPaint);

    final corePaint = Paint()
      ..color = isActivated ? const Color(0xFF18FFFF) : const Color(0xFFB388FF);
    canvas.drawCircle(center, 12.0, corePaint);

    // Glowing runes/cross
    final runePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(
        Offset(center.dx - 8, center.dy), Offset(center.dx + 8, center.dy), runePaint);
    canvas.drawLine(
        Offset(center.dx, center.dy - 8), Offset(center.dx, center.dy + 8), runePaint);
  }

  void _renderZone(Canvas canvas, Offset center) {
    final isGolden = type == FieldObjectType.goldenZone;
    final baseColor = isGolden ? const Color(0xFFFFD700) : const Color(0xFF00E5FF);
    final fillPaint = Paint()
      ..color = baseColor.withValues(alpha: isActivated ? 0.1 : 0.25)
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = baseColor.withValues(alpha: isActivated ? 0.2 : 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final radius = 28.0;
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, ringPaint);

    // Charge indicator
    if (chargeTimer > 0 && !isActivated) {
      final sweepAngle = (chargeTimer / chargeDuration) * 2 * pi;
      final chargePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        chargePaint,
      );
    }
  }

  void _renderChest(Canvas canvas, Offset center) {
    final isGolden = type == FieldObjectType.chestGolden;
    final bodyColor = isGolden ? const Color(0xFFFFC107) : const Color(0xFF795548);
    final trimColor = isGolden ? const Color(0xFFFFEB3B) : const Color(0xFFFFD54F);

    if (isActivated) {
      // Opened chest
      final paint = Paint()..color = bodyColor.withValues(alpha: 0.5);
      canvas.drawRect(Rect.fromCenter(center: center, width: 22, height: 16), paint);
      return;
    }

    final chestRect = Rect.fromCenter(center: center, width: 24, height: 18);
    canvas.drawRRect(
      RRect.fromRectAndRadius(chestRect, const Radius.circular(3)),
      Paint()..color = bodyColor,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 24, height: 4),
      Paint()..color = trimColor,
    );
    // Lock
    canvas.drawCircle(center, 2.5, Paint()..color = Colors.black);
  }

  void _renderJar(Canvas canvas, Offset center) {
    if (isActivated) return; // Destroyed
    final isHp = type == FieldObjectType.jarHp;
    final isLarge = type == FieldObjectType.jarLarge;
    final jarColor = isHp
        ? const Color(0xFFEF5350)
        : (isLarge ? const Color(0xFF8D6E63) : const Color(0xFFBCAAA4));

    final radius = isLarge ? 12.0 : 9.0;
    canvas.drawCircle(center, radius, Paint()..color = jarColor);
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.8),
      radius * 0.5,
      Paint()..color = jarColor.withValues(alpha: 0.8),
    );
  }

  void _renderShop(Canvas canvas, Offset center) {
    // Tent / stall shape
    final roofPaint = Paint()..color = const Color(0xFFE91E63);
    final basePaint = Paint()..color = const Color(0xFF8D6E63);

    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy + 4), width: 26, height: 16),
      basePaint,
    );
    final roofPath = Path()
      ..moveTo(center.dx - 16, center.dy - 2)
      ..lineTo(center.dx, center.dy - 16)
      ..lineTo(center.dx + 16, center.dy - 2)
      ..close();
    canvas.drawPath(roofPath, roofPaint);
  }

  void _renderDevice(Canvas canvas, Offset center) {
    final isDupe = type == FieldObjectType.duplicator;
    final color = isDupe ? const Color(0xFF00E676) : const Color(0xFF2979FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 22, height: 22),
          const Radius.circular(4)),
      Paint()..color = color,
    );
    final inner = Paint()..color = Colors.white;
    canvas.drawCircle(center, 5.0, inner);
  }

  void _renderMagnetStatue(Canvas canvas, Offset center) {
    final paint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawCircle(center, 12.0, paint);
    final uPath = Path()
      ..moveTo(center.dx - 6, center.dy - 6)
      ..lineTo(center.dx - 6, center.dy + 4)
      ..arcToPoint(Offset(center.dx + 6, center.dy + 4),
          radius: const Radius.circular(6))
      ..lineTo(center.dx + 6, center.dy - 6);
    canvas.drawPath(
      uPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
  }

  void _renderTotem(Canvas canvas, Offset center) {
    final isCurse = type == FieldObjectType.curseTotem;
    final color = isCurse ? const Color(0xFFB71C1C) : const Color(0xFFFF6D00);
    final rect = Rect.fromCenter(center: center, width: 14, height: 28);
    canvas.drawRect(rect, Paint()..color = color);
    // Eye on totem
    canvas.drawCircle(
      Offset(center.dx, center.dy - 4),
      3.0,
      Paint()..color = Colors.yellow,
    );
  }
}
