// lib/models/shape.dart
import 'package:flutter/material.dart';

abstract class Shape {
  Color color;
  double strokeWidth;
  bool isFilled;
  Color? fillColor;
  
  Shape({
    required this.color,
    required this.strokeWidth,
    this.isFilled = false,
    this.fillColor,
  });
  
  void draw(Canvas canvas, Size size);
  bool contains(Offset point);
  bool get canFill => false;
  Map<String, dynamic> toJson();
  static Shape? fromJson(Map<String, dynamic> json) => null;
}
