---
id: WM-1
title: 위성 모드 init에서 코드 repo 심링크 자동 생성
summary: satellite init이 .waymark.local.yml의 각 코드경로를 위성 루트 심링크로 걸고 gitignore
assignee: yjun1806
target: [waymark]
tracker: []
---

# WM-1 · 위성 모드 init에서 코드 repo 심링크 자동 생성

## Why

위성 repo는 사실상 **세션이 시작되는 운영 허브**다 — 에이전트는 위성에서 살고, 코드 repo들을
읽고 쓴다. (비유하자면 위성이 "지구"고, 코드 저장소들이 그 주위를 도는 위성인 셈.) 그래서
허브에서 코드가 **보여야** 개발이 된다.

그런데 코드는 **다른 repo/경로**에 살고, 그 로컬 경로는 `.waymark.local.yml`의 `paths.<alias>`에만
기록된다. 그래서 에이전트는 위성 트리 안에서 코드를 **상대경로로 읽을 수 없다** — grep·참조·
`file:line` 인용이 위성 밖 절대경로로 새거나 아예 안 잡힌다.

`muxa-waymark`에서 손으로 `muxa -> /Users/yj/Documents/private/muxa` 심링크를 위성 루트에 걸고
`.gitignore`에 `/muxa`를 넣어봤더니, `./muxa/src/...`처럼 **위성 안에서 코드가 navigable**해졌다.
tracked 위성은 안 더럽히고(gitignore) 로컬 편의만 얻는다. 이 패턴을 init이 자동으로 하게 한다.
인프라/툴링 변경 — planning source 없음.

## How

`skills/waymark-init/SKILL.md`의 **Step 4 (satellite only)**를 확장한다. `.waymark.local.yml`을
쓰고 `.waymark.local.yml`을 gitignore한 뒤, `paths`의 각 `<alias> → <local checkout path>`에 대해:

1. 위성 루트에 심링크 생성: `ln -s <local checkout path> <alias>`
2. `.gitignore`에 `/<alias>` 한 줄 추가 (코드는 자체 repo → 심링크는 **로컬 전용, 추적 금지**)

가드(엣지 케이스):
- **충돌** — `<alias>`가 기존 파일/폴더나 `waymark/`·`.git`과 겹치면 만들지 말고 경고. (init은
  대화형이니 사용자에게 알린다.)
- **경로 부재** — `<local checkout path>`가 없으면 dangling 심링크가 되므로, 걸기 전 존재 확인.
- **Windows** — 심링크가 권한을 요구할 수 있음. gitignored라 로컬 편의일 뿐이니, 실패 시 조용히
  건너뛰고 "코드는 절대경로로 참조"로 폴백(에러 아님).

Step 7 핸드오프에도 "위성에서 `./<alias>/`로 코드 열람 가능" 한 줄 추가.
`.gitignore` 주석은 repo `lang`에 맞춰 작성.

## Tasks

- [ ] T1 Step 4에 심링크 생성 + `/<alias>` gitignore 문구 추가
- [ ] T2 충돌·경로부재·Windows 폴백 가드 문구
- [ ] T3 Step 7 핸드오프에 `./<alias>` 안내 추가
- [ ] T4 (선택) ARCHITECTURE의 satellite 절에 심링크 근거 한 줄

## Decisions

- D1 심링크는 **gitignore(로컬 전용)** — 코드는 자체 repo라 tracked 위성 오염 금지. `.waymark.local.yml`과 같은 로컬 계층. `muxa-waymark`에서 실증.
- D2 별도 설정 안 만든다 — 심링크 대상은 `.waymark.local.yml`의 `paths`와 **1:1**, 단일 진실 원천 유지.
- D3 심링크는 **루트에** 둔다(숨은 경로 아님). 근거: 위성 = 운영 허브라 코드가 보이는 게 존재 이유. "검색 폭발" 우려는 (a) 코드 열람이 목적이고 (b) index 훅은 `waymark/<status>/`만 읽어 심링크를 안 타므로 실질 문제 아님. 문서만 검색할 땐 범위를 `waymark/`로 좁힘(rules 메모로 안내).
- D4 "코드 불가침"은 **waymark 부기 파일을 코드 repo에 안 심는다**는 뜻이지 코드 편집 금지가 아님 — 심링크는 이 불변식과 무관(양쪽 다 waymark 파일로 안 더럽힘).
- D5 심링크는 gitignored 로컬 전용 → 새 협업자에겐 없다. 재-init이 채운다([[WM-4]]).
- Open Q Windows 심링크 폴백을 "건너뛰기"로 둘지, junction/복사 등 대안을 둘지 — 우선 건너뛰기.
