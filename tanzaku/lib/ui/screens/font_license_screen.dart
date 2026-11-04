import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 同梱フォントと、そのライセンス文。
const bundledFonts = [
  ('Noto Serif JP', '無料で使える書体。短冊・句帳の標準', 'assets/licenses/NotoSerifJP-OFL.txt'),
  (
    'しっぽり明朝（Shippori Mincho）',
    'すずりで使える書体',
    'assets/licenses/ShipporiMincho-OFL.txt',
  ),
  ('Yuji Syuku', 'すずりで使える筆の書体', 'assets/licenses/YujiSyuku-OFL.txt'),
];

class FontLicenseScreen extends StatelessWidget {
  const FontLicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('フォントのライセンス')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '次のフォントを SIL Open Font License 1.1 に従って同梱しています。Noto Serif JP は太さ400の静的なフォントに書き出して使っています。',
          ),
          const SizedBox(height: 8),
          for (final (name, use, path) in bundledFonts)
            ExpansionTile(
              title: Text(name),
              subtitle: Text(use),
              children: [
                FutureBuilder<String>(
                  future: rootBundle.loadString(path),
                  builder: (context, snap) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: SelectableText(
                      snap.data ?? '…',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
