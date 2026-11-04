import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 共有シート。画像1枚と短い文を渡す。ストアリンクは入れない（設計書「共有画像と拡散の設計」）。
abstract class ShareService {
  Future<bool> shareImage(Uint8List png, {required String fileName, required String text});
}

class NoShareService implements ShareService {
  const NoShareService();

  @override
  Future<bool> shareImage(Uint8List png, {required String fileName, required String text}) async => false;
}

class SharePlusService implements ShareService {
  const SharePlusService();

  @override
  Future<bool> shareImage(Uint8List png, {required String fileName, required String text}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(png, flush: true);
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'image/png')], text: text),
    );
    return result.status == ShareResultStatus.success;
  }
}
