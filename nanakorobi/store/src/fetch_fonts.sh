#!/bin/sh
# スクリーンショットの見出しと画面の文字に使う Noto Sans JP（SIL OFL 1.1）を取ってくる。
# アプリ本体には同梱しない。store/src/fonts/ は .gitignore に入れてある。
set -e
dir="$(dirname "$0")/fonts"
mkdir -p "$dir"
curl -sSL -o "$dir/NotoSansJP-Regular.ttf" "https://fonts.gstatic.com/s/notosansjp/v57/-F6jfjtqLzI2JPCgQBnw7HFyzSD-AsregP8VFBEj75s.ttf"
curl -sSL -o "$dir/NotoSansJP-Bold.ttf" "https://fonts.gstatic.com/s/notosansjp/v57/-F6jfjtqLzI2JPCgQBnw7HFyzSD-AsregP8VFPYk75s.ttf"
ls -la "$dir"
