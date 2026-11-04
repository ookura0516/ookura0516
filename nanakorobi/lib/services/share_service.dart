import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// 共有シートへ PNG を渡す。ストアリンクは画像にも本文にも入れない。
abstract class ShareService {
  Future<void> sharePng(Uint8List png, {required String fileName, String? text});
}

class SharePlusService implements ShareService {
  const SharePlusService();

  @override
  Future<void> sharePng(Uint8List png, {required String fileName, String? text}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(png, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
      ),
    );
  }
}

class FakeShareService implements ShareService {
  final List<(String, String?)> shared = [];
  Uint8List? lastPng;

  @override
  Future<void> sharePng(Uint8List png, {required String fileName, String? text}) async {
    lastPng = png;
    shared.add((fileName, text));
  }
}

/// JSON の書き出し・読み込み（プラス）。書き出しは共有シートへ、読み込みはファイル選択から。
abstract class BackupFileService {
  Future<void> exportJson(String json, {required String fileName});

  /// 選ばなかったら null。
  Future<String?> pickJson();
}

class PlatformBackupFileService implements BackupFileService {
  const PlatformBackupFileService();

  @override
  Future<void> exportJson(String json, {required String fileName}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(json, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json')]),
    );
  }

  @override
  Future<String?> pickJson() async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'JSON', extensions: ['json'], mimeTypes: ['application/json']),
      ],
    );
    if (file == null) return null;
    return file.readAsString();
  }
}

class FakeBackupFileService implements BackupFileService {
  String? exported;
  String? toImport;

  @override
  Future<void> exportJson(String json, {required String fileName}) async => exported = json;

  @override
  Future<String?> pickJson() async => toImport;
}
