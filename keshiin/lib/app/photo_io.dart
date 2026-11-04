import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../data/image_store.dart';

/// 写真の取り込みと削除（テストでは偽物に差し替える）。
abstract class PhotoStore {
  Future<({String path, int width, int height})> importPhoto(Uint8List bytes);
  Future<void> delete(String relative);
  Future<int> totalBytes();
  String absolute(String relative);
}

class FilePhotoStore implements PhotoStore {
  FilePhotoStore(this.store);
  final ImageStore store;

  @override
  Future<({String path, int width, int height})> importPhoto(Uint8List bytes) =>
      store.importPhoto(bytes);
  @override
  Future<void> delete(String relative) => store.delete(relative);
  @override
  Future<int> totalBytes() => store.totalBytes();
  @override
  String absolute(String relative) => store.absolute(relative);
}

/// 保存した写真を描画用の ui.Image にする。縮小版は使い回す。
abstract class PhotoLoader {
  /// [full] が偽なら長辺600px の縮小版。読めなければ null（灰色の面で描く）。
  Future<ui.Image?> load(String relative, {bool full = false});
  void evict(String relative);
}

class FilePhotoLoader implements PhotoLoader {
  FilePhotoLoader(this.store);
  final PhotoStore store;
  final Map<String, Future<ui.Image?>> _thumbs = {};

  @override
  Future<ui.Image?> load(String relative, {bool full = false}) {
    if (full) return _decode(store.absolute(relative));
    if (_thumbs.length > 120) _thumbs.clear();
    return _thumbs[relative] ??= _decode(
      store.absolute(ImageStore.thumbOf(relative)),
    );
  }

  Future<ui.Image?> _decode(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return null;
      final codec = await ui.instantiateImageCodec(await f.readAsBytes());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  @override
  void evict(String relative) => _thumbs.remove(relative);
}
