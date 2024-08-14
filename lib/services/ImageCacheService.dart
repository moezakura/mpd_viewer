import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static const String _cacheDirectoryName = 'image_cache';

  Future<File> getCachedImage(String id) async {
    final cacheDir = await _getCacheDirectory();
    final file = File('${cacheDir.path}/$id');

    if (await file.exists()) {
      return file;
    } else {
      throw Exception('Image not found in cache');
    }
  }

  Future<File> cacheImage(String id, Uint8List imageData) async {
    final cacheDir = await _getCacheDirectory();
    final file = File('${cacheDir.path}/$id');

    await file.writeAsBytes(imageData);
    return file;
  }

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationCacheDirectory();
    final cacheDir = Directory('${appDir.path}/$_cacheDirectoryName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<void> clearCache() async {
    final cacheDir = await _getCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }

  Future<bool> isCached(String id) async {
    final cacheDir = await _getCacheDirectory();
    final file = File('${cacheDir.path}/$id');
    return await file.exists();
  }
}
