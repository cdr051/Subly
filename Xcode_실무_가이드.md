# Xcode 실무 가이드 — 구독 관리 앱 첫 세팅

> 대상: 프로그래밍 경험은 있으나 iOS는 처음 / Mac 사용 / SwiftUI + Swift + SwiftData + Swift Testing
> 목표: Xcode 설치부터 "구독을 추가하면 목록에 뜨고 총액이 계산되는" 최소 동작까지.

---

## 0. 준비물 체크

- macOS (보유 ✅)
- Xcode 최신 버전 (App Store에서 무료)
- Claude Code (이미 설치 ✅)
- Apple 계정 (App Store 로그인용, 무료)
- ※ Apple Developer Program(연 $99)은 **실기기 배포/출시 단계에서만** 필요. 지금은 불필요.

---

## 1. Xcode 설치

1. Mac App Store 열기 → "Xcode" 검색 → 설치 (용량이 크니 시간 걸림)
2. 설치 후 한 번 실행 → 추가 컴포넌트 설치 프롬프트가 뜨면 동의
3. 터미널에서 명령행 도구도 잡아두기:
   ```bash
   xcode-select --install
   ```
   (이미 설치돼 있으면 그냥 넘어가도 됨)

---

## 2. 새 프로젝트 생성

1. Xcode 실행 → **Create New Project** (또는 File > New > Project)
2. 상단 탭에서 **iOS** 선택 → **App** 선택 → Next
3. 옵션 설정:

| 항목 | 값 | 이유 |
|------|-----|------|
| Product Name | `SubManager` (원하는 이름) | 나중에 표시 이름은 따로 바꿀 수 있음 |
| Team | 본인 Apple 계정 | 없으면 "Add Account"로 무료 등록 |
| Organization Identifier | `com.본인이름` 같은 역도메인 | 번들 ID 생성용. 예: `com.gildong` |
| Interface | **SwiftUI** | |
| Language | **Swift** | |
| Storage | **None** | ⚠️ 아래 설명 참고 |
| Testing System | **Swift Testing** (또는 Swift Testing with XCUITest) | 유닛 테스트용 |
| Include Tests | 체크 ✅ | 테스트 타깃을 처음부터 만들어둠 |

> **왜 Storage를 None으로?** Xcode가 "SwiftData"를 고르면 샘플 코드가 잔뜩 딸려옵니다. 직접 깔끔하게 SwiftData를 붙이는 게 구조 이해에 더 좋아서, 빈 상태로 시작해 우리가 모델을 추가합니다. (SwiftData 프레임워크 자체는 `import SwiftData`만 하면 바로 쓸 수 있음 — 별도 설치 불필요)

4. 저장 위치 선택 → **Create Source Control** 체크(Git 자동 시작, 권장) → Create

---

## 3. 프로젝트 구조 정리

새 프로젝트에는 기본적으로 `(앱이름)App.swift`와 `ContentView.swift`가 있어요. 규모가 커질 걸 대비해 폴더(그룹)를 미리 나눠두면 좋습니다. 프로젝트 네비게이터에서 우클릭 → New Group:

```
SubManager/
├── App/            ← (앱이름)App.swift
├── Models/         ← SwiftData 모델 (Subscription.swift 등)
├── Views/          ← 화면 (SubscriptionListView.swift 등)
├── ViewModels/     ← 로직 (테스트하기 쉽게 분리)
└── Resources/      ← 색상, 에셋 등
```

> 처음엔 파일이 몇 개 안 되니 과하게 나눌 필요는 없지만, Models / Views 정도는 일찍 분리하는 게 좋아요. **특히 로직을 ViewModel로 빼두면 나중에 테스트가 훨씬 쉬워집니다** (4번 끝 참고).

---

## 4. 첫 동작 만들기 — SwiftData 모델 + 목록 화면

여기서부터는 Claude Code에 맡겨도 되지만, 전체 흐름을 이해하도록 핵심만 적습니다.

### (1) 모델 정의 — `Models/Subscription.swift`

```swift
import Foundation
import SwiftData

@Model
final class Subscription {
    var name: String
    var price: Double
    var billingCycleMonths: Int   // 1 = 월간, 12 = 연간
    var nextBillingDate: Date
    var category: String

    init(name: String, price: Double, billingCycleMonths: Int = 1,
         nextBillingDate: Date = .now, category: String = "기타") {
        self.name = name
        self.price = price
        self.billingCycleMonths = billingCycleMonths
        self.nextBillingDate = nextBillingDate
        self.category = category
    }

    // 월 환산 금액 (총액 계산용)
    var monthlyPrice: Double {
        price / Double(billingCycleMonths)
    }
}
```

### (2) 앱 진입점에 SwiftData 연결 — `App/(앱이름)App.swift`

```swift
import SwiftUI
import SwiftData

@main
struct SubManagerApp: App {
    var body: some Scene {
        WindowGroup {
            SubscriptionListView()
        }
        .modelContainer(for: Subscription.self)  // ← 이 한 줄이 저장소를 켬
    }
}
```

### (3) 목록 + 추가 화면 — `Views/SubscriptionListView.swift`

```swift
import SwiftUI
import SwiftData

struct SubscriptionListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Subscription.name) private var subscriptions: [Subscription]

    var totalMonthly: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyPrice }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("이번 달 예상 지출") {
                    Text("₩\(totalMonthly, specifier: "%.0f")")
                        .font(.title2).bold()
                }
                Section("구독 목록") {
                    ForEach(subscriptions) { sub in
                        VStack(alignment: .leading) {
                            Text(sub.name).font(.headline)
                            Text("₩\(sub.price, specifier: "%.0f") · \(sub.category)")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("내 구독")
            .toolbar {
                Button {
                    addSample()
                } label: { Image(systemName: "plus") }
            }
        }
    }

    private func addSample() {
        let sample = Subscription(name: "Netflix", price: 17000,
                                  billingCycleMonths: 1, category: "엔터테인먼트")
        context.insert(sample)
    }

    private func delete(_ offsets: IndexSet) {
        for i in offsets { context.delete(subscriptions[i]) }
    }
}
```

이 상태로 ▶️ 실행하면, `+` 버튼으로 구독이 추가되고 목록·총액이 자동 갱신됩니다. 앱을 껐다 켜도 데이터가 남아요(SwiftData가 저장하므로). **이게 MVP의 뼈대입니다.**

> **로직 분리 팁:** `totalMonthly` 같은 계산을 별도의 `struct`/`ViewModel`로 빼면 Swift Testing으로 단위 테스트하기 쉬워집니다. `@Query`에 직접 의존하는 화면 자체는 UI 테스트(XCUITest) 영역이에요.

---

## 5. 실행 / 시뮬레이터

- 상단 중앙의 기기 선택 메뉴에서 시뮬레이터(예: iPhone 16) 선택
- 좌상단 ▶️ (또는 `Cmd + R`)로 빌드·실행
- 멈출 때는 ■ (또는 `Cmd + .`)
- 자주 쓰는 단축키: 빌드 `Cmd+B`, 실행 `Cmd+R`, 정리 `Cmd+Shift+K`

---

## 6. 테스트 (Swift Testing)

`Include Tests`를 체크했다면 테스트 타깃이 이미 있습니다. 순수 로직부터 가볍게 검증하세요.

```swift
import Testing
@testable import SubManager

struct SubscriptionTests {
    @Test func 연간구독_월환산이_정확한가() {
        let yearly = Subscription(name: "유튜브 프리미엄", price: 120000,
                                  billingCycleMonths: 12)
        #expect(yearly.monthlyPrice == 10000)
    }
}
```

- 테스트 실행: `Cmd + U` 또는 테스트 함수 옆 ◇ 클릭
- **주의:** `@Query`를 쓰는 화면 로직은 SwiftUI가 떠야 동작하므로 단위 테스트가 어렵습니다. 그래서 계산·검증 같은 **순수 함수는 ViewModel/모델 메서드로 빼서 Swift Testing으로**, 화면 흐름은 **XCUITest로** 나눠 테스트하는 게 정석이에요. 지금 단계에선 순수 로직 몇 개만 덮어도 충분합니다.

---

## 7. Claude Code와 함께 작업하는 흐름

1. 터미널에서 프로젝트 폴더로 이동 후 `claude` 실행
   ```bash
   cd ~/경로/SubManager
   claude
   ```
2. 프로젝트 루트에 `/init`로 `CLAUDE.md`를 만들어두면, Claude가 프로젝트 맥락(스택·구조·규칙)을 기억합니다.
3. 작업 방식: **코드는 Claude Code에서 짜고/고치고 → 빌드·실행·시뮬레이터 확인은 Xcode에서.**
   - 예: "Subscription 모델에 사용빈도(usageFrequency) 속성 추가하고, 목록에서 보여줘"
   - 예: "이 빌드 에러 원인 찾아줘" (Xcode 에러 메시지를 붙여넣기)
4. Xcode가 외부 파일 변경을 자동 반영하니, Claude가 파일을 고치면 Xcode에서 다시 ▶️만 누르면 됩니다.

> 권장 `CLAUDE.md` 메모: 스택(SwiftUI/Swift/SwiftData/Swift Testing), 폴더 구조 규칙, "Storage는 SwiftData", "MVP 범위 사수" 같은 원칙을 적어두면 Claude가 그 틀 안에서 도와줍니다.

---

## 8. Git (버전 관리)

프로젝트 생성 시 Source Control을 켰다면 이미 Git이 시작됐어요. 기능 단위로 커밋하는 습관을 들이세요.

```bash
git add .
git commit -m "feat: 구독 목록 + 총액 계산 추가"
```

- `.gitignore`에 Xcode 사용자 설정·빌드 산출물(`xcuserdata/`, `DerivedData/` 등)이 들어가야 합니다. Xcode가 기본 생성해주지만, 누락 시 Claude Code에 "Xcode용 .gitignore 만들어줘"라고 요청하세요.

---

## 9. 다음 단계 로드맵

MVP 뼈대가 돌면 개요서의 순서대로 한 겹씩:

1. ✅ 구독 추가/삭제 + 총액 (지금 단계)
2. 제대로 된 입력 폼 화면 (`+`를 샘플이 아닌 실제 폼으로)
3. 결제일 로컬 알림 (UserNotifications)
4. 카테고리 차트 (Swift Charts)
5. 사용빈도 입력 → 규칙 기반 "해지 후보" 정렬
6. LLM API 연동으로 진짜 AI 추천/해지 사유 생성
7. TestFlight로 실기기 테스트 (이때 Apple Developer Program 가입)

---

## 자주 막히는 지점

- **`command not found: claude`** → 터미널 재시작 또는 셸 설정 reload
- **시뮬레이터가 안 뜸** → Xcode > Settings > Components에서 시뮬레이터 런타임 설치 확인
- **빌드는 되는데 데이터가 안 남음** → `.modelContainer(for:)`가 앱 진입점에 붙어 있는지 확인
- **에러 메시지가 막막할 때** → 메시지 전체를 복사해 Claude Code에 그대로 붙여넣기. 보통 한 번에 원인을 짚어줍니다.

> 막히면 그 화면/에러를 캡처하거나 코드를 들고 다시 오세요. 단계별로 같이 풀어드릴게요.
