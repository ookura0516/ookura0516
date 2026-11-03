// ストア用のスクリーンショットを撮るための入口（Web で動かす）。手順は store/README.md。
// ?v=room で部屋番号の画面、?stage=N&role=a|b でそのステージを、部屋 122 332 で開く。
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisokagi/core/room_code.dart';
import 'package:hisokagi/game/services.dart';
import 'package:hisokagi/game/session.dart';
import 'package:hisokagi/monetize/purchase_service.dart';
import 'package:hisokagi/scenario/model.dart';
import 'package:hisokagi/ui/app_controller.dart';
import 'package:hisokagi/ui/screens/play_screen.dart';
import 'package:hisokagi/ui/screens/ready_screen.dart';
import 'package:hisokagi/ui/screens/title_screen.dart';
import 'package:hisokagi/ui/theme.dart';

class _P extends PurchaseService {
  @override
  bool get hasPass => false;
  @override
  String get priceLabel => '¥600';
  @override
  PassStatus get status => PassStatus.idle;
  @override
  Future<void> init() async {}
  @override
  Future<void> buyPass() async {}
  @override
  Future<void> restore() async {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  final app = AppController(store: SessionStore(prefs), purchases: _P());
  final q = Uri.base.queryParameters;
  const code = RoomCode(scenario: 1, players: 2, seed: 233);
  Widget home = const TitleScreen();
  if (q['v'] == 'room') {
    final s = app.start(code: code, mode: PlayMode.linked, roles: {Role.a});
    home = ReadyScreen(session: s, purpose: ReadyPurpose.created);
  } else if (q.containsKey('stage')) {
    final role = q['role'] == 'b' ? Role.b : Role.a;
    final s = GameSession(
      code: code,
      mode: PlayMode.linked,
      roles: {role},
      progress: {role: int.parse(q['stage']!)},
    );
    home = PlayScreen(session: s);
  }
  runApp(
    ChangeNotifierProvider.value(
      value: app,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: HisokagiTheme.dark,
        home: home,
      ),
    ),
  );
}
