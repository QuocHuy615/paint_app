import 'package:flutter/material.dart';
import 'shape.dart';

class Circle extends Shape {
  Offset center;
  double radius;

  Circle({
    required this.center,
    required this.radius,
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

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool contains(Offset point) {
    final dx = point.dx - center.dx;
    final dy = point.dy - center.dy;
    return (dx * dx + dy * dy) <= radius * radius;
  }

  @override
  bool get canFill => true;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'circle',
    'centerX': center.dx,
    'centerY': center.dy,
    'radius': radius,
    'color': color.value,
    'strokeWidth': strokeWidth,
    'isFilled': isFilled,
    'fillColor': fillColor?.value,
  };
}
