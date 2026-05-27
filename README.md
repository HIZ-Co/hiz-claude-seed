# hiz-claude-seed

HIZ 마케팅 에이전시 **팀 표준 Claude Code 환경** seed.
부트캠프(AI ON) 멤버가 한 줄로 본인 PC에 팀 공통 스킬·커맨드·에이전트·규칙을 설치한다.

## 설치 (한 줄)

> 전제: VS Code + Claude Code(CLI) + Git 설치 완료. (설치 가이드는 부트캠프 안내 페이지 참조)

**Mac**
```bash
git clone https://github.com/HIZ-Co/hiz-claude-seed.git ~/HIZ && cd ~/HIZ && bash setup.sh && claude
```

**Windows (PowerShell)**
```powershell
git clone https://github.com/HIZ-Co/hiz-claude-seed.git $HOME\HIZ; cd $HOME\HIZ; .\setup.ps1; claude
```

## 무엇이 설치되나

`claude-home/` 의 내용을 `~/.claude/` 에 복사한다.

| 항목 | 내용 |
|------|------|
| skills (59) | 문서(pdf·docx·xlsx·pptx·make-pdf) · 코딩 참조 · 기획/리뷰 등 |
| commands (13) | `/이어서저장` `/이어서불러오기` `/리서치` `/박제` `/사용진단` `/plan` `/code-review` 등 |
| agents (9) | architect · planner · code-reviewer · security-reviewer · tdd-guide 등 |
| rules | common · python 코딩 규칙 |
| settings.json | 팀 기본값 (없을 때만 설치 — 기존 설정 보존) |
| mcp-configs | 무료 MCP 6종 (github · memory · sequential-thinking · context7 · filesystem · playwright) |

## 설계 원칙

- **기존 파일 보존**: setup 스크립트는 `~/.claude` 의 기존 파일을 **절대 덮어쓰지 않는다.** 인증(`.credentials.json`)·개인 `settings.json`·메모리는 그대로 유지되고, 없는 항목만 추가된다. 재실행해도 안전(idempotent).
- **비밀정보 0**: 이 repo는 PUBLIC이다. 인증 토큰·세션 로그·고객 데이터는 들어있지 않다. MCP 설정의 토큰 자리는 모두 `YOUR_..._HERE` 플레이스홀더이며 본인 값으로 교체한다.
- **유료 MCP 제외**: firecrawl · exa · browserbase · apify 등은 day-1 셋업에서 제외. 5/29부터 본인 필요 시 추가.
- **gstack 제외**: gstack은 1.2GB 별도 런타임이라 seed에 포함하지 않는다. `browse`·`qa`·`ship` 등 gstack 계열 스킬 stub은 포함되지만, 작동하려면 [gstack](https://github.com/gstack)을 따로 설치해야 한다.

## 막히면

`#ai-bootcamp-1조` 슬랙 채널에 OS 버전 + 에러 화면 캡쳐.
