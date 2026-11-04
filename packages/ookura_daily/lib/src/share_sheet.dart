import 'dart:typed_data';
import 'dart:ui';

import 'package:share_plus/share_plus.dart';

/// 共有シートの窓口。テストでは差し替える。
abstract class ShareSheet {
  /// 文字だけを共有する。
  Future<void> shareText(String text, {Rect? origin});

  /// PNG を共有する。[text] は投稿文の下書きとして添える。
  Future<void> sharePng(
    Uint8List png, {
    required String fileName,
    String? text,
    Rect? origin,
  });
}

/// share_plus で OS の共有シートを開く。
class SystemShareSheet implements ShareSheet {
  const SystemShareSheet();

  @override
  Future<void> shareText(String text, {Rect? origin}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, sharePositionOrigin: origin),
    );
  }

  @override
  Future<void> sharePng(
    Uint8List png, {
    required String fileName,
    String? text,
    Rect? origin,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(png, mimeType: 'image/png', name: fileName)],
        fileNameOverrides: [fileName],
        text: text,
        sharePositionOrigin: origin,
      ),
    );
  }
}
