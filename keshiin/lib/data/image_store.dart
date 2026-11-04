import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// 元の写真をアプリ内にコピーして持つ。写真ライブラリから消えても切手は残る。
///
/// 元画像は長辺2400px に縮小して保存（容量対策、設計書「リスクと対策」）。
/// シートの表示用に長辺600px の縮小版も作る（設計書「目打ちの描画」）。
class ImageStore {
  ImageStore(this.rootDir);

  /// アプリの書類フォルダ。DB にはここからの相対パスを書く。
  final Directory rootDir;

  static const int maxLongSide = 2400;
  static const int thumbLongSide = 600;

  String absolute(String relative) => p.join(rootDir.path, relative);

  /// 縮小版のパス（元画像の名前から決める）。
  static String thumbOf(String relative) =>
      relative.replaceFirst(RegExp(r'\.jpg$'), '_t.jpg');

  /// 写真を取り込み、相対パスと縦横の画素数を返す。
  Future<({String path, int width, int height})> importPhoto(
    Uint8List bytes, {
    DateTime? now,
  }) async {
    final stamp = (now ?? DateTime.now()).microsecondsSinceEpoch;
    final rel = p.join('photos', 'p$stamp.jpg');
    final out = await Isolate.run(() => _process(bytes));
    final file = File(absolute(rel));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(out.full, flush: true);
    await File(absolute(thumbOf(rel))).writeAsBytes(out.thumb, flush: true);
    return (path: rel, width: out.width, height: out.height);
  }

  Future<void> delete(String relative) async {
    for (final r in [relative, thumbOf(relative)]) {
      final f = File(absolute(r));
      if (await f.exists()) await f.delete();
    }
  }

  /// 使っているファイルの合計（設定の容量表示）。
  Future<int> totalBytes() async {
    final dir = Directory(p.join(rootDir.path, 'photos'));
    if (!await dir.exists()) return 0;
    var sum = 0;
    await for (final e in dir.list()) {
      if (e is File) sum += await e.length();
    }
    return sum;
  }
}

class _Processed {
  _Processed(this.full, this.thumb, this.width, this.height);
  final Uint8List full;
  final Uint8List thumb;
  final int width;
  final int height;
}

_Processed _process(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('写真を読めませんでした');
  // EXIF の向きを画素に反映してから縮小する（向きの情報は保存しない）。
  final upright = img.bakeOrientation(decoded);
  final full = resizeLongSide(upright, ImageStore.maxLongSide);
  final thumb = resizeLongSide(full, ImageStore.thumbLongSide);
  return _Processed(
    img.encodeJpg(full, quality: 90),
    img.encodeJpg(thumb, quality: 85),
    full.width,
    full.height,
  );
}

/// 長辺が [maxSide] を超えるときだけ縮小する。
img.Image resizeLongSide(img.Image src, int maxSide) {
  final long = src.width > src.height ? src.width : src.height;
  if (long <= maxSide) return src;
  return src.width >= src.height
      ? img.copyResize(
          src,
          width: maxSide,
          interpolation: img.Interpolation.average,
        )
      : img.copyResize(
          src,
          height: maxSide,
          interpolation: img.Interpolation.average,
        );
}
