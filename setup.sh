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

# settings.json: 기존 설정·권한은 보존하되, 팀 표준 auto mode(defaultMode)가
# 없으면 그것만 주입한다. (로그인이 먼저라 빈 settings.json이 미리 생겨도 auto mode 보장)
if [ ! -f "$DST/settings.json" ]; then
  cp "$SRC/settings.json" "$DST/settings.json"
  echo "  [OK] settings.json (신규 설치 - auto mode + 플러그인 포함)"
elif command -v python3 >/dev/null 2>&1; then
  python3 - "$DST/settings.json" "$SRC/settings.json" <<'PY'
import json, sys
dst, src = sys.argv[1], sys.argv[2]
try:
    with open(dst, encoding='utf-8') as f:
        cfg = json.load(f)
except Exception:
    print(f"  [경고] settings.json 파싱 실패 - 수동 확인 필요: {dst}")
    sys.exit(0)
try:
    with open(src, encoding='utf-8') as f:
        seed = json.load(f)
except Exception:
    seed = {}
changed = []
perm = cfg.get('permissions')
if not isinstance(perm, dict):
    perm = {}; cfg['permissions'] = perm
if 'defaultMode' not in perm:
    perm['defaultMode'] = 'acceptEdits'; changed.append('auto mode')
# 플러그인·마켓플레이스: 기존 키는 절대 건드리지 않고 없는 것만 추가
ep = cfg.get('enabledPlugins')
if not isinstance(ep, dict):
    ep = {}; cfg['enabledPlugins'] = ep
for k, v in seed.get('enabledPlugins', {}).items():
    if k not in ep:
        ep[k] = v; changed.append(k.split('@')[0])
mk = cfg.get('extraKnownMarketplaces')
if not isinstance(mk, dict):
    mk = {}; cfg['extraKnownMarketplaces'] = mk
for k, v in seed.get('extraKnownMarketplaces', {}).items():
    if k not in mk:
        mk[k] = v
if changed:
    with open(dst, 'w', encoding='utf-8') as f:
        json.dump(cfg, f, ensure_ascii=False, indent=2)
    print("  [수정] settings.json 기존 보존 + 추가: " + ", ".join(changed))
else:
    print("  [보존] settings.json 이미 최신 (auto mode + 플러그인 설정됨)")
PY
else
  echo "  [보존] settings.json 이미 있음 - python3 없어 자동 주입 불가"
  echo "         수동으로 permissions 안에 \"defaultMode\": \"acceptEdits\" 추가하세요."
fi

echo ""
echo "설치 완료. Claude Code가 곧 켜집니다."
echo "참고: gstack 계열 스킬(browse/qa/ship 등)은 gstack 별도 설치 후 작동합니다."
echo ""
