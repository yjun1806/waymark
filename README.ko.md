# Waymark

[English](./README.md) · **한국어**

**진실(원천)이 이미 다른 곳에 있는 팀을 위한 스펙 주도 개발.**

## 왜 Waymark?

기획은 대개 이미 어딘가 적혀 있다. Confluence든 노션이든 PDF든. 그걸 기반으로 설계하고
개발한다. Spec Kit 계열 SDD를 여기에 얹으면 처음에 spec·plan·tasks를 한 번 세팅하는
것까진 좋은데, 문제는 그다음이다. 기획이 바뀌고, "이 부분 수정해주세요"가 들어오고,
개발하다 "이렇게 하면 안 되겠는데"가 나온다. 그때마다 사람이 문서 여러 개에 손으로
반영해야 한다.

그렇게 문서는 비대해지고 어느 순간 plan과 task의 경계가 뭉개진다. 문서 구조를 지키라고
스킬과 프롬프트를 걸어놔도, 에이전트가 제때 호출하지 않으면 그만이다. 결과는 드리프트다.
문서끼리 서로 다른 얘기를 하고 레거시 정보가 남는다. 정리하려고 AI를 또 돌리면 토큰이
샌다. 그리고 그렇게 공들여 git으로 공유한 문서도 오래되면 아무도 안 읽는다. 현실과
다르다는 걸 알기 때문이다.

Waymark은 이 경험에서 거꾸로 뽑아낸 결론들이다. 프레임워크가 아니라 얇은
**규약(convention)**이다.

- **복제하지 않고 참조한다.** 기획은 Confluence에, 계약은 코드에, 진척은 트래커에 이미
  있다. 사본을 안 만들면 반영할 노동도 없고 낡을 사본도 없다(**권위 드리프트 0** — 내용
  드리프트는 훅/CI 게이트로 최소화). 맥락용 발췌는 날짜를 박아 **한 번만** 쓰고 갱신하지
  않는다. 기획이 바뀌면 사본을 동기화하는 게 아니라 다음 착수 때 원천에서 **다시
  가져오고**(re-fetch), 중대 변경이면 문서를 `approved`로 되돌려 재승인한다.
- **이슈 1개 = 얇은 문서 1개.** 문서는 *어떻게(how)* 와 *결정*만 소유한다. spec/plan/task로
  쪼개지 않으니 뭉개질 경계 자체가 없다.
- **상태는 폴더가 소유한다.** `draft → approved → in-progress → done` — 파일이 있는
  폴더가 곧 상태다. `done`이면 **동결**한다. 어차피 안 읽을 낡은 문서에 "현재"를 맡기지
  않는다는 뜻이다. 현재 상태가 필요하면 유지하는 대신 파생한다(ARCHITECTURE §7).
- **믿을 건 코드로 강제한 것뿐.** 스킬이 제때 안 불리는 걸 겪어봤으니, 지킬 규칙은
  프롬프트가 아니라 훅과 게이트에 넣었다. 오늘 코드로 막는 건 id 유일성·필수
  frontmatter·헤딩·`done` 동결이고, 폴더 이동 판단 같은 건 아직 규율의 영역이다.

기획 문서 없이 "이런 기능이 필요한데" 같은 구두 논의에서 출발할 수도 있다. 외부 원천이
없으면 Waymark 문서가 그 시점의 SSOT 역할을 한다(ARCHITECTURE §0). 다만 아무것도 안 적힌
greenfield에서 읽을 수 있는 현재상태 spec을 계속 유지하고 싶다면, 그건
Spec Kit·OpenSpec이 맞다.

## 설치

Waymark은 **Claude Code 플러그인**이다. **Claude Code 세션**(터미널 또는 IDE) 안에서
아래 슬래시 명령을 입력한다:

```
/plugin marketplace add yjun1806/waymark
/plugin install waymark@waymark
```

설치하면 `waymark-init` 스킬과 `/work-new` 명령이 활성화된다.
사전 준비: Claude Code · git · python3. (repo가 Private면 `marketplace add` 시 git
접근 권한 필요 — 팀 내부 배포는 권한 있는 사람만 설치 가능.)

## 빠른 시작

1. **`waymark init`** (또는 "Waymark 세팅해줘") — 모드 선택(satellite/embedded) · `waymark/`
   폴더 · `.waymark.yml` · git 게이트 설치.
2. **`/work-new`** — 새 이슈 문서 생성 (`waymark/draft/`).
3. **상태 이동은 자동** — Claude가 작업 상황을 판단해 `git mv`로 옮긴다
   (`draft → approved → in-progress → done`). 이동이 곧 상태 변경이자 감사 로그.
   사람 게이트(설계 승인·최종 done)만 확인받고, 나머지는 규칙(CLAUDE.md)대로 자동.

커밋 시 게이트(`waymark-check`)가 id 유일성·필수 필드·헤딩을 검증하고,
인덱스(`waymark/<status>/index.md`)가 자동 생성된다.

## 배포 모드 (satellite / embedded)

Waymark 데이터(`waymark/` 폴더 + `.waymark.yml`)를 어디 두느냐. **`waymark init`이 셋업 때 물어본다.**

- **satellite** (기본) — Waymark을 **독립 repo**에 두고, 관리 대상 코드 repo들을
  `.waymark.yml`의 `repos:`로 **참조**한다(코드 repo는 안 건드림). 솔로·멀티레포·팀
  미도입 상황에 적합.
- **embedded** — 코드 repo **안에** `waymark/`를 둔다(docs-with-code). `repos:` 불필요.
  단일 repo에서 코드+문서를 같은 PR로 버전관리하고 싶을 때.

두 모드 모두 구조는 동일 — 루트에 `waymark/<status>/`. 자세히는 [ARCHITECTURE.ko.md](./ARCHITECTURE.ko.md) §12.

**설정 파일** (`waymark init`이 생성):
- `.waymark.yml` — `lang` · `repos`(satellite) · `assignees` 로스터. **git 공유**.
- `.waymark.local.yml` — 로컬 체크아웃 경로(기기별). **gitignore**.

```yaml
# .waymark.yml 예시 (satellite)
lang: ko
repos:
  backend: { remote: github.com/myteam/backend }
assignees:
  younjun-kim: YJ          # github-id → prefix (트래커 없을 때 id 발급)
```

## 핵심 3원칙

위 결론들의 정식 이름 — 설계 근거는 [ARCHITECTURE.ko.md](./ARCHITECTURE.ko.md).

1. **참조하되 복제하지 않는다** — 유지되는 사본 금지. 발췌는 write-once, 갱신 대신 착수 시 re-fetch.
2. **HOW만 소유한다** — 구현 의도·결정만. 기획·계약·진척은 원천에 위임.
3. **권위를 시한부로 둔다** — 상태 폴더에 있는 동안 live, `done`에서 동결.

## 무엇이 아닌가

- **프레임워크 아님** — 얇은 규약 + 강제 훅 + 스킬.
- **품질·방법론 도구 아님** — 문서를 *어떻게 잘 쓰는지*(품질·정합성), 설계·구현을 *어떻게
  하는지*(방법론)는 **안 건드린다.** 그건 전용 스킬(리뷰·TDD·설계·문서작성)의 몫. Waymark이
  소유하는 건 **작업 단위(이슈=문서 1개)의 관리 규약과 상태**뿐 — 어디 살고, 지금 무슨
  상태이고, 언제 얼리나. 훅이 강제하는 것도 *구조*(id·헤딩·상태·동결)이지 *내용의 좋고
  나쁨*이 아니다.
- **트래커 대체 아님** — Jira/Linear를 **보완**(더 미세한 실행 상태). 미러 금지.
- **vs OpenSpec** — OpenSpec은 유지비를 내고 읽을 수 있는 현재상태 spec을 얻고, Waymark은
  그 spec을 포기해 드리프트를 없앤다. **트레이드오프.** → [ARCHITECTURE.ko.md](./ARCHITECTURE.ko.md) §0.

## 다른 방식들과 비교

전부 정당한 방식이고 각자 **진짜 강점**이 있다. 뭐가 더 낫다기보다, **무엇을 포기하고 무엇을
얻느냐**가 다를 뿐이다.

| 방식 | 진짜 강점 | 그게 빛나는 곳 |
|---|---|---|
| **Spec Kit** | 도구중립 표준 · 코드 전 팀 정렬 · 성숙한 생태계 | greenfield, 큰 팀의 사전 합의 |
| **OpenSpec** | 읽을 수 있는 현재상태 spec · 자기완결 · 단순 | 외부 SSOT 없음, in-repo spec을 원함 |
| **BMAD** | 페르소나 팀 시뮬레이션 · 촘촘한 감사추적 | 복잡·규제·greenfield |
| **Jira / Linear** | 조직 전체 · 비개발자 접근 · 성숙 | 프로젝트 관리의 원천 (**Waymark이 보완**) |
| **Waymark** | 권위 복제 안 함(권위 드리프트 0) · 트래커 보완 · git-native | **기획이 이미 밖(Confluence)**, 계약이 코드에 |

Waymark이 채우는 틈은 *"진실이 이미 다른 곳에 있는데 그걸 또 복제하기는 싫은"* 경우다. 그 전제가
없다면 — greenfield거나, 읽을 수 있는 in-repo spec을 원한다면 — **Spec Kit·OpenSpec이 더 맞고,
우리도 그렇게 권한다.** 자세한 비교는 [ARCHITECTURE.ko.md](./ARCHITECTURE.ko.md) §0.

## 규모

개인 → 팀 → 엔터(개발조직 한정)까지. **git처럼 분산(distributed)**으로 확장한다 — 팀마다
독립 인스턴스이지, 조직 전체 단일 시스템이 아니다. (인스턴스 간 동기화 프로토콜은 없다 —
각자 독립.) → [ARCHITECTURE.ko.md](./ARCHITECTURE.ko.md) §11.

## 구조

```
waymark/{draft,approved,in-progress,done}/   이슈 문서(폴더=상태) + 자동생성 index.md
.waymark.yml                                  팀 설정 (lang · repos · assignees)
```

플러그인 구성: `commands/`(슬래시 명령) · `skills/`(`waymark-init`·`waymark-remove`) ·
`hooks/`(강제력) · `templates/`(`work.template`·`waymark-rules`).

## 언어

생성 문서(title·summary·본문)는 **팀 주언어**(`.waymark.yml`의 `lang`)로 — 영어권은 영어,
한국 팀은 한글. **파일명 slug는 항상 ASCII**(크로스-OS git 안전).

## 더 읽기

- [ARCHITECTURE.ko.md](./ARCHITECTURE.ko.md) — 포지셔닝(vs OpenSpec)·폴더 모델·id/스키마·배포 모드·강제력 등 설계 결정 전부.

## 이름

**Waymark** — 등산로에 **얇게** 쌓아 다음 갈림길을 가리키는 돌탑·표식(cairn)에서 왔다.
거창한 기념물이 아니라 **길을 잇는 최소한의 흔적**이라는 점이 이 도구가 하는 일과 정확히
겹친다. `way`(경로·워크플로우) + `mark`(git이 커밋을 찍듯 이슈를 찍어 표시)의 결합이기도 하다.

## 라이선스

MIT — [LICENSE](./LICENSE). © 2026 Youngjun Kim.
