// lib/screens/painting_screen.dart
import 'package:flutter/material.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/color_picker.dart';
import '../widgets/size_picker.dart';
import '../models/shape.dart';
import '../models/shape_factory.dart';
import '../services/file_service.dart';
import '../services/image_export_service.dart';
import './gallery_screen.dart';

class PaintingScreen extends StatefulWidget {
  @override
  State<PaintingScreen> createState() => _PaintingScreenState();
}

class _PaintingScreenState extends State<PaintingScreen> {
  String _selectedShape = 'line';
  Color _selectedColor = Colors.black;
  double _strokeWidth = 2.0;
  List<Shape> _shapes = [];
  String? _currentDrawingName;
  
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _repaintKey = GlobalKey();
  final FileService _fileService = FileService();
  final ImageExportService _imageService = ImageExportService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 Paint App', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 2,
        shadowColor: Colors.black26,
        actions: [
          Tooltip(
            message: 'Tao ban ve moi',
            child: IconButton(
              icon: const Icon(Icons.note_add),
              onPressed: _createNewDrawing,
              style: IconButton.styleFrom(
                backgroundColor: Colors.teal.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Lưu bản vẽ dạng JSON',
            child: IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveDrawing,
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Xuất ảnh PNG',
            child: IconButton(
              icon: const Icon(Icons.image),
              onPressed: _exportImage,
              style: IconButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'jpg') {
                _exportImageAsJpg();
              }
            },
            tooltip: 'Xuất ảnh JPG',
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'jpg',
                child: Row(
                  children: const [
                    Icon(Icons.photo_library, size: 20),
                    SizedBox(width: 8),
                    Text('Xuất JPG'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.more_vert),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Hoàn tác',
            child: IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _undo,
              style: IconButton.styleFrom(
                backgroundColor: Colors.amber.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Xóa tất cả',
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearAll,
              style: IconButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Thư viện bản vẽ',
            child: IconButton(
              icon: const Icon(Icons.library_books),
              onPressed: _openGallery,
              style: IconButton.styleFrom(
                backgroundColor: Colors.purple.withOpacity(0.1),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          
          if (isDesktop) {
            // Desktop: sidebar bên phải
            return Row(
              children: [
                Expanded(
                  child: CanvasWidget(
                    key: _canvasKey,
                    selectedShape: _selectedShape,
                    selectedColor: _selectedColor,
                    strokeWidth: _strokeWidth,
                    onShapesChanged: (shapes) => _shapes = shapes,
                    repaintBoundaryKey: _repaintKey,
                  ),
                ),
                _buildSideToolbar(),
              ],
            );
          } else {
            // Mobile: toolbar dưới
            return Column(
              children: [
                Expanded(
                  child: CanvasWidget(
                    key: _canvasKey,
                    selectedShape: _selectedShape,
                    selectedColor: _selectedColor,
                    strokeWidth: _strokeWidth,
                    onShapesChanged: (shapes) => _shapes = shapes,
                    repaintBoundaryKey: _repaintKey,
                  ),
                ),
                _buildBottomToolbar(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSideToolbar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          left: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chọn hình
            const Text(
              '✏️ Chọn Hình',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _shapeButton('●', 'point', 'Điểm'),
                _shapeButton('📏', 'line', 'Đường'),
                _shapeButton('⭕', 'circle', 'Tròn'),
                _shapeButton('▭', 'rectangle', 'Chữ nhật'),
                _shapeButton('⬜', 'square', 'Vuông'),
                _shapeButton('⬭', 'ellipse', 'Ellipse'),
              ],
            ),
            const SizedBox(height: 16),

            // Chọn màu
            const Text(
              '🎨 Màu Sắc',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            ColorPicker(
              selectedColor: _selectedColor,
              onColorChanged: (color) {
                setState(() => _selectedColor = color);
              },
            ),
            const SizedBox(height: 16),

            // Chọn độ dày
            const Text(
              '📏 Độ Dày',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizePicker(
              strokeWidth: _strokeWidth,
              onSizeChanged: (size) {
                setState(() => _strokeWidth = size);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 130),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(250, 250, 250, 1),
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hàng 1: Chọn hình
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✏️ ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _shapeButton('●', 'point', 'Điểm'),
                        const SizedBox(width: 4),
                        _shapeButton('📏', 'line', 'Đường'),
                        const SizedBox(width: 4),
                        _shapeButton('⭕', 'circle', 'Tròn'),
                        const SizedBox(width: 4),
                        _shapeButton('▭', 'rectangle', 'Chữ nhật'),
                        const SizedBox(width: 4),
                        _shapeButton('⬜', 'square', 'Vuông'),
                        const SizedBox(width: 4),
                        _shapeButton('⬭', 'ellipse', 'Ellipse'),
                        const SizedBox(width: 4),
                        _shapeButton('▭', 'rectangle', 'Chữ nhật'),
                        const SizedBox(width: 4),
                        _shapeButton('⬭', 'ellipse', 'Ellipse'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hàng 2: Chọn màu
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('🎨 ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        children: [
                          Colors.black,
                          Colors.red,
                          Colors.blue,
                          Colors.green,
                          Colors.yellow,
                          Colors.purple,
                          Colors.orange,
                          Colors.pink,
                        ]
                          .map((color) {
                            final isSelected = _selectedColor == color;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _selectedColor = color);
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black87
                                          : Colors.grey[400]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(Icons.check,
                                              color: Colors.white, size: 14),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          })
                          .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Hàng 3: Độ dày
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('📏 ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 20,
                    value: _strokeWidth,
                    onChanged: (size) {
                      setState(() => _strokeWidth = size);
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${_strokeWidth.toStringAsFixed(1)}px',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _shapeButton(String icon, String shape, String label) {
    final isSelected = _selectedShape == shape;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => setState(() => _selectedShape = shape),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected 
              ? Colors.blue.withOpacity(0.9)
              : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : null,
            boxShadow: isSelected
              ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 6)]
              : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _resetDrawingState() {
    if (!mounted) return;
    (_canvasKey.currentState as dynamic)?.clearAll();
    setState(() {
      _shapes = [];
      _currentDrawingName = null;
    });
  }

  Future<void> _createNewDrawing() async {
    if (!mounted) return;

    if (_shapes.isEmpty) {
      _resetDrawingState();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da tao ban ve moi')),
        );
      }
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tao ban ve moi'),
        content: const Text('Ban ve hien tai se bi xoa. Tiep tuc?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tao moi'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      if (!mounted) return;
      _resetDrawingState();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Da tao ban ve moi')),
        );
      }
    }
  }

  void _clearAll() {
    _resetDrawingState();
  }
  
  void _undo() {
    (_canvasKey.currentState as dynamic)?.undo();
  }
  
  void _saveDrawing() async {
    final nameController = TextEditingController();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💾 Lưu bản vẽ'),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Nhập tên bản vẽ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('❌ Vui lòng nhập tên!')),
                );
                return;
              }
              
              await _fileService.saveDrawing(_shapes, name);
              setState(() => _currentDrawingName = name);
              
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Đã lưu: $name')),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
  
  void _exportImage() async {
    final filepath = await _imageService.exportAsImage(
      _repaintKey,
      'drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      'png',
    );
    if (filepath.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ PNG: $filepath'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _exportImageAsJpg() async {
    final filepath = await _imageService.exportAsImage(
      _repaintKey,
      'drawing_${DateTime.now().millisecondsSinceEpoch}.jpg',
      'jpg',
    );
    if (filepath.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ JPG: $filepath'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openGallery() async {
    if (!mounted) return;
    
    final selectedName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (ctx) => const GalleryScreen()),
    );
    
    if (selectedName == GalleryScreen.newDrawingToken) {
      await _createNewDrawing();
      return;
    }

    if (selectedName != null && mounted) {
      final drawingData = await _fileService.loadDrawing(selectedName);
      if (!mounted) return;
      if (drawingData.isNotEmpty) {
        final loadedShapes = drawingData
            .map(shapeFromJson)
            .whereType<Shape>()
            .toList();

        (_canvasKey.currentState as dynamic)?.setShapes(loadedShapes);
        setState(() {
          _shapes = loadedShapes;
          _currentDrawingName = selectedName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Da tai: $selectedName')),
        );
      }
    }
  }
}
