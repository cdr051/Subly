import SwiftUI
import SwiftData

struct RecommendationView: View {
    @Environment(\.modelContext) private var context
    @Query private var preferences: [UserPreference]
    @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]

    private var preference: UserPreference? { preferences.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    interestSection
                    if let pref = preference, !pref.interestKeys.isEmpty {
                        recommendationSection(pref: pref)
                        cancellationSection(pref: pref)
                    } else {
                        emptyPrompt
                    }
                }
                .padding()
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("취향 기반 추천")
            .onAppear {
                if preferences.isEmpty {
                    context.insert(UserPreference())
                }
            }
        }
    }

    // MARK: - Interest Section

    private var interestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Label("어떤 콘텐츠를 즐기시나요?", systemImage: "hand.tap.fill")
                    .font(.headline)
                Text("관심 있는 항목을 모두 선택하세요. 언제든 변경할 수 있어요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 2)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 108), spacing: 10)],
                spacing: 10
            ) {
                ForEach(Interest.allCases, id: \.self) { interest in
                    let selected = preference?.isSelected(interest) ?? false
                    InterestChip(interest: interest, isSelected: selected) {
                        toggleInterest(interest)
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }

    // MARK: - New Recommendations Section

    private func recommendationSection(pref: UserPreference) -> some View {
        let recs = RecommendationEngine.recommendNewServices(
            interests: pref.interests,
            currentSubscriptions: subscriptions
        )

        return VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Label("지금 구독해보면 어떨까요?", systemImage: "sparkles")
                    .font(.headline)
                Text("선택하신 취향을 바탕으로 추천했어요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if recs.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("이미 취향에 맞는 서비스를 모두 구독하고 있어요!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            } else {
                ForEach(recs) { rec in
                    RecommendedServiceCard(recommendation: rec)
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }

    // MARK: - Cancellation Section

    private func cancellationSection(pref: UserPreference) -> some View {
        let cancellations = RecommendationEngine.enhancedCancellations(
            subscriptions: subscriptions,
            interests: pref.interests
        )

        return VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Label("해지 검토 추천", systemImage: "scissors.circle.fill")
                    .font(.headline)
                Text("사용 빈도·취향·중복 서비스를 분석했어요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if cancellations.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("현재 구독을 잘 활용하고 있어요!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            } else {
                ForEach(cancellations) { item in
                    EnhancedCancellationCard(item: item)
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }

    // MARK: - Empty Prompt

    private var emptyPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 6) {
                Text("취향을 선택하면")
                    .font(.title3).bold()
                Text("딱 맞는 구독 서비스를 추천해드려요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    // MARK: - Actions

    private func toggleInterest(_ interest: Interest) {
        if let pref = preferences.first {
            pref.toggle(interest)
        } else {
            let pref = UserPreference(interestKeys: [interest.rawValue])
            context.insert(pref)
        }
    }
}

// MARK: - Interest Chip

struct InterestChip: View {
    let interest: Interest
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: interest.sfSymbol)
                    .font(.caption)
                Text(interest.rawValue)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.purple.opacity(0.12) : Color(.systemGroupedBackground))
            .foregroundStyle(isSelected ? Color.purple : Color.secondary)
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isSelected ? Color.purple : Color.clear, lineWidth: 1.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Recommended Service Card

struct RecommendedServiceCard: View {
    let recommendation: ServiceRecommendation

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: recommendation.service.colorHex).opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: recommendation.service.sfSymbol)
                    .font(.title3)
                    .foregroundStyle(Color(hex: recommendation.service.colorHex))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.service.name)
                    .font(.headline)
                Text(recommendation.service.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                // match tags
                HStack(spacing: 6) {
                    ForEach(recommendation.matchTags, id: \.self) { tag in
                        Text(tag.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .foregroundStyle(.purple)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 2) {
                if recommendation.service.monthlyPriceKRW == 0 {
                    Text("무료")
                        .font(.headline)
                        .foregroundStyle(.green)
                } else {
                    Text("₩\(recommendation.service.monthlyPriceKRW.formatted())")
                        .font(.headline)
                    Text("/월")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Enhanced Cancellation Card

struct EnhancedCancellationCard: View {
    let item: EnhancedCancellation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: item.subscription.colorHex).opacity(0.15))
                        .frame(width: 38, height: 38)
                    Image(systemName: item.subscription.category.sfSymbol)
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: item.subscription.colorHex))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.subscription.name)
                        .font(.subheadline).bold()
                    Text(item.subscription.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.subscription.displayMonthlyPrice)
                        .font(.subheadline).bold()
                        .foregroundStyle(.red)
                    Text("/월")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text(item.reason)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let alt = item.alternativeName {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                    Text("\(alt)(으)로 교체 고려")
                        .font(.caption)
                }
                .foregroundStyle(Color.blue)
            }
        }
        .padding(14)
        .background(Color.red.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.red.opacity(0.12), lineWidth: 1)
        }
    }
}
