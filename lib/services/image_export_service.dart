// lib/services/image_export_service.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageExportService {
  static const MethodChannel _channel = MethodChannel('paint_app/downloads');

  Future<String> get _exportPath async {
    try {
      // Lấy external storage directory (nơi ứng dụng có thể lưu file công khai)
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final paintAppDir = Directory('${externalDir.path}/PaintApp');
        if (!await paintAppDir.exists()) {
          await paintAppDir.create(recursive: true);
        }
        print('External storage path: ${paintAppDir.path}');
        return paintAppDir.path;
      }
    } catch (e) {
      print('External storage not available: $e');
    }
    
    // Fallback: dùng app documents
    final appDir = await getApplicationDocumentsDirectory();
    final paintAppDir = Directory('${appDir.path}/PaintApp');
    if (!await paintAppDir.exists()) {
      await paintAppDir.create(recursive: true);
    }
    print('App documents path: ${paintAppDir.path}');
    return paintAppDir.path;
  }

  Future<String> exportAsImage(
    GlobalKey key,
    String filename,
    String format,
  ) async {
    try {
      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final img.Image decodedImage = img.decodeImage(pngBytes)!;


      final isPng = format == 'png';
      final encodedBytes = isPng
          ? img.encodePng(decodedImage)
          : img.encodeJpg(decodedImage);

      if (Platform.isAndroid) {
        final savedPath = await _channel.invokeMethod<String>(
          'saveToDownloads',
          {
            'filename': filename,
            'bytes': Uint8List.fromList(encodedBytes),
            'mimeType': isPng ? 'image/png' : 'image/jpeg',
            'subDir': 'PaintApp',
          },
        );
        return savedPath ?? '';
      }

      final exportDir = await _exportPath;
      final filepath = '$exportDir/$filename';

      if (isPng) {
        final pngFile = File(filepath);
        await pngFile.writeAsBytes(encodedBytes);
      } else {
        final jpgFile = File(filepath);
        await jpgFile.writeAsBytes(encodedBytes);
      }

      print('Ảnh đã lưu: $filepath');
      return filepath;
    } catch (e) {
      print('Lỗi: $e');
      return '';
    }
  }
}