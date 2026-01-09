import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../models/shape.dart';

class FileService {
  Future<String> get _localPath async {
    try {
      // Lấy external storage directory
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final paintAppDir = Directory('${externalDir.path}/PaintApp');
        if (!await paintAppDir.exists()) {
          await paintAppDir.create(recursive: true);
        }
        print('📂 External storage path: ${paintAppDir.path}');
        return paintAppDir.path;
      }
    } catch (e) {
      print('⚠️ External storage not available: $e');
    }
    
    // Fallback: app documents
    final appDir = await getApplicationDocumentsDirectory();
    final paintAppDir = Directory('${appDir.path}/PaintApp');
    if (!await paintAppDir.exists()) {
      await paintAppDir.create(recursive: true);
    }
    print('📂 App documents path: ${paintAppDir.path}');
    return paintAppDir.path;
  }

  // Lưu bản vẽ với tên cụ thể
  Future<String> saveDrawing(List<Shape> shapes, String drawingName) async {
    final path = await _localPath;
    final filename = '$drawingName.json';
    final file = File('$path/$filename');
    
    final data = shapes.map((s) => s.toJson()).toList();
    await file.writeAsString(jsonEncode(data));
    
    print('✅ Bản vẽ "$drawingName" đã lưu: ${file.path}');
    return file.path;
  }

  Future<bool> drawingExists(String drawingName) async {
    try {
      final path = await _localPath;
      final file = File('$path/$drawingName.json');
      return await file.exists();
    } catch (e) {
      print('Error checking drawing: $e');
      return false;
    }
  }

  // Lấy danh sách tất cả bản vẽ đã lưu
  Future<List<DrawingInfo>> getDrawingsList() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      
      if (!await dir.exists()) return [];
      
      final files = dir.listSync();
      final drawings = <DrawingInfo>[];
      
      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final name = file.path.split('/').last.replaceAll('.json', '');
          final stat = await file.stat();
          
          drawings.add(DrawingInfo(
            name: name,
            path: file.path,
            modified: stat.modified,
            size: stat.size,
          ));
        }
      }
      
      // Sắp xếp theo ngày sửa đổi (mới nhất trước)
      drawings.sort((a, b) => b.modified.compareTo(a.modified));
      return drawings;
    } catch (e) {
      print('❌ Lỗi lấy danh sách: $e');
      return [];
    }
  }

  // Load bản vẽ cụ thể
  Future<List<Map<String, dynamic>>> loadDrawing(String drawingName) async {
    try {
      final path = await _localPath;
      final file = File('$path/$drawingName.json');
      
      if (!await file.exists()) return [];

      final contents = await file.readAsString();
      print('✅ Đã tải bản vẽ: $drawingName');
      return List<Map<String, dynamic>>.from(jsonDecode(contents));
    } catch (e) {
      print('❌ Lỗi tải file: $e');
      return [];
    }
  }

  // Xóa bản vẽ
  Future<bool> deleteDrawing(String drawingName) async {
    try {
      final path = await _localPath;
      final file = File('$path/$drawingName.json');
      
      if (await file.exists()) {
        await file.delete();
        print('✅ Đã xóa bản vẽ: $drawingName');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Lỗi xóa file: $e');
      return false;
    }
  }
}

// Class để lưu thông tin bản vẽ
class DrawingInfo {
  final String name;
  final String path;
  final DateTime modified;
  final int size;

  DrawingInfo({
    required this.name,
    required this.path,
    required this.modified,
    required this.size,
  });

  String get formattedDate {
    return '${modified.day}/${modified.month}/${modified.year} ${modified.hour}:${modified.minute.toString().padLeft(2, '0')}';
  }

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
