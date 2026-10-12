import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum DropType {
  expSmall,
  expMedium,
  expLarge,
  goldCoin,
  pinkCoin,
  healthPotion,
  droppedChest,
}

class DropItem extends PositionComponent {
  final DropType type;
  final int value;
  bool isBeingAttracted = false;
  double _bounceTimer = 0.0;

  DropItem({
    required this.type,
    required this.value,
    required Vector2 position,
  }) : super(position: position, size: Vector2(16, 16), anchor: Anchor.center) {
    _bounceTimer = Random().nextDouble() * 2 * pi;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _bounceTimer += dt * 4;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bounce = sin(_bounceTimer) * 2.0;
    final center = Offset(size.x / 2, size.y / 2 + bounce);

    switch (type) {
      case DropType.expSmall:
        // Green diamond gem
        final paint = Paint()..color = const Color(0xFF00E676);
        _drawGem(canvas, center, 6.0, paint);
        break;
      case DropType.expMedium:
        // Blue gem
        final paint = Paint()..color = const Color(0xFF00B0FF);
        _drawGem(canvas, center, 8.0, paint);
        break;
      case DropType.expLarge:
        // Purple/red gem
        final paint = Paint()..color = const Color(0xFFD500F9);
        _drawGem(canvas, center, 10.0, paint);
        break;
      case DropType.goldCoin:
        // Gold circle with inner border
        final paint = Paint()..color = const Color(0xFFFFD700);
        canvas.drawCircle(center, 6.0, paint);
        final innerPaint = Paint()
          ..color = const Color(0xFFFFA000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, 4.0, innerPaint);
        break;
      case DropType.pinkCoin:
        // Rare pink coin
        final paint = Paint()..color = const Color(0xFFFF4081);
        canvas.drawCircle(center, 7.5, paint);
        final innerPaint = Paint()
          ..color = const Color(0xFFF50057)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8;
        canvas.drawCircle(center, 5.0, innerPaint);
        break;
      case DropType.healthPotion:
        // Red cross potion
        final paint = Paint()..color = const Color(0xFFFF1744);
        canvas.drawCircle(center, 8.0, paint);
        final crossPaint = Paint()..color = Colors.white;
        canvas.drawRect(
            Rect.fromCenter(center: center, width: 3, height: 10), crossPaint);
        canvas.drawRect(
            Rect.fromCenter(center: center, width: 10, height: 3), crossPaint);
        break;
      case DropType.droppedChest:
        // Mini chest box
        final chestPaint = Paint()..color = const Color(0xFF8D6E63);
        final goldTrim = Paint()..color = const Color(0xFFFFD54F);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: center, width: 16, height: 12),
              const Radius.circular(2)),
          chestPaint,
        );
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 16, height: 3),
          goldTrim,
        );
        break;
    }
  }

  void _drawGem(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius * 0.7, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius * 0.7, center.dy)
      ..close();
    canvas.drawPath(path, paint);

    // Inner highlight
    final hlPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final hlPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.6)
      ..lineTo(center.dx + radius * 0.25, center.dy - radius * 0.1)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(hlPath, hlPaint);
  }
}
