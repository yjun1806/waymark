---
id: WM-4
title: init이 세팅 상태를 감지해 새 협업자의 로컬 셋업만 채우기
summary: satellite doc repo를 clone한 새 협업자를 위해 init이 현재 상태(공유/로컬)를 체크하고 빠진 로컬 wiring만 세팅 (join 모드)
assignee: yjun1806
target: [waymark]
tracker: []
---

# WM-4 · init이 세팅 상태를 감지해 새 협업자의 로컬 셋업만 채우기

## Why

satellite 모드는 **공유(tracked)와 로컬(gitignored)이 갈린다**:

- **공유(커밋됨)** — `.waymark.yml`, `waymark/` 상태 폴더, `waymark/rules.md`, CLAUDE.md 임포트
- **로컬 전용(gitignored)** — `.waymark.local.yml`(코드 경로), 코드 심링크([[WM-1]]), 역방향
  마커([[WM-3]]), 그리고 `.git/hooks/*`(clone에 안 옴)

그래서 팀에 **새로 합류한 사람이 doc repo를 clone하면 공유 부분은 오지만 로컬 조각이 전부 비어**
협업이 안 된다(코드 경로 모름, 심링크 없음, 게이트 훅 없음). 이들을 채우려면 init 실행이
필요한데, 처음부터 다시 하는 게 아니라 **현재 상태를 감지해 빠진 로컬만** 채워야 한다.
인프라/툴링 — planning source 없음.

## How

`skills/waymark-init/SKILL.md`에 **상태 감지 게이트**를 앞단(Step 0 직후)에 추가하고 분기한다:

- **공유 셋업 존재**(`waymark/` + `.waymark.yml` 있음) **+ 로컬 미완**(`.waymark.local.yml` 없음
  또는 심링크/훅 없음) → **join 모드**: 공유 스캐폴딩은 **건드리지 않고**(이미 있으면 스킵),
  코드 repo 로컬 경로만 물어 `.waymark.local.yml` 작성 → 심링크([[WM-1]]) → 역방향 마커
  opt-in([[WM-3]]) → 게이트 훅 재설치.
- **아무것도 없음** → 기존 full init(모드 질문부터).
- **전부 있음** → "이미 셋업됨" 보고 후 종료(idempotent).

**update 스킬과의 경계 명시:** `waymark-update` = 플러그인 버전 sync(vendored 훅/rules 갱신,
인덱스 재생성). **WM-4 = 새 사람의 로컬 wiring 채우기.** init이 "공유는 됐고 내 로컬만 빔"을
감지하면 join으로 분기 — 둘의 역할을 문서에 구분해 적는다.

## Tasks

- [ ] T1 init 앞단에 상태 감지(공유/로컬/훅) 로직 추가
- [ ] T2 join 모드 — 공유 스캐폴딩 스킵, 로컬만 세팅
- [ ] T3 게이트 훅 재설치(clone엔 `.git/hooks` 없음)
- [ ] T4 full init과 분기 + idempotent 종료 경로
- [ ] T5 update 스킬과의 경계를 README/스킬 설명에 명시

## Decisions

- D1 init은 **idempotent** — 여러 번 실행해도 안전, 공유 tracked 산출물은 이미 있으면 재작성 금지.
- D2 새 협업자 온보딩의 진입점은 **init 하나** — 로컬 조각([[WM-1]]/[[WM-3]]/local.yml/훅)의 원천은
  init이라는 단일 창구로 모은다.
- Open Q "join"을 init 내부 분기로 둘지, 별도 스킬/명령(`waymark-join`)으로 뺄지 — 우선 init 분기.
- Open Q 훅 재설치가 `waymark-update`와 겹치는 지점의 최종 소유권(누가 정본인지).
