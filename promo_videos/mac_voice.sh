#!/usr/bin/env bash
# Mac で実行する：声なし動画を8本作り、macOS の読み上げで仮の声を入れて完成版を作る
#
#   ./promo_videos/mac_voice.sh            … 声は Kyoko
#   VOICE=Otoya ./promo_videos/mac_voice.sh … 別の声（say -v '?' | grep ja_JP で一覧）
#
# できるもの: promo_videos/out/<案>_<V|H>_final.mp4（8本）
# 必要なもの: ffmpeg（brew install ffmpeg）、Node.js、Python 3、Google Chrome か Playwright の Chromium
# 使う容量: 字体と動画で約0.5GB
set -euo pipefail
cd "$(dirname "$0")"
VOICE="${VOICE:-Kyoko}"

say_step() { printf '\n== %s\n' "$1"; }

say_step '必要なものの確認'
command -v ffmpeg >/dev/null || { echo 'ffmpeg がありません。brew install ffmpeg を実行してください'; exit 1; }
command -v node >/dev/null || { echo 'Node.js がありません。brew install node を実行してください'; exit 1; }
command -v python3 >/dev/null || { echo 'Python 3 がありません'; exit 1; }
command -v say >/dev/null || { echo 'say がありません（macOS で実行してください）'; exit 1; }
df -h . | tail -1

say_step '声の確認'
if ! say -v "$VOICE" -o /tmp/promo_voice_check.aiff 'テスト' 2>/dev/null; then
  echo "声「$VOICE」が使えません。使える日本語の声:"; say -v '?' | grep -i ja_JP || true
  echo 'VOICE=<声の名前> を付けて実行し直してください'; exit 1
fi
rm -f /tmp/promo_voice_check.aiff

say_step 'Python（numpy）の準備'
if python3 -c 'import numpy' 2>/dev/null; then
  export PY=python3
else
  [ -x .venv/bin/python ] || python3 -m venv .venv
  .venv/bin/python -m pip install --quiet numpy
  export PY="$PWD/.venv/bin/python"
fi

say_step '字体と Playwright の準備'
[ -d node_modules/@fontsource/noto-sans-jp ] || npm install --no-audit --no-fund
node --input-type=module -e "import { createRequire } from 'node:module'; const r = createRequire(process.cwd() + '/'); try { r('playwright'); } catch { r('playwright-core'); }" 2>/dev/null \
  || npm install --no-audit --no-fund --no-save playwright-core

say_step '声なし動画を8本作る（10分ほど）'
./build.sh

say_step "声（$VOICE）を入れる"
"$PY" mix_voice.py --all --say "$VOICE"

say_step 'できあがり'
ls -lh out/*_final.mp4
open out 2>/dev/null || true
