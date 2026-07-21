# Docat

**진실(원천)이 이미 다른 곳에 있는 팀을 위한 스펙 주도 개발.**
*기념비 말고 이정표를 남겨라 (Leave a marker, not a monument).*

대부분의 SDD 도구는 repo를 세상의 중심으로 가정하고, 기획·계약·작업을
기능마다 마크다운 6~7개로 **복제**한다. 하지만 팀에 이미 기획은
Confluence/노션에, 데이터 계약은 코드에, 진척은 이슈트래커에 있다면 —
그 사본들은 그저 **드리프트 부채**가 될 뿐이다.

Docat은 **이슈당 얇은 문서 1개**만 두어 *어떻게(how)* 와 *결정* 만 소유하고,
나머지는 복제 대신 **참조(link)** 한다. 상태는 **폴더가 소유**하고
(`draft → approved → in-progress → done`), 완료되면 **동결**한다. 자세한 철학은
[MANIFESTO.md](./MANIFESTO.md), 설계는 [DESIGN.md](./DESIGN.md) 참고.

## 상태 — v0.1 (작업 중)

Claude Code 플러그인 + 도구중립 매니페스토 형태로 패키징.

- [x] `MANIFESTO.md` — 철학 (도구중립)
- [x] `DESIGN.md` — 구체 설계 결정
- [x] `templates/work.template.md` — 이슈당 문서 1개
- [x] `commands/` — `/work-new` · `/work-move` (슬래시 커맨드)
- [ ] 훅 — `ref-integrity-gate`(id 유일성) · `index-autogen`
- [ ] 스킬 — 필요 시 `SKILL.md`

## 구조

```
.docat.yml                 팀 설정 (lang · assignees 로스터)
.claude-plugin/plugin.json   플러그인 manifest
commands/                    슬래시 명령 (.toml)
skills/                      SKILL.md 패키지
hooks/                       hooks.json + 스크립트 (강제력)
templates/work.template.md   이슈마다 이걸 복사
docat/{draft,approved,in-progress,done}/   이슈 문서(폴더=상태) + 자동생성 index.md
examples/                    예시
MANIFESTO.md · DESIGN.md     철학 · 설계
```

## 핵심 아이디어 (3원칙)

1. **참조하되 복제하지 않는다** — 이미 권위 있는 곳에 있는 진실은 링크만, 복사 금지.
2. **HOW만 소유한다** — 문서는 구현 의도·결정만 담고, 나머지(기획·계약)는 원천에 위임.
3. **권위를 시한부로 둔다** — 상태 폴더(`draft → … → done`)에 있는 동안 live,
   `done`으로 이동하면 동결.

## 언어

생성 문서(title·summary·본문)는 **팀 주언어**(`.docat.yml`의 `lang`)로 만든다 —
영어권은 영어, 한국 팀은 한글. 단 **파일명 slug는 항상 ASCII**(크로스-OS git 안전).

## 라이선스

MIT — [LICENSE](./LICENSE) 참고.
