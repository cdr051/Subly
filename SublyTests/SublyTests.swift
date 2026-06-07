import Testing
@testable import Subly

struct SubscriptionModelTests {
    @Test func 월간구독_월환산이_그대로인가() {
        let sub = Subscription(name: "Netflix", price: 17_000, billingCycle: .monthly)
        #expect(sub.monthlyPrice == 17_000)
    }

    @Test func 연간구독_월환산이_정확한가() {
        let sub = Subscription(name: "유튜브 프리미엄", price: 120_000, billingCycle: .yearly)
        #expect(sub.monthlyPrice == 10_000)
    }

    @Test func 주간구독_월환산이_4주_이상인가() {
        let sub = Subscription(name: "주간 서비스", price: 1_000, billingCycle: .weekly)
        #expect(sub.monthlyPrice > 3_500)
    }

    @Test func 연간_금액이_월환산_12배인가() {
        let sub = Subscription(name: "Test", price: 120_000, billingCycle: .yearly)
        #expect(abs(sub.yearlyPrice - sub.monthlyPrice * 12) < 0.01)
    }
}

struct InsightEngineTests {
    @Test func 거의안씀_구독은_해지후보에_포함된다() {
        let sub = Subscription(
            name: "Forgotten", price: 9_900,
            billingCycle: .monthly, usageFrequency: .rarely
        )
        let candidates = InsightEngine.cancellationCandidates(from: [sub])
        #expect(candidates.count == 1)
        #expect(candidates[0].subscription.name == "Forgotten")
    }

    @Test func 자주씀_구독은_해지후보에서_제외된다() {
        let sub = Subscription(
            name: "Netflix", price: 17_000,
            billingCycle: .monthly, usageFrequency: .often
        )
        let candidates = InsightEngine.cancellationCandidates(from: [sub])
        #expect(candidates.isEmpty)
    }

    @Test func 해지후보는_점수_내림차순으로_정렬된다() {
        let cheap = Subscription(name: "Cheap", price: 1_000, billingCycle: .monthly, usageFrequency: .rarely)
        let expensive = Subscription(name: "Expensive", price: 50_000, billingCycle: .monthly, usageFrequency: .rarely)
        let candidates = InsightEngine.cancellationCandidates(from: [cheap, expensive])
        #expect(candidates.first?.subscription.name == "Expensive")
    }

    @Test func 카테고리_분류가_올바르게_집계된다() {
        let a = Subscription(name: "A", price: 10_000, billingCycle: .monthly, category: .music)
        let b = Subscription(name: "B", price: 20_000, billingCycle: .monthly, category: .music)
        let c = Subscription(name: "C", price: 5_000, billingCycle: .monthly, category: .gaming)
        let breakdown = InsightEngine.categoryBreakdown(from: [a, b, c])
        #expect(breakdown[0].category == .music)
        #expect(breakdown[0].total == 30_000)
    }
}

struct CancellationScoreTests {
    @Test func 거의안씀이_자주씀보다_점수가_높다() {
        let often = Subscription(name: "A", price: 10_000, billingCycle: .monthly, usageFrequency: .often)
        let rarely = Subscription(name: "B", price: 10_000, billingCycle: .monthly, usageFrequency: .rarely)
        #expect(rarely.cancellationScore > often.cancellationScore)
    }
}
