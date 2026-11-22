"""ナレーション台本（読み上げる文と、入れる位置・長さ）を書き出す

  python3 narration.py

out/*.timeline.json を読み、次の2つを作る。
- timelines/<案>_<V|H>.json … mix_voice.py が使う時間割（リポジトリに残す）
- ナレーション台本.md         … 録音・音声合成用の台本
"""
import glob
import json
import os
import shutil

HERE = os.path.dirname(os.path.abspath(__file__))
ORDER = ['nejimaki', 'masume', 'hoshimusubi', 'hanabishi']
NAMES = {'nejimaki': 'ネジマキ', 'masume': 'マスメ', 'hoshimusubi': 'ホシムスビ', 'hanabishi': 'ハナビシ'}
FMTS = {'V': '縦型 9:16', 'H': '横型 16:9'}


def main():
    os.makedirs(os.path.join(HERE, 'timelines'), exist_ok=True)
    tls = {}
    for p in glob.glob(os.path.join(HERE, 'out', '*.timeline.json')):
        tl = json.load(open(p, encoding='utf-8'))
        base = f"{tl['app']}_{tl['fmt']}"
        slim = {k: tl[k] for k in ('app', 'fmt', 'duration', 'cps')}
        slim['lines'] = [{'n': i + 1, 'say': s['say'], 'caption': s['text'], 'start': s['vo']['start'], 'slot': s['vo']['slot']} for i, s in enumerate(tl['scenes'])]
        json.dump(slim, open(os.path.join(HERE, 'timelines', f'{base}.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
        tls[base] = slim
    out = ['# ナレーション台本', '',
           '動画は声なしで作ってあります。下の文を1行ずつ音声ファイルにして `voice/<案>_<V|H>/01.wav, 02.wav …` に置き、',
           '`python3 mix_voice.py <案> <V|H>` を実行すると、決まった位置に声が入り、背景音は声の間だけ小さくなります。',
           'macOS の読み上げ（say）で仮の声を入れるなら `python3 mix_voice.py --all --say Kyoko` だけで8本できます。', '',
           '「長さの上限」を超えた声は、1.15倍まで自動で速めます。それでも収まらないときは `CPS=5.5 ./build.sh` で動画を作り直してください。', '']
    for app in ORDER:
        for fmt in ('V', 'H'):
            tl = tls.get(f'{app}_{fmt}')
            if not tl:
                continue
            out += [f"## {NAMES[app]}・{FMTS[fmt]}（{tl['duration']:.1f}秒）", '',
                    '| 番号 | 読み上げる文 | 始まり（秒） | 長さの上限（秒） |', '| --- | --- | --- | --- |']
            for ln in tl['lines']:
                out.append(f"| {ln['n']:02d} | {ln['say']} | {ln['start']:.2f} | {ln['slot']:.2f} |")
            out.append('')
    open(os.path.join(HERE, 'ナレーション台本.md'), 'w', encoding='utf-8').write('\n'.join(out))
    print('ナレーション台本.md と timelines/ を更新しました', sorted(tls))


if __name__ == '__main__':
    main()
