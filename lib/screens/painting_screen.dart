// lib/screens/painting_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/canvas_widget.dart';
import '../widgets/color_picker.dart';
import '../widgets/size_picker.dart';
import '../models/shape.dart';
import '../models/shape_factory.dart';
import '../services/file_service.dart';
import '../services/image_export_service.dart';
import './gallery_screen.dart';

enum _NewDrawingDecision { save, discard, cancel }

class PaintingScreen extends StatefulWidget {
  @override
  State<PaintingScreen> createState() => _PaintingScreenState();
}

class _PaintingScreenState extends State<PaintingScreen> {
  String _selectedShape = 'line';
  Color _selectedColor = Colors.black;
  double _strokeWidth = 2.0;
  bool _isFillEnabled = false;
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
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Lưu bản vẽ dạng JSON',
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveDrawing,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Xuất ảnh PNG',
            child: IconButton(
              icon: const Icon(Icons.image),
              onPressed: _exportImage,
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
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Xóa tất cả',
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearAll,
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'Thư viện bản vẽ',
            child: IconButton(
              icon: const Icon(Icons.library_books),
              onPressed: _openGallery,
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
                    isFillEnabled: _isFillEnabled,
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
                    isFillEnabled: _isFillEnabled,
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
                _shapeButton('point', 'point', 'Điểm'),
                _shapeButton('line', 'line', 'Đường'),
                _shapeButton('circle', 'circle', 'Tròn'),
                _shapeButton('rectangle', 'rectangle', 'Chữ nhật'),
                _shapeButton('square', 'square', 'Vuông'),
                _shapeButton('ellipse', 'ellipse', 'Ellipse'),
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
              'Độ dày',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizePicker(
              strokeWidth: _strokeWidth,
              onSizeChanged: (size) {
                setState(() => _strokeWidth = size);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tô màu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildFillModeToggle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 170),
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
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _shapeButton('point', 'point', 'Điểm'),
                        const SizedBox(width: 4),
                        _shapeButton('line', 'line', 'Đường'),
                        const SizedBox(width: 4),
                        _shapeButton('circle', 'circle', 'Tròn'),
                        const SizedBox(width: 4),
                        _shapeButton('rectangle', 'rectangle', 'Chữ nhật'),
                        const SizedBox(width: 4),
                        _shapeButton('square', 'square', 'Vuông'),
                        const SizedBox(width: 4),
                        _shapeButton('ellipse', 'ellipse', 'Ellipse'),
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

            // Hang 3: Do day
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Độ dày ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: _buildFillModeToggle(compact: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillModeToggle({bool compact = false}) {
    final isOn = _isFillEnabled;
    final textColor = isOn ? Colors.white : Colors.grey[700]!;
    final borderColor = isOn ? Colors.teal[700]! : Colors.grey[400]!;
    final backgroundColor = isOn ? Colors.teal[400]! : Colors.grey[200]!;

    return Tooltip(
      message: isOn ? 'Tô màu' : 'Tô màu',
      child: InkWell(
        onTap: () => setState(() => _isFillEnabled = !_isFillEnabled),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isOn
                ? [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.format_color_fill,
                size: compact ? 16 : 18,
                color: textColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Tô màu',
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 6 : 8,
                  vertical: compact ? 2 : 3,
                ),
                decoration: BoxDecoration(
                  color: isOn ? Colors.white.withOpacity(0.2) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _shapeButton(String iconAsset, String shape, String label) {
    final isSelected = _selectedShape == shape;
    final iconColor = isSelected ? Colors.white : Colors.grey[700]!;
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
              SvgPicture.asset(
                'assets/icons/$iconAsset.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
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

  Future<bool> _isCurrentDrawingInLibrary() async {
    final name = _currentDrawingName?.trim();
    if (name == null || name.isEmpty) return false;
    return _fileService.drawingExists(name);
  }


  Future<String?> _promptForDrawingName({String? initialName}) async {
    if (!mounted) return null;
    var nameValue = (initialName ?? '').trim();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lưu bản vẽ'),
        content: TextFormField(
          initialValue: nameValue,
          decoration: InputDecoration(
            hintText: 'Nhập tên bản vẽ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.title),
          ),
          autofocus: true,
          onChanged: (value) => nameValue = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameValue.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập tên!')),
                );
                return;
              }
              Navigator.pop(ctx, name);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<_NewDrawingDecision?> _confirmSaveBeforeNewDrawing() async {
    if (!mounted) return null;
    return showDialog<_NewDrawingDecision>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo bản vẽ mới'),
        content: const Text('Bạn có muốn lưu bản vẽ hiện tại không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _NewDrawingDecision.cancel),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _NewDrawingDecision.discard),
            child: const Text('Không lưu'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, _NewDrawingDecision.save),
            child: const Text('Lưu và tạo mới'),
          ),
        ],
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
          const SnackBar(content: Text('Đã tạo bản vẽ mới')),
        );
      }
      return;
    }

    final isInLibrary = await _isCurrentDrawingInLibrary();
    if (isInLibrary) {
      final name = _currentDrawingName?.trim();
      if (name != null && name.isNotEmpty) {
        await _fileService.saveDrawing(_shapes, name);
      }
      if (!mounted) return;
      _resetDrawingState();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật và tạo bản vẽ mới')),
        );
      }
      return;
    }

    final decision = await _confirmSaveBeforeNewDrawing();
    if (decision == null || decision == _NewDrawingDecision.cancel) return;

    var snackMessage = 'Da tạo bản vẽ mới';
    if (decision == _NewDrawingDecision.save) {
      final name = await _promptForDrawingName(initialName: _currentDrawingName);
      if (name == null || name.trim().isEmpty) return;
      await _fileService.saveDrawing(_shapes, name);
      snackMessage = 'Đã lưu và tạo bản vẽ mới';
    }

    if (!mounted) return;
    _resetDrawingState();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackMessage)),
      );
    }
  }

  void _clearAll() {
    _resetDrawingState();
  }
  
  void _undo() {
    (_canvasKey.currentState as dynamic)?.undo();
  }
  
  void _saveDrawing() async {
    if (!mounted) return;
    final name = await _promptForDrawingName(initialName: _currentDrawingName);
    if (name == null || name.trim().isEmpty) return;
    await _fileService.saveDrawing(_shapes, name);
    if (!mounted) return;
    setState(() => _currentDrawingName = name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã lưu: $name')),
      );
    }
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
          content: Text('Xuất bản vẽ thành công'),
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
          content: Text('Xuất bản vẽ thành công'),
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
          SnackBar(content: Text(selectedName)),
        );
      }
    }
  }
}
