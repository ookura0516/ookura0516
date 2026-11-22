"""声を重ねて完成版の動画を作る（お手元の Mac で実行）

  python3 mix_voice.py nejimaki V              … voice/nejimaki_V/01.wav, 02.wav … を使う
  python3 mix_voice.py --all                   … 声がそろっている分をすべて
  python3 mix_voice.py --all --say Kyoko       … macOS の読み上げで仮の声を作ってから、8本すべて

必要なもの: ffmpeg（brew install ffmpeg）、Python 3（追加のライブラリは不要）
入力: out/<案>_<V|H>_novoice.mp4、timelines/<案>_<V|H>.json、voice/<案>_<V|H>/NN.(wav|aiff|m4a|mp3)
出力: out/<案>_<V|H>_final.mp4

声は台本の位置から鳴らし、背景音は声のあいだだけ小さくする。
声が「長さの上限」を超えたら 1.15 倍まで速める。それでも超えるときは知らせる。
"""
import glob
import json
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
MAX_TEMPO = 1.15
EXTS = ('wav', 'aiff', 'aif', 'm4a', 'mp3', 'caf')


def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        sys.stderr.write(r.stderr[-3000:])
        raise SystemExit(f'失敗: {" ".join(cmd[:3])} …')
    return r.stdout


def duration(path):
    return float(run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', path]).strip())


def say_lines(base, lines, voice, rate):
    d = os.path.join(HERE, 'voice', base)
    os.makedirs(d, exist_ok=True)
    if not shutil.which('say'):
        raise SystemExit('say コマンドがありません（macOS で実行してください）')
    for ln in lines:
        out = os.path.join(d, f"{ln['n']:02d}.aiff")
        cmd = ['say', '-v', voice, '-o', out]
        if rate:
            cmd += ['-r', str(rate)]
        run(cmd + [ln['say']])


def find_voice(base, n):
    for ext in EXTS:
        hits = glob.glob(os.path.join(HERE, 'voice', base, f'{n:02d}.{ext}'))
        if hits:
            return hits[0]
    return None


def mix(base):
    tl = json.load(open(os.path.join(HERE, 'timelines', f'{base}.json'), encoding='utf-8'))
    video = os.path.join(HERE, 'out', f'{base}_novoice.mp4')
    if not os.path.exists(video):
        raise SystemExit(f'{video} がありません。先に ./build.sh で作るか、受け取った動画を out/ に置いてください')
    inputs, chains, labels, report = ['-i', video], [], [], []
    for ln in tl['lines']:
        v = find_voice(base, ln['n'])
        if not v:
            raise SystemExit(f"声のファイルがありません: voice/{base}/{ln['n']:02d}.wav（{ln['say']}）")
        d = duration(v)
        tempo = 1.0
        if d > ln['slot']:
            tempo = min(d / ln['slot'], MAX_TEMPO)
        fit = d / tempo
        mark = 'OK' if fit <= ln['slot'] + 0.05 else f'{fit - ln["slot"]:.2f}秒はみ出し'
        report.append(f"  {ln['n']:02d} {d:5.2f}秒 → {fit:5.2f}秒（上限 {ln['slot']:.2f}）{'' if tempo == 1 else f' 速さ×{tempo:.2f}'} {mark}")
        k = len(inputs) // 2
        inputs += ['-i', v]
        ms = int(ln['start'] * 1000)
        chains.append(f"[{k}:a]aformat=sample_rates=48000:channel_layouts=stereo,highpass=f=80,"
                      f"atempo={tempo:.4f},volume=1.6,adelay={ms}|{ms}[v{k}]")
        labels.append(f'[v{k}]')
    n = len(labels)
    total = tl['duration']
    graph = ';'.join(chains)
    graph += f";{''.join(labels)}amix=inputs={n}:duration=longest:normalize=0,apad,atrim=0:{total:.3f}[vo]"
    graph += ';[vo]asplit=2[vo1][vo2]'
    graph += ';[0:a][vo1]sidechaincompress=threshold=0.02:ratio=8:attack=15:release=350[duck]'
    graph += ';[duck][vo2]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-16:TP=-1.5:LRA=11,apad[aout]'
    out = os.path.join(HERE, 'out', f'{base}_final.mp4')
    run(['ffmpeg', '-y', '-loglevel', 'error', *inputs, '-filter_complex', graph,
         '-map', '0:v', '-map', '[aout]', '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k', '-ar', '48000',
         '-shortest', '-movflags', '+faststart', out])
    print(f'{base}: {out}')
    print('\n'.join(report))


def main():
    args = sys.argv[1:]
    voice = rate = None
    if '--say' in args:
        i = args.index('--say')
        voice = args[i + 1]
        del args[i:i + 2]
    if '--rate' in args:
        i = args.index('--rate')
        rate = int(args[i + 1])
        del args[i:i + 2]
    if '--all' in args:
        bases = sorted(os.path.basename(p)[:-5] for p in glob.glob(os.path.join(HERE, 'timelines', '*.json')))
    elif len(args) >= 2:
        bases = [f'{args[0]}_{args[1]}']
    else:
        print(__doc__)
        return
    for base in bases:
        if voice:
            tl = json.load(open(os.path.join(HERE, 'timelines', f'{base}.json'), encoding='utf-8'))
            say_lines(base, tl['lines'], voice, rate)
        if not all(find_voice(base, ln['n']) for ln in json.load(open(os.path.join(HERE, 'timelines', f'{base}.json'), encoding='utf-8'))['lines']):
            print(f'{base}: 声がそろっていないので飛ばします')
            continue
        mix(base)


if __name__ == '__main__':
    main()
