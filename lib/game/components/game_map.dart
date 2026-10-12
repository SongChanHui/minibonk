import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameMapComponent extends Component {
  static const double mapSize = 2400.0;
  static const double halfSize = mapSize / 2;

  final Paint _bgPaint = Paint()..color = const Color(0xFF141A29);
  final Paint _gridPaint = Paint()
    ..color = const Color(0xFF1F293D)
    ..strokeWidth = 1.0;
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFF00E5FF).withValues(alpha: 0.4)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.0;
  final Paint _hazardPaint = Paint()
    ..color = const Color(0xFF1B3A4B).withValues(alpha: 0.5);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Map background
    final mapRect = Rect.fromLTWH(-halfSize, -halfSize, mapSize, mapSize);
    canvas.drawRect(mapRect, _bgPaint);

    // Subtle Mud / Water slow zones (e.g., 4 ponds around the map)
    canvas.drawCircle(const Offset(-450, -350), 120.0, _hazardPaint);
    canvas.drawCircle(const Offset(500, 400), 140.0, _hazardPaint);
    canvas.drawCircle(const Offset(-300, 600), 100.0, _hazardPaint);
    canvas.drawCircle(const Offset(600, -500), 110.0, _hazardPaint);

    // Grid pattern
    const gridSize = 120.0;
    for (double x = -halfSize; x <= halfSize; x += gridSize) {
      canvas.drawLine(Offset(x, -halfSize), Offset(x, halfSize), _gridPaint);
    }
    for (double y = -halfSize; y <= halfSize; y += gridSize) {
      canvas.drawLine(Offset(-halfSize, y), Offset(halfSize, y), _gridPaint);
    }

    // Outer Neon Border
    canvas.drawRect(mapRect, _borderPaint);
  }
}
