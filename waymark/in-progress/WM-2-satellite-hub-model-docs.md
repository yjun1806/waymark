---
id: WM-2
title: 위성 모드를 "운영 허브" 모델로 문서 설명 개선
summary: 위성 waymark repo = 세션이 시작되는 운영 허브(지구), 코드 repo = 그 위성. 코드/문서 분리를 canonical 문서에 명확히
assignee: yjun1806
target: [waymark]
tracker: []
---

# WM-2 · 위성 모드를 "운영 허브" 모델로 문서 설명 개선

## Why

현재 문서는 위성 모드를 "코드를 참조하는 **별도 문서 저장소**" 정도로만 설명해, 위성이 수동적
부속물처럼 오해될 수 있다. 실제 사용 모델은 정반대다:

- **위성 waymark repo = 세션이 시작되는 운영 허브.** 여기서 에이전트(Claude Code, Codex 등)를
  실행하고, 계획하고, 코딩한다.
- **코드 repo들 = 허브가 읽고 쓰는 대상.** (위성이 "지구"고 코드 저장소가 그 주위를 도는 위성.)
- 즉 **코드 저장소와 문서(이슈 관리) 저장소의 분리** — 문서 repo는 코드 repo를 알고 참조한다.

이 관점을 canonical 문서에 명확히 해, 정방향/역방향 연동([[WM-1]]/[[WM-3]])이 왜 필요한지의
토대를 만든다. 인프라/문서 — planning source 없음.

## How

위성 모델을 서술하는 **한 곳(SSOT)**을 `ARCHITECTURE`(satellite 절)로 잡고, 아래를 개정한다:

1. `ARCHITECTURE.md` / `ARCHITECTURE.ko.md` satellite 절 — "운영 허브" 모델로 개정. 핵심:
   위성에서 에이전트 실행·계획·코딩; 코드 repo는 참조·편집 대상; 코드/문서 저장소 분리.
2. `README.md` / `README.ko.md` 위성 모드 소개 문단 — 같은 프레이밍으로 한두 줄.
3. `skills/waymark-init/SKILL.md` Step 1의 satellite 설명 — "own repo가 references code" →
   "own repo가 **운영 허브**, 코드 repo를 참조·편집" 뉘앙스로.

연동 메커니즘(심링크·백-레퍼런스)은 여기서 **재서술하지 않고 [[WM-1]]/[[WM-3]]를 링크**한다
(reference, don't re-source). 이 절이 모델의 단일 진실 원천.

## Tasks

- [x] T1 ARCHITECTURE satellite 절 개정 (en + ko) — §12 "운영 허브"로, 로컬 배선 노트 추가
- [x] T2 README 위성 모드 문단 개정 (en + ko)
- [x] T3 init Step 1 satellite 설명 개정
- [x] T4 상호 참조 — WM-3이 [[WM-2]] 링크, WM-1은 허브 맥락 포함. SSOT = ARCHITECTURE §12

## Decisions

- D1 satellite 모델의 SSOT = `ARCHITECTURE` satellite 절. 다른 문서·이슈는 여기를 링크만.
- D2 "위성/지구" 비유는 설명 보조로만 — 모드 이름(`satellite`)은 바꾸지 않는다(호환성·범위 최소화).
- Open Q 모드 이름을 언젠가 재고할지(예: `hub`)는 별도 이슈로 — 지금은 설명만 개선.
