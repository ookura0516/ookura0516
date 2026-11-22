#!/usr/bin/env bash
# 確認用：各場面の 60% の時点の静止画を並べた一覧を out/sheet_<案>_<V|H>.png に作る
set -euo pipefail
cd "$(dirname "$0")"
app=$1; fmt=$2
node render.mjs "$app" "$fmt" --frames 0 >/dev/null
frames=$(python3 -I -c "
import json; tl=json.load(open('out/${app}_${fmt}.timeline.json'))
print(','.join(str(int((s['start']+s['dur']*0.6)*30)) for s in tl['scenes']))")
rm -f out/${app}_${fmt}_f*.png
node render.mjs "$app" "$fmt" --frames "$frames" >/dev/null
python3 -I - "$app" "$fmt" <<'PY'
import glob, sys
from PIL import Image
app, fmt = sys.argv[1:3]
fs = sorted(glob.glob(f'out/{app}_{fmt}_f*.png'))
tw, th = (360, 640) if fmt == 'V' else (640, 360)
cols = 4 if fmt == 'V' else 2
rows = (len(fs) + cols - 1) // cols
W = Image.new('RGB', (cols * (tw + 10), rows * (th + 10)), 'white')
for i, f in enumerate(fs):
    W.paste(Image.open(f).resize((tw, th)), ((i % cols) * (tw + 10), (i // cols) * (th + 10)))
W.save(f'out/sheet_{app}_{fmt}.png')
PY
rm -f out/${app}_${fmt}_f*.png
echo "out/sheet_${app}_${fmt}.png"
