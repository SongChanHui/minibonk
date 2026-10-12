import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FloatingDamageText extends PositionComponent {
  final String text;
  final bool isCrit;
  final int critStage;
  double _lifeTime = 0.8;
  final double _speed = 45.0;

  FloatingDamageText({
    required this.text,
    required Vector2 position,
    this.isCrit = false,
    this.critStage = 1,
  }) : super(position: position);

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= _speed * dt;
    _lifeTime -= dt;
    if (_lifeTime <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final opacity = (_lifeTime / 0.8).clamp(0.0, 1.0);
    Color textColor = Colors.white;
    double fontSize = 13.0;

    if (isCrit) {
      if (critStage >= 3) {
        textColor = const Color(0xFFFF3D00); // Super crit orange-red
        fontSize = 17.0;
      } else {
        textColor = const Color(0xFFFFD600); // Yellow-gold crit
        fontSize = 15.0;
      }
    }

    final displayText = isCrit ? '$text Crit!' : text;

    final textSpan = TextSpan(
      text: displayText,
      style: TextStyle(
        color: textColor.withValues(alpha: opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: opacity),
            offset: const Offset(1.5, 1.5),
            blurRadius: 3.0,
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
