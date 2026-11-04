import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

import '../model/models.dart';

/// 試験日プリセット。同梱 JSON を土台に、jsDelivr の更新分があればそちらを使う。
/// 取得に失敗しても同梱版で動く。
abstract class PresetFetcher {
  /// 取れなければ null。例外は投げない。
  Future<String?> fetch(Uri url);
}

class HttpPresetFetcher implements PresetFetcher {
  const HttpPresetFetcher({this.timeout = const Duration(seconds: 6)});

  final Duration timeout;

  @override
  Future<String?> fetch(Uri url) async {
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final req = await client.getUrl(url).timeout(timeout);
      final res = await req.close().timeout(timeout);
      if (res.statusCode != 200) return null;
      return await res.transform(utf8.decoder).join().timeout(timeout);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}

class NoPresetFetcher implements PresetFetcher {
  const NoPresetFetcher();

  @override
  Future<String?> fetch(Uri url) async => null;
}

class FakePresetFetcher implements PresetFetcher {
  FakePresetFetcher([this.body]);

  String? body;
  int calls = 0;

  @override
  Future<String?> fetch(Uri url) async {
    calls++;
    return body;
  }
}

class PresetRepository {
  PresetRepository({
    required this.loadBundled,
    this.fetcher = const NoPresetFetcher(),
    this.cacheFile,
  });

  /// 同梱 JSON を読む。アプリでは [fromAssets]。
  final Future<String> Function() loadBundled;
  final PresetFetcher fetcher;

  /// 更新分の控え。null なら控えない。
  final File? cacheFile;

  static const assetPath = 'assets/presets/exam_dates.json';

  /// 更新分の置き場所。main ブランチの同梱 JSON をそのまま配信する。
  static final remoteUrl = Uri.parse(
    'https://cdn.jsdelivr.net/gh/ookura0516/ookura0516@main/nanakorobi/assets/presets/exam_dates.json',
  );

  static Future<String> fromAssets() => rootBundle.loadString(assetPath);

  static PresetCatalog? tryParse(String? text) {
    if (text == null) return null;
    try {
      final c = PresetCatalog.fromJson(jsonDecode(text) as Map<String, dynamic>);
      if (c.version != 1) return null;
      return c;
    } catch (_) {
      return null;
    }
  }

  /// 同梱版・控え・更新分のうち、いちばん新しいものを返す。
  Future<PresetCatalog> load({bool refresh = true}) async {
    var best = tryParse(await loadBundled()) ?? PresetCatalog.empty;

    final cache = cacheFile;
    if (cache != null) {
      try {
        if (await cache.exists()) {
          final cached = tryParse(await cache.readAsString());
          if (cached != null && cached.updatedOn > best.updatedOn) best = cached;
        }
      } catch (_) {}
    }

    if (refresh) {
      final remoteText = await fetcher.fetch(remoteUrl);
      final remote = tryParse(remoteText);
      if (remote != null && remote.updatedOn > best.updatedOn) {
        best = remote;
        if (cache != null) {
          try {
            await cache.writeAsString(remoteText!, flush: true);
          } catch (_) {}
        }
      }
    }
    return best;
  }
}
