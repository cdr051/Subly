import SwiftUI
import SwiftData

struct HomeView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("홈", systemImage: "house.fill") }

            InsightsView()
                .tabItem { Label("인사이트", systemImage: "chart.bar.fill") }

            RecommendationView()
                .tabItem { Label("추천", systemImage: "sparkles") }

            SettingsView()
                .tabItem { Label("설정", systemImage: "gearshape.fill") }
        }
    }
}

// MARK: - Dashboard Tab

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Subscription.nextBillingDate) private var subscriptions: [Subscription]
    @State private var showingAdd = false
    @State private var editingSubscription: Subscription?
    @State private var searchText = ""

    private var filtered: [Subscription] {
        guard !searchText.isEmpty else { return subscriptions }
        return subscriptions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var upcoming: [Subscription] {
        subscriptions.filter { $0.isUpcomingSoon }
    }

    private var totalMonthly: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyPrice }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16, pinnedViews: []) {
                    summaryCard
                        .padding(.horizontal)
                        .padding(.top, 8)

                    if !upcoming.isEmpty && searchText.isEmpty {
                        upcomingSection
                            .padding(.horizontal)
                    }

                    allSection
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("내 구독")
            .searchable(text: $searchText, prompt: "서비스 검색")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEditSubscriptionView()
            }
            .sheet(item: $editingSubscription) { sub in
                AddEditSubscriptionView(subscription: sub)
            }
        }
    }

    // MARK: Summary Card

    private var summaryCard: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color(hex: "667EEA").opacity(0.4), radius: 12, y: 6)

            VStack(spacing: 14) {
                Text("이번 달 예상 지출")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))

                Text("₩\(Int(totalMonthly).formatted())")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Rectangle()
                    .fill(.white.opacity(0.25))
                    .frame(height: 1)

                HStack {
                    VStack(spacing: 4) {
                        Text("연간")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text("₩\(Int(totalMonthly * 12).formatted())")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text("구독 수")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text("\(subscriptions.count)개")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(24)
        }
    }

    // MARK: Upcoming Section

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("7일 내 결제 예정", systemImage: "bell.badge.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            ForEach(upcoming) { sub in
                NavigationLink(destination: SubscriptionDetailView(subscription: sub)) {
                    UpcomingRow(subscription: sub)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: All Subscriptions Section

    private var allSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("전체 구독")
                    .font(.headline)
                Spacer()
                Text("\(filtered.count)개")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if filtered.isEmpty {
                emptyState
            } else {
                ForEach(filtered) { sub in
                    NavigationLink(destination: SubscriptionDetailView(subscription: sub)) {
                        SubscriptionCard(subscription: sub)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            editingSubscription = sub
                        } label: {
                            Label("편집", systemImage: "pencil")
                        }
                        Divider()
                        Button(role: .destructive) {
                            delete(sub)
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard.trianglebadge.exclamationmark")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text(searchText.isEmpty ? "아직 구독이 없어요" : "검색 결과가 없어요")
                .font(.headline)
                .foregroundStyle(.secondary)
            if searchText.isEmpty {
                Button("첫 구독 추가하기") { showingAdd = true }
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }

    private func delete(_ sub: Subscription) {
        NotificationManager.cancel(for: sub)
        context.delete(sub)
    }
}

// MARK: - Upcoming Row

struct UpcomingRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            categoryIcon(subscription)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.name)
                    .font(.subheadline).bold()
                Text(subscription.nextBillingDate.billingDateText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(subscription.displayPrice)
                    .font(.subheadline).bold()
                let days = subscription.daysUntilBilling
                Text(days == 0 ? "오늘" : "D-\(days)")
                    .font(.caption2).bold()
                    .foregroundStyle(days <= 3 ? .red : .orange)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Subscription Card

struct SubscriptionCard: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 14) {
            categoryIcon(subscription)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(subscription.name)
                        .font(.headline)
                    if subscription.isTrial {
                        Text("체험")
                            .font(.caption2).bold()
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
                Text(subscription.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: subscription.usageFrequency.sfSymbol)
                        .font(.system(size: 10))
                    Text(subscription.usageFrequency.rawValue)
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.displayPrice)
                    .font(.headline)
                Text(subscription.billingCycle.shortSuffix)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(subscription.nextBillingDate.billingDateText)
                    .font(.caption2)
                    .foregroundStyle(subscription.isUpcomingSoon ? .orange : .secondary)
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }
}

// MARK: - Shared helper

func categoryIcon(_ subscription: Subscription) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(hex: subscription.colorHex).opacity(0.15))
        Image(systemName: subscription.category.sfSymbol)
            .font(.title3)
            .foregroundStyle(Color(hex: subscription.colorHex))
    }
}
