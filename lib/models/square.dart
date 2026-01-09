import 'package:flutter/material.dart';
import 'shape.dart';

class Square extends Shape {
  Offset topLeft;
  double side;

  Square({
    required this.topLeft,
    required this.side,
    required Color color,
    required double strokeWidth,
    Color? fillColor,
  }) : super(
    color: color,
    strokeWidth: strokeWidth,
    isFilled: fillColor != null,
    fillColor: fillColor,
  );

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFilled ? fillColor! : color
      ..strokeWidth = strokeWidth
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(topLeft.dx, topLeft.dy, side, side),
      paint,
    );
  }

  @override
  bool contains(Offset point) {
    final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, side, side);
    return rect.contains(point);
  }

  @override
  bool get canFill => true;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'square',
    'topLeftX': topLeft.dx,
    'topLeftY': topLeft.dy,
    'side': side,
    'color': color.value,
    'strokeWidth': strokeWidth,
    'isFilled': isFilled,
    'fillColor': fillColor?.value,
  };
}
