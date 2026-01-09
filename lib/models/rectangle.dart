import 'package:flutter/material.dart';
import 'shape.dart';

class Rectangle extends Shape {
  Offset topLeft;
  Offset bottomRight;

  Rectangle({
    required this.topLeft,
    required this.bottomRight,
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
      Rect.fromPoints(topLeft, bottomRight),
      paint,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'rectangle',
    'topLeftX': topLeft.dx,
    'topLeftY': topLeft.dy,
    'bottomRightX': bottomRight.dx,
    'bottomRightY': bottomRight.dy,
    'color': color.value,
    'strokeWidth': strokeWidth,
    'isFilled': isFilled,
    'fillColor': fillColor?.value,
  };
}
