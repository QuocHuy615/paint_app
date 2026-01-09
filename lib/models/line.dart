// lib/models/line.dart
import 'package:flutter/material.dart';
import 'shape.dart';

class Line extends Shape {
  Offset startPoint;
  Offset endPoint;
  
  Line({
    required this.startPoint,
    required this.endPoint,
    required Color color,
    required double strokeWidth,
  }) : super(color: color, strokeWidth: strokeWidth);
  
  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool contains(Offset point) {
    return false;
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': 'line',
    'startX': startPoint.dx,
    'startY': startPoint.dy,
    'endX': endPoint.dx,
    'endY': endPoint.dy,
    'color': color.value,
    'strokeWidth': strokeWidth,
  };
}
