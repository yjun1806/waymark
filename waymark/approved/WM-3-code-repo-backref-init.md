---
id: WM-3
title: init에서 코드 repo → 문서 repo 역방향 연동 옵션
summary: satellite init이 코드 repo에 "이 repo 이슈는 여기서 관리" 백-레퍼런스를 넣을지 물어보고 세팅 (opt-in)
assignee: yjun1806
target: [waymark]
tracker: []
---

# WM-3 · init에서 코드 repo → 문서 repo 역방향 연동 옵션

## Why

연결이 **단방향**이다. 문서(위성) repo는 `repos:`/`paths:`로 코드 repo를 알지만, **코드 repo는
문서 repo를 모른다.** 그래서 누군가 코드 repo에서 바로 세션을 시작하면(에이전트든 사람이든),
"이 repo의 이슈·계획·결정은 어디서 관리되나?"를 알 길이 없다.

init 때 **"코드 repo에도 문서 repo를 알리는 백-레퍼런스를 넣을까요?"**를 물어보고, 원하면 각
코드 repo에 문서 repo를 가리키는 표식을 심는다. 운영 허브 모델([[WM-2]])의 반대 방향 연결.
인프라/툴링 — planning source 없음.

## How

`skills/waymark-init/SKILL.md`의 satellite 플로우(Step 3~4 부근)에 **opt-in 프롬프트** 추가.
"예"면 각 코드 repo(`paths`의 로컬 체크아웃)에 백-레퍼런스를 설치한다.

**핵심 긴장:** 이건 위성 모드의 "코드 repo를 안 건드린다"를 **의도적으로 완화**하는 동작이라
반드시 물어본다(opt-in).

**형태 = 안 B 확정** (gitignored 로컬 마커/심링크): 코드 repo에 `waymark -> <doc-repo path>`
심링크 또는 `.waymark-satellite` 마커(경로만)를 두고 코드 repo `.gitignore`에 추가. 코드 repo의
tracked 파일은 **안 건드림**, 로컬 편의만.
(반려한 안 A — 코드 repo `CLAUDE.md`에 커밋 노트: 팀 전체가 보지만 **공유 코드 repo의 tracked
파일을 수정**해 그 repo PR이 필요. 지금은 공유 오염을 피해 B로 가고, 팀 공유가 정말 필요하면
후속 이슈로 A 옵션을 검토.)

로컬 전용이라 새 협업자는 이 마커도 없다 → 재-init으로 채운다([[WM-4]]).

**재소싱 금지 준수:** 어느 형태든 이슈 목록을 코드 repo로 **복사하지 않는다** — 문서 repo의
**위치만** 가리킨다(포인터 한 줄).

Step 7 핸드오프에 "코드 repo에서 시작해도 `<doc-repo>`로 안내됨" 한 줄. 되돌리기는
`waymark-remove`가 이 백-레퍼런스도 걷어내도록 연계(별도 task).

## Tasks

- [ ] T1 satellite init에 opt-in 프롬프트 추가
- [ ] T2 선택한 형태(A/B)로 백-레퍼런스 설치 로직
- [ ] T3 안 B라면 코드 repo `.gitignore` 처리
- [ ] T4 Step 7 핸드오프 안내 + waymark-remove 연계
- [ ] T5 WM-2의 허브 모델 절에서 역방향 연결로 링크

## Decisions

- D1 **opt-in 필수** — 코드 repo를 건드리므로. 기본값은 "안 함"(명시 동의 시에만).
- D2 백-레퍼런스는 **포인터만**(문서 repo 위치), 이슈 내용 복제 금지 — reference 원칙.
- D3 **형태 = B (gitignored 로컬 마커/심링크) 확정** — 코드 repo 공유 오염 금지. A(커밋 노트)는
  팀 공유가 필요할 때 후속 이슈로.
- Open Q 코드 repo가 여러 개일 때 각각 물어볼지 일괄 처리할지.
- Open Q `waymark-remove`가 코드 repo 쪽 백-레퍼런스까지 안전하게 제거하는 범위.
