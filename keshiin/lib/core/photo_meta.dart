import 'dart:typed_data';

import 'package:exif/exif.dart';

/// 写真から読んだ撮影日と位置。どちらも無いことがある。
class PhotoMeta {
  const PhotoMeta({this.taken, this.lat, this.lng});

  final DateTime? taken;
  final double? lat;
  final double? lng;

  bool get hasLocation => lat != null && lng != null;

  static const empty = PhotoMeta();
}

/// 写真の EXIF から撮影日時と GPS を読む。読めなければ空を返す（失敗にしない）。
Future<PhotoMeta> readPhotoMeta(Uint8List bytes) async {
  try {
    final tags = await readExifFromBytes(bytes);
    if (tags.isEmpty) return PhotoMeta.empty;
    final taken = parseExifDate(
      tags['EXIF DateTimeOriginal']?.printable ??
          tags['EXIF DateTimeDigitized']?.printable ??
          tags['Image DateTime']?.printable,
    );
    final lat = _gps(tags['GPS GPSLatitude'], tags['GPS GPSLatitudeRef']);
    final lng = _gps(tags['GPS GPSLongitude'], tags['GPS GPSLongitudeRef']);
    return PhotoMeta(taken: taken, lat: lat, lng: lat == null ? null : lng);
  } catch (_) {
    return PhotoMeta.empty;
  }
}

/// 「2026:11:04 09:12:33」→ DateTime（端末の時刻として）。
DateTime? parseExifDate(String? s) {
  if (s == null) return null;
  final m = RegExp(
    r'^(\d{4})[:\-](\d{2})[:\-](\d{2})[ T]?(\d{2})?:?(\d{2})?:?(\d{2})?',
  ).firstMatch(s.trim());
  if (m == null) return null;
  final y = int.parse(m[1]!);
  final mo = int.parse(m[2]!);
  final d = int.parse(m[3]!);
  if (y < 1900 || mo < 1 || mo > 12 || d < 1 || d > 31) return null;
  return DateTime(
    y,
    mo,
    d,
    int.tryParse(m[4] ?? '') ?? 0,
    int.tryParse(m[5] ?? '') ?? 0,
    int.tryParse(m[6] ?? '') ?? 0,
  );
}

double? _gps(IfdTag? value, IfdTag? ref) {
  if (value == null) return null;
  final v = value.values;
  if (v is! IfdRatios) return null;
  final r = v.ratios;
  if (r.isEmpty) return null;
  double part(int i) => i < r.length && r[i].denominator != 0
      ? r[i].numerator / r[i].denominator
      : 0;
  var deg = part(0) + part(1) / 60 + part(2) / 3600;
  final refStr = ref?.printable.trim().toUpperCase() ?? '';
  if (refStr.startsWith('S') || refStr.startsWith('W')) deg = -deg;
  if (deg == 0) return null; // 0,0 は「位置なし」を書き込むカメラがある
  return deg;
}
