// lib/widgets/size_picker.dart
import 'package:flutter/material.dart';

class SizePicker extends StatelessWidget {
  final double strokeWidth;
  final ValueChanged<double> onSizeChanged;
  
  const SizePicker({
    required this.strokeWidth,
    required this.onSizeChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Độ dày',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${strokeWidth.toStringAsFixed(1)}px',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 4,
            ),
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.blue,
          ),
          child: Slider(
            min: 1,
            max: 20,
            value: strokeWidth,
            onChanged: onSizeChanged,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: strokeWidth,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}