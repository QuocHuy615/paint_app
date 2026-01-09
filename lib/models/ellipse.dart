import 'package:flutter/material.dart';
import 'shape.dart';

class Ellipse extends Shape {
  Offset center;
  double radiusX;
  double radiusY;

  Ellipse({
    required this.center,
    required this.radiusX,
    required this.radiusY,
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

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: radiusX * 2,
        height: radiusY * 2,
      ),
      paint,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'ellipse',
    'centerX': center.dx,
    'centerY': center.dy,
    'radiusX': radiusX,
    'radiusY': radiusY,
    'color': color.value,
    'strokeWidth': strokeWidth,
    'isFilled': isFilled,
    'fillColor': fillColor?.value,
  };
}
