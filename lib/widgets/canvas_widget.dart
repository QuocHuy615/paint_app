// lib/widgets/canvas_widget.dart
import 'package:flutter/material.dart';
import '../services/drawing_service.dart';
import '../models/shape.dart';
import 'drawing_painter.dart';

class CanvasWidget extends StatefulWidget {
  final String selectedShape;
  final Color selectedColor;
  final double strokeWidth;
  final ValueChanged<List<Shape>> onShapesChanged;
  final GlobalKey repaintBoundaryKey;
  
  const CanvasWidget({
    Key? key,
    required this.selectedShape,
    required this.selectedColor,
    required this.strokeWidth,
    required this.onShapesChanged,
    required this.repaintBoundaryKey,
  }) : super(key: key);
  
  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  final DrawingService _service = DrawingService();
  List<Shape> shapes = [];
  Shape? _previewShape;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        _service.startShape(
          widget.selectedShape,
          details.localPosition,
          widget.selectedColor,
          widget.strokeWidth,
        );
      },
      onPanUpdate: (details) {
        setState(() {
          _previewShape = _service.updateShape(details.localPosition);
        });
      },
      onPanEnd: (details) {
        final shape = _service.finishShape();
        if (shape != null) {
          setState(() {
            shapes.add(shape);
            _previewShape = null;
            widget.onShapesChanged(shapes);
          });
        }
      },
      onPanCancel: () {
        setState(() {
          _previewShape = null;
          _service.clear();
        });
      },
      child: RepaintBoundary(
        key: widget.repaintBoundaryKey,
        child: Container(
          color: Colors.white,
          child: CustomPaint(
            painter: DrawingPainter(shapes, _previewShape),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
  
  void clearAll() {
    setState(() {
      shapes.clear();
      _previewShape = null;
      _service.clear();
      widget.onShapesChanged(shapes);
    });
  }
  
  void undo() {
    if (shapes.isNotEmpty) {
      setState(() {
        shapes.removeLast();
        widget.onShapesChanged(shapes);
      });
    }
  }

  void setShapes(List<Shape> newShapes) {
    setState(() {
      shapes = newShapes;
      _previewShape = null;
      _service.clear();
    });
    widget.onShapesChanged(shapes);
  }
}
