// lib/widgets/drawing_painter.dart
import 'package:flutter/material.dart';
import '../models/shape.dart';

class DrawingPainter extends CustomPainter {
  final List<Shape> shapes;
  final Shape? previewShape;
  
  DrawingPainter(this.shapes, this.previewShape);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Vẽ nền trắng
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    
    // Vẽ tất cả shapes
    for (var shape in shapes) {
      shape.draw(canvas, size);
    }
    
    // Vẽ preview (nếu có)
    if (previewShape != null) {
      previewShape!.draw(canvas, size);
    }
  }
  
  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}