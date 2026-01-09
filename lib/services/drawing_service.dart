// lib/services/drawing_service.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/shape.dart';
import '../models/point.dart';
import '../models/line.dart';
import '../models/circle.dart';
import '../models/rectangle.dart';
import '../models/square.dart';
import '../models/ellipse.dart';

class DrawingService {
  Shape? _currentShape;
  
  // Bắt đầu vẽ
  void startShape(String shapeType, Offset position, Color color, double strokeWidth) {
    _currentShape = null;
    
    switch (shapeType) {
      case 'point':
        _currentShape = Point(
          position: position,
          size: 4,
          color: color,
          strokeWidth: strokeWidth,
        );
        break;
      case 'line':
        _currentShape = Line(
          startPoint: Offset(position.dx, position.dy),
          endPoint: Offset(position.dx, position.dy),
          color: color,
          strokeWidth: strokeWidth,
        );
        break;
      case 'circle':
        _currentShape = Circle(
          center: position,
          radius: 0,
          color: color,
          strokeWidth: strokeWidth,
          fillColor: null,
        );
        break;
      case 'rectangle':
        _currentShape = Rectangle(
          topLeft: position,
          bottomRight: position,
          color: color,
          strokeWidth: strokeWidth,
          fillColor: null,
        );
        break;
      case 'square':
        _currentShape = Square(
          topLeft: position,
          side: 0,
          color: color,
          strokeWidth: strokeWidth,
          fillColor: null,
        );
        break;
      case 'ellipse':
        _currentShape = Ellipse(
          center: position,
          radiusX: 0,
          radiusY: 0,
          color: color,
          strokeWidth: strokeWidth,
          fillColor: null,
        );
        break;
    }
  }
  
  // Cập nhật khi kéo
  Shape? updateShape(Offset position) {
    if (_currentShape == null) return null;

    if (_currentShape is Point) {
      // Point không cần update, chỉ cần finish
      return _currentShape;
    } else if (_currentShape is Line) {
      final line = _currentShape as Line;
      _currentShape = Line(
        startPoint: Offset(line.startPoint.dx, line.startPoint.dy),
        endPoint: position,
        color: line.color,
        strokeWidth: line.strokeWidth,
      );
    } else if (_currentShape is Circle) {
      final circle = _currentShape as Circle;
      final dx = position.dx - circle.center.dx;
      final dy = position.dy - circle.center.dy;
      final radius = sqrt(dx * dx + dy * dy);

      _currentShape = Circle(
        center: circle.center,
        radius: radius,
        color: circle.color,
        strokeWidth: circle.strokeWidth,
        fillColor: circle.fillColor,
      );
    } else if (_currentShape is Rectangle) {
      final rect = _currentShape as Rectangle;
      _currentShape = Rectangle(
        topLeft: rect.topLeft,
        bottomRight: position,
        color: rect.color,
        strokeWidth: rect.strokeWidth,
        fillColor: rect.fillColor,
      );
    } else if (_currentShape is Square) {
      final square = _currentShape as Square;
      final dx = (position.dx - square.topLeft.dx).abs();
      final dy = (position.dy - square.topLeft.dy).abs();
      final side = dx > dy ? dx : dy; // Lấy cạnh lớn nhất

      _currentShape = Square(
        topLeft: square.topLeft,
        side: side,
        color: square.color,
        strokeWidth: square.strokeWidth,
        fillColor: square.fillColor,
      );
    } else if (_currentShape is Ellipse) {
      final ellipse = _currentShape as Ellipse;
      final radiusX = (position.dx - ellipse.center.dx).abs();
      final radiusY = (position.dy - ellipse.center.dy).abs();

      _currentShape = Ellipse(
        center: ellipse.center,
        radiusX: radiusX,
        radiusY: radiusY,
        color: ellipse.color,
        strokeWidth: ellipse.strokeWidth,
        fillColor: ellipse.fillColor,
      );
    }
    
    return _currentShape;
  }
  
  // Kết thúc vẽ
  Shape? finishShape() {
    final shape = _currentShape;
    _currentShape = null;
    return shape;
  }
  
  void clear() {
    _currentShape = null;
  }
}
