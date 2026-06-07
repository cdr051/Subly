import Foundation

struct CancellationCandidate: Identifiable {
    let id = UUID()
    let subscription: Subscription
    let reason: String
    let score: Double
}

struct CategorySpend: Identifiable {
    let category: SubscriptionCategory
    let total: Double
    var id: SubscriptionCategory { category }
}

struct InsightEngine {
    static func cancellationCandidates(from subscriptions: [Subscription]) -> [CancellationCandidate] {
        subscriptions
            .filter { $0.usageFrequency != .often }
            .map { sub in
                CancellationCandidate(
                    subscription: sub,
                    reason: reason(for: sub),
                    score: sub.cancellationScore
                )
            }
            .sorted { $0.score > $1.score }
            .prefix(3)
            .map { $0 }
    }

    static func spendingSummary(from subscriptions: [Subscription]) -> String? {
        guard !subscriptions.isEmpty else { return nil }

        let totalMonthly = subscriptions.reduce(0.0) { $0 + $1.monthlyPrice }
        let breakdown = categoryBreakdown(from: subscriptions)

        guard let top = breakdown.first else { return nil }

        let percentage = totalMonthly > 0 ? Int((top.total / totalMonthly) * 100) : 0
        return "\(subscriptions.count)개 구독을 이용 중이에요. \(top.category.rawValue) 지출이 \(percentage)%로 가장 높아요."
    }

    static func categoryBreakdown(from subscriptions: [Subscription]) -> [CategorySpend] {
        Dictionary(grouping: subscriptions, by: \.category)
            .mapValues { $0.reduce(0.0) { $0 + $1.monthlyPrice } }
            .map { CategorySpend(category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }

    private static func reason(for sub: Subscription) -> String {
        switch sub.usageFrequency {
        case .rarely:
            return "거의 사용하지 않으면서 매달 \(sub.displayMonthlyPrice)를 지출하고 있어요. 해지를 고려해보세요."
        case .sometimes:
            return "가끔 사용하는 서비스예요. 연간 플랜이나 더 저렴한 대안이 있는지 확인해보세요."
        case .often:
            return ""
        }
    }
}
