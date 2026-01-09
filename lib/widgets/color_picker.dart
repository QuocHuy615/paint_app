// lib/widgets/color_picker.dart
import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;
  
  const ColorPicker({
    required this.selectedColor,
    required this.onColorChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) {
        final isSelected = selectedColor == color;
        return Tooltip(
          message: _getColorName(color),
          child: GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.black87 : Colors.grey[400]!,
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                        )
                      ],
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 20),
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.black) return 'Đen';
    if (color == Colors.red) return 'Đỏ';
    if (color == Colors.blue) return 'Xanh dương';
    if (color == Colors.green) return 'Xanh lá';
    if (color == Colors.yellow) return 'Vàng';
    if (color == Colors.purple) return 'Tím';
    if (color == Colors.orange) return 'Cam';
    if (color == Colors.pink) return 'Hồng';
    return 'Màu';
  }
}