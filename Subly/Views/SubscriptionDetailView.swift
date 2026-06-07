import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var subscription: Subscription

    @State private var showingEdit = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                infoCard
                usageCard
                if !subscription.notes.isEmpty {
                    notesCard
                }
            }
            .padding()
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(subscription.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showingEdit = true } label: {
                        Label("편집", systemImage: "pencil")
                    }
                    Divider()
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddEditSubscriptionView(subscription: subscription)
        }
        .alert("구독 삭제", isPresented: $showingDeleteAlert) {
            Button("삭제", role: .destructive) {
                NotificationManager.cancel(for: subscription)
                context.delete(subscription)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("\(subscription.name)을(를) 삭제하시겠어요? 이 작업은 되돌릴 수 없어요.")
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(hex: subscription.colorHex).opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: subscription.category.sfSymbol)
                    .font(.system(size: 38))
                    .foregroundStyle(Color(hex: subscription.colorHex))
            }

            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Text(subscription.name)
                        .font(.title2).bold()
                    if subscription.isTrial {
                        Text("체험")
                            .font(.caption).bold()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
                Text(subscription.category.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 0) {
                priceMetric(label: "결제 금액", value: subscription.displayPrice + subscription.billingCycle.shortSuffix)
                Divider().frame(height: 36)
                priceMetric(label: "월 환산", value: subscription.displayMonthlyPrice)
                Divider().frame(height: 36)
                priceMetric(label: "연 환산", value: subscription.displayYearlyPrice)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: .black.opacity(0.07), radius: 8, y: 4)
    }

    private func priceMetric(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Info Card

    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow(icon: "calendar", label: "다음 결제일", value: subscription.nextBillingDate.fullDateText)
            divider
            infoRow(
                icon: "clock",
                label: "결제까지",
                value: subscription.daysUntilBilling == 0 ? "오늘" : "\(subscription.daysUntilBilling)일 후",
                valueColor: subscription.isUpcomingSoon ? .orange : nil
            )
            divider
            infoRow(icon: "arrow.2.circlepath", label: "결제 주기", value: subscription.billingCycle.rawValue)
            divider
            infoRow(icon: "dollarsign.circle", label: "통화", value: "\(subscription.currency) (\(subscription.currencySymbol))")

            if subscription.isTrial, let trialEnd = subscription.trialEndDate {
                divider
                infoRow(icon: "gift.fill", label: "체험 종료일", value: trialEnd.fullDateText, valueColor: .orange)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Usage Card

    private var usageCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("사용 빈도")
                .font(.headline)
                .padding(.horizontal, 4)

            HStack(spacing: 0) {
                ForEach(UsageFrequency.allCases, id: \.self) { freq in
                    Button {
                        subscription.usageFrequency = freq
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: freq.sfSymbol)
                                .font(.title3)
                            Text(freq.rawValue)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            subscription.usageFrequency == freq
                                ? Color(hex: subscription.colorHex).opacity(0.15)
                                : Color.clear
                        )
                        .foregroundStyle(
                            subscription.usageFrequency == freq
                                ? Color(hex: subscription.colorHex)
                                : Color.secondary
                        )
                    }
                }
            }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Notes Card

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("메모", systemImage: "note.text")
                .font(.headline)
                .padding(.horizontal, 4)

            Text(subscription.notes)
                .font(.body)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Helpers

    private var divider: some View {
        Divider().padding(.leading, 52)
    }

    private func infoRow(icon: String, label: String, value: String, valueColor: Color? = nil) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundStyle(valueColor ?? .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }
}
