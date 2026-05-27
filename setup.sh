#!/usr/bin/env bash
# HIZ 팀 Claude Code 환경 셋업 (Mac / Linux)
# claude-home/ 의 팀 표준 설정을 ~/.claude/ 에 설치한다.
# 원칙: 기존 파일은 절대 덮어쓰지 않는다 (인증·개인 설정 보존). 없는 것만 추가.

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/claude-home"
DST="$HOME/.claude"

if [ ! -d "$SRC" ]; then
  echo "[오류] claude-home 폴더를 찾을 수 없습니다. repo 루트에서 실행하세요."
  exit 1
fi

mkdir -p "$DST"
echo ""
echo "HIZ 팀 Claude 환경 설치 시작..."
echo "  대상: $DST (기존 파일 보존)"

# 디렉토리: cp -Rn = recursive + no-clobber. 기존 파일 무조건 보존, 없는 것만 추가
for d in skills commands agents rules mcp-configs; do
  if [ -d "$SRC/$d" ]; then
    mkdir -p "$DST/$d"
    cp -Rn "$SRC/$d/." "$DST/$d/" 2>/dev/null || true
    cnt=$(find "$DST/$d" -type f | wc -l | tr -d ' ')
    echo "  [OK] $d ($cnt files)"
  fi
done

# settings.json: 없을 때만 복사 (기존 설정·권한 보존)
if [ ! -f "$DST/settings.json" ]; then
  cp "$SRC/settings.json" "$DST/settings.json"
  echo "  [OK] settings.json (신규 설치)"
else
  echo "  [보존] settings.json 이미 있음 - 덮어쓰지 않음"
fi

echo ""
echo "설치 완료. Claude Code가 곧 켜집니다."
echo "참고: gstack 계열 스킬(browse/qa/ship 등)은 gstack 별도 설치 후 작동합니다."
echo ""
