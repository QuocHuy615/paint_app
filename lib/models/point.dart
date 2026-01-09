import 'package:flutter/material.dart';
import 'shape.dart';

class Point extends Shape {
  Offset position;
  double size; // Kích thước điểm

  Point({
    required this.position,
    required this.size,
    required Color color,
    required double strokeWidth,
  }) : super(color: color, strokeWidth: strokeWidth);

  @override
  void draw(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(position, size, paint);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'point',
    'x': position.dx,
    'y': position.dy,
    'size': size,
    'color': color.value,
    'strokeWidth': strokeWidth,
  };
}
