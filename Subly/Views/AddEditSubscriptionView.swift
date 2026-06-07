import SwiftUI
import SwiftData

private let presetColors = [
    "FF3B30", "FF9500", "FFCC00", "34C759",
    "00C7BE", "007AFF", "5856D6", "AF52DE", "FF2D55", "8E8E93"
]

private let currencies = ["KRW", "USD", "EUR", "JPY"]

struct AddEditSubscriptionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var subscription: Subscription?

    @State private var name: String
    @State private var priceText: String
    @State private var currency: String
    @State private var billingCycle: BillingCycle
    @State private var nextBillingDate: Date
    @State private var category: SubscriptionCategory
    @State private var usageFrequency: UsageFrequency
    @State private var isTrial: Bool
    @State private var trialEndDate: Date
    @State private var notes: String
    @State private var colorHex: String

    init(subscription: Subscription? = nil) {
        self.subscription = subscription
        let defaultNext = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
        let defaultCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") ?? "KRW"

        _name = State(initialValue: subscription?.name ?? "")
        _priceText = State(initialValue: subscription.map { $0.price.priceInputString } ?? "")
        _currency = State(initialValue: subscription?.currency ?? defaultCurrency)
        _billingCycle = State(initialValue: subscription?.billingCycle ?? .monthly)
        _nextBillingDate = State(initialValue: subscription?.nextBillingDate ?? defaultNext)
        _category = State(initialValue: subscription?.category ?? .other)
        _usageFrequency = State(initialValue: subscription?.usageFrequency ?? .often)
        _isTrial = State(initialValue: subscription?.isTrial ?? false)
        _trialEndDate = State(initialValue: subscription?.trialEndDate ?? defaultNext)
        _notes = State(initialValue: subscription?.notes ?? "")
        _colorHex = State(initialValue: subscription?.colorHex ?? "007AFF")
    }

    private var isEditing: Bool { subscription != nil }
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && Double(priceText) != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                basicSection
                pricingSection
                usageSection
                colorSection
                notesSection
            }
            .navigationTitle(isEditing ? "구독 편집" : "구독 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장") { save() }
                        .bold()
                        .disabled(!isValid)
                }
            }
        }
    }

    // MARK: - Sections

    private var basicSection: some View {
        Section("기본 정보") {
            HStack {
                Image(systemName: category.sfSymbol)
                    .foregroundStyle(Color(hex: colorHex))
                    .frame(width: 24)
                TextField("서비스 이름", text: $name)
            }

            Picker("카테고리", selection: $category) {
                ForEach(SubscriptionCategory.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.sfSymbol).tag(cat)
                }
            }
        }
    }

    private var pricingSection: some View {
        Section("금액 및 결제") {
            HStack {
                Text(currencySymbol(for: currency))
                    .foregroundStyle(.secondary)
                TextField("금액", text: $priceText)
                    .keyboardType(.decimalPad)
            }

            Picker("통화", selection: $currency) {
                ForEach(currencies, id: \.self) { c in
                    Text("\(c) (\(currencySymbol(for: c)))").tag(c)
                }
            }

            Picker("결제 주기", selection: $billingCycle) {
                ForEach(BillingCycle.allCases, id: \.self) { cycle in
                    Text(cycle.rawValue).tag(cycle)
                }
            }

            DatePicker("다음 결제일", selection: $nextBillingDate, displayedComponents: .date)
        }
    }

    private var usageSection: some View {
        Section("사용 정보") {
            Picker("사용 빈도", selection: $usageFrequency) {
                ForEach(UsageFrequency.allCases, id: \.self) { freq in
                    Label(freq.rawValue, systemImage: freq.sfSymbol).tag(freq)
                }
            }

            Toggle("무료체험 중", isOn: $isTrial)

            if isTrial {
                DatePicker("체험 종료일", selection: $trialEndDate, displayedComponents: .date)
            }
        }
    }

    private var colorSection: some View {
        Section("색상") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(presetColors, id: \.self) { hex in
                        ZStack {
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                            if colorHex == hex {
                                Image(systemName: "checkmark")
                                    .font(.caption).bold()
                                    .foregroundStyle(.white)
                            }
                        }
                        .onTapGesture { colorHex = hex }
                    }
                }
                .padding(.vertical, 6)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
    }

    private var notesSection: some View {
        Section("메모 (선택)") {
            TextField("메모를 입력하세요", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    // MARK: - Save

    private func save() {
        let priceValue = Double(priceText) ?? 0

        if let existing = subscription {
            existing.name = name.trimmingCharacters(in: .whitespaces)
            existing.price = priceValue
            existing.currency = currency
            existing.billingCycle = billingCycle
            existing.nextBillingDate = nextBillingDate
            existing.category = category
            existing.usageFrequency = usageFrequency
            existing.isTrial = isTrial
            existing.trialEndDate = isTrial ? trialEndDate : nil
            existing.notes = notes
            existing.colorHex = colorHex
            NotificationManager.schedule(for: existing)
        } else {
            let new = Subscription(
                name: name.trimmingCharacters(in: .whitespaces),
                price: priceValue,
                currency: currency,
                billingCycle: billingCycle,
                nextBillingDate: nextBillingDate,
                category: category,
                usageFrequency: usageFrequency,
                isTrial: isTrial,
                trialEndDate: isTrial ? trialEndDate : nil,
                notes: notes,
                colorHex: colorHex
            )
            context.insert(new)
            NotificationManager.schedule(for: new)
        }

        dismiss()
    }

    private func currencySymbol(for currency: String) -> String {
        switch currency {
        case "KRW": return "₩"
        case "USD": return "$"
        case "EUR": return "€"
        case "JPY": return "¥"
        default: return currency
        }
    }
}
