#!/usr/bin/env bash
# 将根目录 VERSION 文件中的版本号同步到 Cargo.toml、pubspec.yaml、package.json。
# 用法: ./scripts/set-version.sh [版本号]
# 若省略版本号，则使用 VERSION 文件内容。

set -e
cd "$(dirname "$0")/.."

if [ -n "$1" ]; then
  VER="$1"
  echo "$VER" > VERSION
else
  VER=$(cat VERSION | tr -d '[:space:]')
fi

if [ -z "$VER" ]; then
  echo "Usage: $0 [version]" >&2
  echo "  If version is omitted, reads from VERSION file." >&2
  exit 1
fi

echo "Setting version to: $VER"

# Cargo.toml：只改 [workspace.package].version 与以 ratex- 开头的依赖行中的 version，不改 phf/serde 等
sed -e '/^[[:space:]]*version = "/s/version = "[^"]*"/version = "'"$VER"'"/' \
    -e '/^ratex-/s/version = "[^"]*"/version = "'"$VER"'"/g' \
    Cargo.toml > Cargo.toml.tmp && mv Cargo.toml.tmp Cargo.toml

# Flutter pubspec
sed "s/^version: .*/version: $VER/" platforms/flutter/pubspec.yaml > platforms/flutter/pubspec.yaml.tmp && mv platforms/flutter/pubspec.yaml.tmp platforms/flutter/pubspec.yaml

# npm package (ratex-wasm)
node -e "
const fs = require('fs');
const p = 'platforms/web/package.json';
const j = JSON.parse(fs.readFileSync(p, 'utf8'));
j.version = '$VER';
fs.writeFileSync(p, JSON.stringify(j, null, 2) + '\n');
"

node -e "
const fs = require('fs');
const p = 'platforms/react-native/package.json';
const j = JSON.parse(fs.readFileSync(p, 'utf8'));
j.version = '$VER';
fs.writeFileSync(p, JSON.stringify(j, null, 2) + '\n');
"

echo "Done. Updated: Cargo.toml, platforms/flutter/pubspec.yaml, platforms/web/package.json"
