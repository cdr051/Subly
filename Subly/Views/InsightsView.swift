import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query private var subscriptions: [Subscription]

    private var breakdown: [CategorySpend] {
        InsightEngine.categoryBreakdown(from: subscriptions)
    }

    private var candidates: [CancellationCandidate] {
        InsightEngine.cancellationCandidates(from: subscriptions)
    }

    private var summary: String? {
        InsightEngine.spendingSummary(from: subscriptions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if subscriptions.isEmpty {
                        emptyState
                    } else {
                        if let text = summary {
                            summaryBanner(text)
                        }
                        if !breakdown.isEmpty {
                            categoryChartCard
                        }
                        if !candidates.isEmpty {
                            cancellationCard
                        } else {
                            allGoodCard
                        }
                    }
                }
                .padding()
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("인사이트")
        }
    }

    // MARK: - Summary Banner

    private func summaryBanner(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(.purple)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.purple.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Category Chart Card

    private var categoryChartCard: some View {
        let maxTotal = breakdown.map { $0.total }.max() ?? 1

        return VStack(alignment: .leading, spacing: 14) {
            Label("카테고리별 월 지출", systemImage: "chart.bar.fill")
                .font(.headline)

            Chart {
                ForEach(breakdown) { item in
                    BarMark(
                        x: .value("금액", item.total),
                        y: .value("카테고리", item.category.rawValue)
                    )
                    .foregroundStyle(Color(hex: item.category.colorHex))
                    .cornerRadius(6)
                }
            }
            .chartXAxis(.hidden)
            .chartXScale(domain: 0...maxTotal)
            .frame(height: max(CGFloat(breakdown.count) * 46, 60))

            Divider()

            let totalAll = breakdown.reduce(0.0) { $0 + $1.total }
            VStack(spacing: 8) {
                ForEach(breakdown) { item in
                    let pct = totalAll > 0 ? Int((item.total / totalAll) * 100) : 0
                    HStack {
                        Circle()
                            .fill(Color(hex: item.category.colorHex))
                            .frame(width: 10, height: 10)
                        Text(item.category.rawValue)
                            .font(.caption)
                        Spacer()
                        Text("\(pct)%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("₩\(Int(item.total).formatted())")
                            .font(.caption).bold()
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }

    // MARK: - Cancellation Card

    private var cancellationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("해지 검토 추천", systemImage: "scissors")
                .font(.headline)
            Text("사용 빈도와 비용을 분석한 결과예요.")
                .font(.caption)
                .foregroundStyle(.secondary)
            ForEach(candidates) { candidate in
                CancellationRow(candidate: candidate)
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }

    private var allGoodCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            Text("구독을 잘 활용하고 있어요!")
                .font(.headline)
            Text("사용 빈도를 입력하면 더 정확한 분석을 받을 수 있어요.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 3)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("아직 분석할 구독이 없어요")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("홈 탭에서 구독을 추가하면\n인사이트를 확인할 수 있어요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Cancellation Row

struct CancellationRow: View {
    let candidate: CancellationCandidate

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: candidate.subscription.category.sfSymbol)
                    .foregroundStyle(.red)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(candidate.subscription.name)
                        .font(.subheadline).bold()
                    Spacer()
                    Text(candidate.subscription.displayMonthlyPrice + "/월")
                        .font(.subheadline).bold()
                        .foregroundStyle(.red)
                }
                Text(candidate.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(Color.red.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
