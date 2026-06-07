# Subly — 구독 관리 앱

## 기술 스택
- 언어: Swift (Xcode 16.4, iOS 18.5+)
- UI: SwiftUI (선언형)
- 저장: SwiftData (`@Model`, `@Query`)
- 알림: UserNotifications (로컬 알림)
- 차트: Swift Charts (`BarMark`, `SectorMark`)
- 테스트: Swift Testing (`@Test`, `#expect`)

## 폴더 구조
```
Subly/
├── SublyApp.swift          ← 진입점, modelContainer 설정
├── Models/
│   └── Subscription.swift  ← @Model 클래스 + BillingCycle/SubscriptionCategory/UsageFrequency enum
├── ViewModels/
│   └── InsightEngine.swift ← 규칙 기반 해지 추천 로직 (순수 struct)
├── Utilities/
│   ├── Extensions.swift    ← Color(hex:), Date 포맷, Double.priceInputString
│   └── NotificationManager.swift ← 로컬 알림 스케줄링
└── Views/
    ├── HomeView.swift          ← TabView 루트 + DashboardView + 카드 컴포넌트
    ├── AddEditSubscriptionView.swift ← 구독 추가/편집 폼 (Sheet)
    ├── SubscriptionDetailView.swift  ← 상세 보기 (@Bindable)
    ├── InsightsView.swift      ← 카테고리 차트 + 해지 추천
    └── SettingsView.swift      ← 기본 통화, 알림 설정
```

## 개발 원칙
- **MVP 범위 사수**: AI 없이 먼저 동작하게 → 그 위에 차트 → 그 위에 AI
- SwiftData는 `import SwiftData` + `.modelContainer(for:)` 로 세팅 완료
- 알림은 구독 추가/수정 시 `NotificationManager.schedule(for:)` 호출
- InsightEngine은 규칙 기반 (v1.2에서 LLM API로 교체 예정)
- `@Bindable var subscription: Subscription` 패턴으로 상세 뷰에서 직접 편집

## 현재 구현 단계
- [x] MVP v1.0: 구독 CRUD, 총액 계산, 로컬 알림, SwiftData 저장
- [x] v1.1: 카테고리 차트 (Swift Charts), 사용 빈도 입력
- [x] v1.1 규칙 기반 AI: 해지 추천 (InsightEngine)
- [x] v1.2 취향 추천: 관심사 기반 구독 추천 + 강화된 해지 제안 (RecommendationEngine + UserPreference)
- [ ] v1.2 LLM: Claude API 연동으로 자연어 추천/해지 사유 고도화
- [ ] v2.0: iCloud 동기화, 위젯

## 주의사항
- `@Model` enum 프로퍼티는 `String, Codable, CaseIterable` 필수
- 테스트에서 `@Model` 객체는 context 없이 생성 가능하나 init 파라미터로 값 설정 권장
- `PBXFileSystemSynchronizedRootGroup` 사용 → 파일 추가 시 pbxproj 수정 불필요
