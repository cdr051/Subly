# Subly — 구독 관리 앱

> 넷플릭스·유튜브 프리미엄 등 구독 서비스를 한눈에 관리하고, 취향 분석을 통해 새 구독을 추천하거나 불필요한 구독의 해지를 제안하는 iOS 앱

![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-18.5+-000000?logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-0070C9)
![SwiftData](https://img.shields.io/badge/SwiftData-✓-6E40C9)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 해결하는 문제

- 매달 얼마를 어떤 구독에 쓰는지 모른다
- 안 쓰는 구독을 잊고 계속 결제한다 (구독 누수)
- 결제일·무료체험 종료일을 놓쳐 원치 않는 과금이 발생한다
- 새 서비스를 고를 때 비교 기준이 없다

---

## 주요 기능

### 🏠 대시보드
- 월·연 총지출 한눈에 파악
- 7일 내 결제 예정 목록
- 구독 추가·편집·삭제, 빠른 검색

### 📊 인사이트
- 카테고리별 지출 막대 차트 (Swift Charts)
- 사용 빈도 기반 해지 후보 자동 선별

### ✨ 취향 기반 추천
- 영화·드라마, 음악, 게임 등 10개 관심사 선택
- 현재 구독하지 않는 서비스 중 취향에 맞는 것 추천 (국내외 30여 개 플랫폼 DB)
- 중복 카테고리·낮은 사용 빈도·취향 불일치를 종합한 해지 제안

### 🔔 로컬 알림
- 결제 하루 전 알림
- 무료체험 종료 하루 전 알림

---

## 기술 스택

| 영역 | 선택 |
|------|------|
| 언어 | Swift 5.9+ |
| UI | SwiftUI |
| 영속성 | SwiftData (`@Model`, `@Query`) |
| 차트 | Swift Charts |
| 알림 | UserNotifications |
| 테스트 | Swift Testing |
| 최소 배포 | iOS 18.5 |

---

## 프로젝트 구조

```
Subly/
├── Models/
│   ├── Subscription.swift          # 구독 데이터 모델 + BillingCycle / Category / UsageFrequency enum
│   ├── UserPreference.swift        # 사용자 취향 설정 (SwiftData)
│   └── ServiceDatabase.swift       # 국내외 플랫폼 DB + Interest enum
├── ViewModels/
│   ├── InsightEngine.swift         # 차트 데이터, 해지 후보 로직
│   └── RecommendationEngine.swift  # 취향 매칭, 강화된 해지 제안
├── Views/
│   ├── HomeView.swift              # TabView 루트 + 대시보드
│   ├── AddEditSubscriptionView.swift
│   ├── SubscriptionDetailView.swift
│   ├── InsightsView.swift
│   ├── RecommendationView.swift
│   └── SettingsView.swift
└── Utilities/
    ├── Extensions.swift            # Color(hex:), Date 포맷, Double 변환
    └── NotificationManager.swift
```

---

## 시작하기

### 요구사항
- macOS 14+
- Xcode 16+
- iOS 18.5+ 시뮬레이터 또는 실기기

### 실행

```bash
git clone https://github.com/<your-username>/Subly.git
cd Subly
open Subly.xcodeproj
```

Xcode에서 시뮬레이터를 선택하고 **Cmd+R** 로 빌드·실행합니다.

외부 의존성(CocoaPods, SPM 패키지)이 없으므로 별도 설치 과정이 불필요합니다.

---

## 로드맵

| 단계 | 내용 | 상태 |
|------|------|------|
| MVP | 구독 CRUD, 총액 계산, 로컬 알림, SwiftData 저장 | ✅ 완료 |
| v1.1 | 카테고리 차트, 사용 빈도, 규칙 기반 해지 추천 | ✅ 완료 |
| v1.2 | 취향 선택 UI, 규칙 기반 신규 구독 추천 | ✅ 완료 |
| v1.2+ | Claude API 연동 — 자연어 추천·해지 사유 생성 | 🔲 예정 |
| v2.0 | iCloud 동기화, 홈 위젯, 잠금화면 위젯 | 🔲 예정 |

---

## 기여

이슈와 PR은 언제나 환영합니다.
버그 제보나 기능 제안은 [Issues](../../issues) 탭을 이용해 주세요.

---

## 라이선스

[MIT License](LICENSE)
