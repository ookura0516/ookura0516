#!/usr/bin/env bash
# 声なし版の動画を作る
#   ./build.sh                 … 4案 × 縦横 = 8本
#   ./build.sh nejimaki V      … 1本だけ
#   CPS=5.5 ./build.sh         … 声が遅い場合（1秒あたりの文字数を小さくすると、場面が長くなる）
set -euo pipefail
cd "$(dirname "$0")"
CPS="${CPS:-6.2}"
APPS=(nejimaki masume hoshimusubi hanabishi)
FMTS=(V H)
if [ $# -ge 1 ]; then APPS=("$1"); fi
if [ $# -ge 2 ]; then FMTS=("$2"); fi
mkdir -p out
for app in "${APPS[@]}"; do
  for fmt in "${FMTS[@]}"; do
    base="${app}_${fmt}"
    node render.mjs "$app" "$fmt" --cps "$CPS"
    python3 audio.py "out/${base}.timeline.json" "out/${base}_bgm.wav"
    ffmpeg -y -loglevel error -i "out/${base}_video.mp4" -i "out/${base}_bgm.wav" \
      -map 0:v -map 1:a -c:v copy -c:a aac -b:a 192k -shortest -movflags +faststart "out/${base}_novoice.mp4"
    rm -f "out/${base}_video.mp4"
    echo "→ out/${base}_novoice.mp4"
  done
done
python3 narration.py
