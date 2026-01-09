import 'package:flutter/material.dart';
import 'circle.dart';
import 'ellipse.dart';
import 'line.dart';
import 'point.dart';
import 'rectangle.dart';
import 'shape.dart';
import 'square.dart';

Shape? shapeFromJson(Map<String, dynamic> json) {
  final type = json['type'];
  if (type is! String) {
    return null;
  }

  switch (type) {
    case 'point':
      return Point(
        position: Offset(
          _toDouble(json['x']),
          _toDouble(json['y']),
        ),
        size: _toDouble(json['size'], fallback: 4),
        color: _toColor(json['color']),
        strokeWidth: _toDouble(json['strokeWidth'], fallback: 2),
      );
    case 'line':
      return Line(
        startPoint: Offset(
          _toDouble(json['startX']),
          _toDouble(json['startY']),
        ),
        endPoint: Offset(
          _toDouble(json['endX']),
          _toDouble(json['endY']),
        ),
        color: _toColor(json['color']),
        strokeWidth: _toDouble(json['strokeWidth'], fallback: 2),
      );
    case 'circle':
      return Circle(
        center: Offset(
          _toDouble(json['centerX']),
          _toDouble(json['centerY']),
        ),
        radius: _toDouble(json['radius']),
        color: _toColor(json['color']),
        strokeWidth: _toDouble(json['strokeWidth'], fallback: 2),
        fillColor: _toFillColor(json),
      );
    case 'rectangle':
      return Rectangle(
        topLeft: Offset(
          _toDouble(json['topLeftX']),
          _toDouble(json['topLeftY']),
        ),
        bottomRight: Offset(
          _toDouble(json['bottomRightX']),
          _toDouble(json['bottomRightY']),
        ),
        color: _toColor(json['color']),
        strokeWidth: _toDouble(json['strokeWidth'], fallback: 2),
        fillColor: _toFillColor(json),
      );
    case 'square':
      return Square(
        topLeft: Offset(
          _toDouble(json['topLeftX']),
          _toDouble(json['topLeftY']),
        ),
        side: _toDouble(json['side']),
        color: _toColor(json['color']),
        strokeWidth: _toDouble(json['strokeWidth'], fallback: 2),
        fillColor: _toFillColor(json),
      );
    case 'ellipse':
      return Ellipse(
        center: Offset(
          _toDouble(json['centerX']),
          _toDouble(json['centerY']),
        ),
        radiusX: _toDouble(json['radiusX']),
        radiusY: _toDouble(json['radiusY']),
        color: _toColor(json['color']),
        strokeWidth: _toDouble(json['strokeWidth'], fallback: 2),
        fillColor: _toFillColor(json),
      );
    default:
      return null;
  }
}

double _toDouble(dynamic value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }
  return fallback;
}

Color _toColor(dynamic value) {
  final parsed = _toInt(value);
  if (parsed == null) {
    return const Color(0xFF000000);
  }
  return Color(parsed);
}

Color? _toFillColor(Map<String, dynamic> json) {
  final isFilled = json['isFilled'] == true;
  if (!isFilled) {
    return null;
  }
  final parsed = _toInt(json['fillColor']);
  if (parsed == null) {
    return null;
  }
  return Color(parsed);
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}
