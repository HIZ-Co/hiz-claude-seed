# HIZ 팀 Claude Code 환경 셋업 (Windows / PowerShell)
# claude-home/ 의 팀 표준 설정을 ~/.claude/ 에 설치한다.
# 원칙: 기존 파일은 절대 덮어쓰지 않는다 (인증·개인 설정 보존). 없는 것만 추가.

$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8; chcp 65001 > $null } catch {}
$src = Join-Path $PSScriptRoot 'claude-home'
$dst = Join-Path $env:USERPROFILE '.claude'

if (-not (Test-Path $src)) {
  Write-Host "[오류] claude-home 폴더를 찾을 수 없습니다. repo 루트에서 실행하세요." -ForegroundColor Red
  exit 1
}

New-Item -ItemType Directory -Force -Path $dst | Out-Null
Write-Host ""
Write-Host "HIZ 팀 Claude 환경 설치 시작..." -ForegroundColor Cyan
Write-Host "  대상: $dst (기존 파일 보존)"

# 디렉토리: 없는 파일만 복사. /XC /XN /XO = 변경·신규버전·구버전 모두 제외 → 기존 파일 무조건 보존
foreach ($d in 'skills', 'commands', 'agents', 'rules', 'mcp-configs') {
  $s = Join-Path $src $d
  if (Test-Path $s) {
    robocopy $s (Join-Path $dst $d) /E /XC /XN /XO /NFL /NDL /NJH /NJS /NP | Out-Null
    $cnt = (Get-ChildItem (Join-Path $dst $d) -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host ("  [OK] {0,-12} ({1} files)" -f $d, $cnt) -ForegroundColor Green
  }
}

# settings.json: 기존 설정·권한은 보존하되, 팀 표준 auto mode(defaultMode)가
# 없으면 그것만 주입한다. (로그인이 먼저라 빈 settings.json이 미리 생겨도 auto mode 보장)
$st = Join-Path $dst 'settings.json'
if (-not (Test-Path $st)) {
  Copy-Item (Join-Path $src 'settings.json') $st
  Write-Host "  [OK] settings.json (신규 설치 - auto mode 포함)" -ForegroundColor Green
} else {
  try {
    $cur = Get-Content $st -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($null -eq $cur.permissions) {
      $cur | Add-Member -NotePropertyName permissions -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    if ($null -eq $cur.permissions.defaultMode) {
      $cur.permissions | Add-Member -NotePropertyName defaultMode -NotePropertyValue 'acceptEdits' -Force
      $json = $cur | ConvertTo-Json -Depth 30
      [System.IO.File]::WriteAllText($st, $json, (New-Object System.Text.UTF8Encoding $false))
      Write-Host "  [수정] settings.json 기존 보존 + auto mode(defaultMode) 주입" -ForegroundColor Green
    } else {
      Write-Host "  [보존] settings.json 이미 있음 (auto mode 설정됨)" -ForegroundColor Yellow
    }
  } catch {
    Write-Host "  [경고] settings.json 파싱 실패 - 수동 확인 필요: $st" -ForegroundColor Red
  }
}

Write-Host ""
Write-Host "설치 완료. Claude Code가 곧 켜집니다." -ForegroundColor Cyan
Write-Host "참고: gstack 계열 스킬(browse/qa/ship 등)은 gstack 별도 설치 후 작동합니다." -ForegroundColor DarkGray
Write-Host ""
