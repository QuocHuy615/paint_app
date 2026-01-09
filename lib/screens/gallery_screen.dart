import 'package:flutter/material.dart';
import '../services/file_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({Key? key}) : super(key: key);
  static const String newDrawingToken = '__new_drawing__';

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late FileService _fileService;
  late Future<List<DrawingInfo>> _drawingsFuture;

  @override
  void initState() {
    super.initState();
    _fileService = FileService();
    _loadDrawings();
  }

  void _loadDrawings() {
    setState(() {
      _drawingsFuture = _fileService.getDrawingsList();
    });
  }

  void _deleteDrawing(String drawingName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('❌ Xóa bản vẽ'),
        content: Text('Bạn chắc chắn muốn xóa "$drawingName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await _fileService.deleteDrawing(drawingName);
              Navigator.pop(ctx);
              _loadDrawings();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ Đã xóa "$drawingName"')),
                );
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Thư Viện Bản Vẽ'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Tao ban ve moi',
            icon: const Icon(Icons.note_add),
            onPressed: () {
              Navigator.pop(context, GalleryScreen.newDrawingToken);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<DrawingInfo>>(
        future: _drawingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🎨 Chưa có bản vẽ nào',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, GalleryScreen.newDrawingToken);
                    },
                    icon: const Icon(Icons.create),
                    label: const Text('Tạo bản vẽ mới'),
                  ),
                ],
              ),
            );
          }

          final drawings = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: drawings.length,
            itemBuilder: (context, index) {
              final drawing = drawings[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.image, size: 40, color: Colors.blue),
                  title: Text(
                    drawing.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('📅 ${drawing.formattedDate}'),
                      Text('📦 ${drawing.formattedSize}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        child: const Text('📂 Mở'),
                        onTap: () {
                          Navigator.pop(context, drawing.name);
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('❌ Xóa', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Future.delayed(
                            const Duration(milliseconds: 100),
                            () => _deleteDrawing(drawing.name),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context, drawing.name);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
