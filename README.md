# Docat

**진실(원천)이 이미 다른 곳에 있는 팀을 위한 스펙 주도 개발.**
*기념비 말고 이정표를 남겨라 (Leave a marker, not a monument).*

Docat은 **프레임워크가 아니라 규약(convention)**이다. 대부분의 SDD 도구는 repo를
세상의 중심으로 두고 기획·계약·작업을 6~7개 마크다운으로 **복제**하지만, 팀엔 이미
기획은 Confluence/노션에, 계약은 코드에, 진척은 트래커에 있다. Docat은 **이슈당 얇은
문서 1개**만 두어 *어떻게(how)* 와 *결정*만 소유하고, 나머지는 복제 대신 **참조**하며,
상태는 **폴더가 소유**하고(`draft → approved → in-progress → done`), done되면 **동결**한다.

## 설치

Docat은 **Claude Code 플러그인**이다. **Claude Code 세션**(터미널 또는 IDE) 안에서
아래 슬래시 명령을 입력한다:

```
/plugin marketplace add yjun1806/docat
/plugin install docat@docat
```

설치하면 `docat-init` 스킬과 `/work-new` 명령이 활성화된다.
사전 준비: Claude Code · git · python3. (repo가 Private면 `marketplace add` 시 git
접근 권한 필요 — 팀 내부 배포는 권한 있는 사람만 설치 가능.)

## 빠른 시작

1. **`docat init`** (또는 "docat 세팅해줘") — 모드 선택(satellite/embedded) · `docat/`
   폴더 · `.docat.yml` · git 게이트 설치.
2. **`/work-new`** — 새 이슈 문서 생성 (`docat/draft/`).
3. **상태 이동은 자동** — Claude가 작업 상황을 판단해 `git mv`로 옮긴다
   (`draft → approved → in-progress → done`). 이동이 곧 상태 변경이자 감사 로그.
   사람 게이트(설계 승인·최종 done)만 확인받고, 나머지는 규칙(CLAUDE.md)대로 자동.

커밋 시 게이트(`docat-check`)가 id 유일성·필수 필드·헤딩을 검증하고,
인덱스(`docat/<status>/index.md`)가 자동 생성된다.

## 배포 모드 (satellite / embedded)

Docat 데이터(`docat/` 폴더 + `.docat.yml`)를 어디 두느냐. **`docat init`이 셋업 때 물어본다.**

- **satellite** (기본) — Docat을 **독립 repo**에 두고, 관리 대상 코드 repo들을
  `.docat.yml`의 `repos:`로 **참조**한다(코드 repo는 안 건드림). 솔로·멀티레포·팀
  미도입 상황에 적합.
- **embedded** — 코드 repo **안에** `docat/`를 둔다(docs-with-code). `repos:` 불필요.
  단일 repo에서 코드+문서를 같은 PR로 버전관리하고 싶을 때.

두 모드 모두 구조는 동일 — 루트에 `docat/<status>/`. 자세히는 [DESIGN.md](./DESIGN.md) §12.

**설정 파일** (`docat init`이 생성):
- `.docat.yml` — `lang` · `repos`(satellite) · `assignees` 로스터. **git 공유**.
- `.docat.local.yml` — 로컬 체크아웃 경로(기기별). **gitignore**.

```yaml
# .docat.yml 예시 (satellite)
lang: ko
repos:
  backend: { remote: github.com/myteam/backend }
assignees:
  younjun-kim: YJ          # github-id → prefix (트래커 없을 때 id 발급)
```

## 핵심 3원칙

1. **참조하되 복제하지 않는다** — 진실은 원천 한 곳에 두고 링크로 참조. 필요하면
   **날짜 박힌 비권위 발췌**(맥락·복원력)는 두되, *유지되는 사본 = 두 번째 진실 원천*은
   만들지 않는다. 금지되는 건 권위의 복제이지 모든 전사(轉寫)가 아니다.
2. **HOW만 소유한다** — 구현 의도·결정만. 기획·계약은 원천에 위임.
3. **권위를 시한부로 둔다** — 상태 폴더에 있는 동안 live, `done`에서 동결.

## 무엇이 아닌가

- **프레임워크 아님** — 얇은 규약 + 강제 훅 + 스킬.
- **트래커 대체 아님** — Jira/Linear를 **보완**(더 미세한 실행 상태). 미러 금지.
- **vs OpenSpec** — OpenSpec은 유지비를 내고 읽을 수 있는 현재상태 spec을 얻고, Docat은
  그 spec을 포기해 드리프트를 없앤다. **트레이드오프.** → [DESIGN.md](./DESIGN.md) §0.

## 규모

개인 → 팀 → 엔터(개발조직 한정)까지. **git처럼 페더레이션**으로 확장한다 — 팀마다
작은 인스턴스이지, 조직 전체 단일 시스템이 아니다. → [DESIGN.md](./DESIGN.md) §11.

## 구조

```
docat/{draft,approved,in-progress,done}/   이슈 문서(폴더=상태) + 자동생성 index.md
.docat.yml                                  팀 설정 (lang · repos · assignees)
```

플러그인 구성: `commands/`(슬래시 명령) · `skills/`(`docat-init`·`docat-remove`) ·
`hooks/`(강제력) · `templates/`(`work.template`·`docat-rules`).

## 언어

생성 문서(title·summary·본문)는 **팀 주언어**(`.docat.yml`의 `lang`)로 — 영어권은 영어,
한국 팀은 한글. **파일명 slug는 항상 ASCII**(크로스-OS git 안전).

## 로드맵

- [x] **v0.1** — 규약 · `/work-new` · **ambient 규칙**(자동 이동) · 게이트(`docat-index`/`docat-check`) · `docat-init`·`docat-remove` 스킬
- [ ] **v0.2** — 링크 liveness · 코드심볼 resolve · contract 테스트 · index merge-driver · CI 워크플로우

## 문서

- [MANIFESTO.md](./MANIFESTO.md) — 철학
- [DESIGN.md](./DESIGN.md) — 구체 설계 결정

## 이름

**Docat** ← *docket*. 법정 "docket"은 전체 사건파일을 **참조**하며 처리할 항목을
**순서대로** 적고 각 **상태를 추적**하는 간결한 등록부다 — Docat이 하는 일과 정확히
겹친다(기획 참조 + how·순서 + 폴더=상태). 거기에 *doc + cat* 의 위트를 얹었다. 🐱

## 라이선스

MIT — [LICENSE](./LICENSE). © 2026 Youngjun Kim.
