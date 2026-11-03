import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/room_code.dart';
import '../../game/session.dart';
import '../../scenario/model.dart';
import '../../scenario/registry.dart';
import '../app_controller.dart';
import 'ready_screen.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _message(RoomCodeError e) => switch (e) {
        RoomCodeError.length => '6けたの数字を入れてください。',
        RoomCodeError.check => '番号がちがうか、アプリのバージョンがちがいます。'
            'もう一度たしかめて、ふたりとも最新のアプリにしてください。',
        RoomCodeError.scenario => 'このアプリにはないシナリオの番号です。アプリを最新にしてください。',
        RoomCodeError.players => '番号がちがうようです。もう一度たしかめてください。',
      };

  void _join() {
    final (code, error) =
        RoomCode.parse(_controller.text, knownScenarios: knownScenarioIds);
    if (code == null) {
      setState(() => _error = _message(error!));
      return;
    }
    // 2人用では、部屋をつくった人がA、はいった人がB。
    final session = context.read<AppController>().start(
          code: code,
          mode: PlayMode.linked,
          roles: {Role.b},
        );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReadyScreen(session: session, purpose: ReadyPurpose.joined),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('部屋にはいる')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('相棒の画面に出ている、6けたの部屋番号を入れてください。',
              style: TextStyle(height: 1.6)),
          const SizedBox(height: 20),
          TextField(
            key: const Key('join-code'),
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 7,
            style: const TextStyle(fontSize: 32, letterSpacing: 8),
            decoration: InputDecoration(
              hintText: '000 000',
              errorText: _error,
              errorMaxLines: 3,
              counterText: '',
            ),
            onSubmitted: (_) => _join(),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _join, child: const Text('はいる')),
        ],
      ),
    );
  }
}
