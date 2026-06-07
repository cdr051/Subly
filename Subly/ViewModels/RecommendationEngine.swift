import Foundation

// MARK: - Result Types

struct ServiceRecommendation: Identifiable {
    let id = UUID()
    let service: ServiceInfo
    let matchScore: Double
    let matchTags: [Interest]
}

struct EnhancedCancellation: Identifiable {
    let id = UUID()
    let subscription: Subscription
    let reason: String
    let alternativeName: String?
}

// MARK: - RecommendationEngine

struct RecommendationEngine {

    // MARK: New Service Recommendations

    static func recommendNewServices(
        interests: [Interest],
        currentSubscriptions: [Subscription]
    ) -> [ServiceRecommendation] {
        guard !interests.isEmpty else { return [] }
        let currentSet = subscribedKeywordSet(from: currentSubscriptions)

        return ServiceDatabase.all
            .filter { !isSubscribed($0, keywordSet: currentSet) }
            .compactMap { service -> ServiceRecommendation? in
                let matching = service.interests.filter { interests.contains($0) }
                guard !matching.isEmpty else { return nil }
                let score = Double(matching.count) / Double(service.interests.count) * 100
                return ServiceRecommendation(service: service, matchScore: score, matchTags: matching)
            }
            .sorted { $0.matchScore > $1.matchScore }
            .prefix(6)
            .map { $0 }
    }

    // MARK: Enhanced Cancellation Suggestions

    static func enhancedCancellations(
        subscriptions: [Subscription],
        interests: [Interest]
    ) -> [EnhancedCancellation] {
        var results: [EnhancedCancellation] = []
        let currentSet = subscribedKeywordSet(from: subscriptions)

        // 1. Low-usage subscriptions
        for sub in subscriptions where sub.usageFrequency != .often {
            let alt = findCheaperAlternative(for: sub, interests: interests, currentSet: currentSet)
            results.append(EnhancedCancellation(
                subscription: sub,
                reason: lowUsageReason(for: sub),
                alternativeName: alt?.name
            ))
        }

        // 2. Duplicate category detection
        let grouped = Dictionary(grouping: subscriptions, by: \.category)
        for (category, subs) in grouped where subs.count >= 2 {
            // candidate: lowest usage first, then most expensive
            guard let candidate = subs.sorted(by: duplicateSortOrder).first,
                  !results.contains(where: { $0.subscription.id == candidate.id })
            else { continue }

            results.append(EnhancedCancellation(
                subscription: candidate,
                reason: "\(category.rawValue) 서비스가 \(subs.count)개예요. \(candidate.name)을(를) 해지하면 매달 \(candidate.displayMonthlyPrice)를 절약할 수 있어요.",
                alternativeName: nil
            ))
        }

        // 3. Interest mismatch for frequently-used subscriptions
        if !interests.isEmpty {
            for sub in subscriptions where sub.usageFrequency == .often {
                guard let service = ServiceDatabase.all.first(where: { isSubscribed($0, keywordSet: [sub.name.lowercased()]) }) else { continue }
                let hasMatch = service.interests.contains { interests.contains($0) }
                if !hasMatch, !results.contains(where: { $0.subscription.id == sub.id }) {
                    results.append(EnhancedCancellation(
                        subscription: sub,
                        reason: "자주 쓰고 있지만 선택하신 관심사와 잘 맞지 않아요. 더 잘 맞는 서비스로 교체해보세요.",
                        alternativeName: nil
                    ))
                }
            }
        }

        return results
            .sorted { $0.subscription.cancellationScore > $1.subscription.cancellationScore }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Already Subscribed Check (public for RecommendationView)

    static func isAlreadySubscribed(_ service: ServiceInfo, in subscriptions: [Subscription]) -> Bool {
        isSubscribed(service, keywordSet: subscribedKeywordSet(from: subscriptions))
    }

    // MARK: - Private Helpers

    private static func subscribedKeywordSet(from subscriptions: [Subscription]) -> Set<String> {
        Set(subscriptions.map { $0.name.lowercased() })
    }

    private static func isSubscribed(_ service: ServiceInfo, keywordSet: Set<String>) -> Bool {
        service.keywords.contains { keyword in
            keywordSet.contains { current in
                current.contains(keyword) || keyword.contains(current)
            }
        }
    }

    private static func lowUsageReason(for sub: Subscription) -> String {
        switch sub.usageFrequency {
        case .rarely:
            return "거의 사용하지 않으면서 매달 \(sub.displayMonthlyPrice)를 내고 있어요. 해지를 강력 추천해요."
        case .sometimes:
            return "가끔만 사용하는 서비스예요. 더 저렴한 대안이나 연간 플랜을 고려해보세요."
        case .often:
            return ""
        }
    }

    private static func duplicateSortOrder(_ a: Subscription, _ b: Subscription) -> Bool {
        if a.usageFrequency.cancellationWeight != b.usageFrequency.cancellationWeight {
            return a.usageFrequency.cancellationWeight > b.usageFrequency.cancellationWeight
        }
        return a.monthlyPrice > b.monthlyPrice
    }

    private static func findCheaperAlternative(
        for sub: Subscription,
        interests: [Interest],
        currentSet: Set<String>
    ) -> ServiceInfo? {
        guard !interests.isEmpty else { return nil }
        return ServiceDatabase.all
            .filter { !isSubscribed($0, keywordSet: currentSet) }
            .filter { service in
                service.interests.contains { interests.contains($0) } &&
                service.monthlyPriceKRW < Int(sub.monthlyPrice)
            }
            .sorted { $0.monthlyPriceKRW < $1.monthlyPriceKRW }
            .first
    }
}
