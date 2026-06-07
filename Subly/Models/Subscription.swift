import Foundation
import SwiftData

enum BillingCycle: String, Codable, CaseIterable {
    case weekly = "주간"
    case monthly = "월간"
    case yearly = "연간"

    var monthsFactor: Double {
        switch self {
        case .weekly: return 7.0 / 30.44
        case .monthly: return 1.0
        case .yearly: return 12.0
        }
    }

    var shortSuffix: String {
        switch self {
        case .weekly: return "/주"
        case .monthly: return "/월"
        case .yearly: return "/년"
        }
    }
}

enum SubscriptionCategory: String, Codable, CaseIterable {
    case entertainment = "엔터테인먼트"
    case music = "음악"
    case productivity = "생산성"
    case health = "건강·피트니스"
    case news = "뉴스·미디어"
    case education = "교육"
    case gaming = "게임"
    case software = "소프트웨어"
    case other = "기타"

    var sfSymbol: String {
        switch self {
        case .entertainment: return "tv.fill"
        case .music: return "music.note"
        case .productivity: return "briefcase.fill"
        case .health: return "heart.fill"
        case .news: return "newspaper.fill"
        case .education: return "book.fill"
        case .gaming: return "gamecontroller.fill"
        case .software: return "laptopcomputer"
        case .other: return "square.grid.2x2.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .entertainment: return "FF2D55"
        case .music: return "FF9500"
        case .productivity: return "007AFF"
        case .health: return "34C759"
        case .news: return "00C7BE"
        case .education: return "FFCC00"
        case .gaming: return "5856D6"
        case .software: return "AF52DE"
        case .other: return "8E8E93"
        }
    }
}

enum UsageFrequency: String, Codable, CaseIterable {
    case often = "자주 씀"
    case sometimes = "가끔"
    case rarely = "거의 안 씀"

    var cancellationWeight: Double {
        switch self {
        case .often: return 1.0
        case .sometimes: return 2.5
        case .rarely: return 5.0
        }
    }

    var sfSymbol: String {
        switch self {
        case .often: return "flame.fill"
        case .sometimes: return "equal.circle.fill"
        case .rarely: return "moon.zzz.fill"
        }
    }
}

@Model
final class Subscription {
    var id: UUID
    var name: String
    var price: Double
    var currency: String
    var billingCycle: BillingCycle
    var nextBillingDate: Date
    var category: SubscriptionCategory
    var usageFrequency: UsageFrequency
    var isTrial: Bool
    var trialEndDate: Date?
    var notes: String
    var colorHex: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        price: Double,
        currency: String = "KRW",
        billingCycle: BillingCycle = .monthly,
        nextBillingDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now,
        category: SubscriptionCategory = .other,
        usageFrequency: UsageFrequency = .often,
        isTrial: Bool = false,
        trialEndDate: Date? = nil,
        notes: String = "",
        colorHex: String = "007AFF",
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.price = price
        self.currency = currency
        self.billingCycle = billingCycle
        self.nextBillingDate = nextBillingDate
        self.category = category
        self.usageFrequency = usageFrequency
        self.isTrial = isTrial
        self.trialEndDate = trialEndDate
        self.notes = notes
        self.colorHex = colorHex
        self.createdAt = createdAt
    }

    var monthlyPrice: Double {
        price / billingCycle.monthsFactor
    }

    var yearlyPrice: Double {
        monthlyPrice * 12
    }

    var cancellationScore: Double {
        monthlyPrice * usageFrequency.cancellationWeight
    }

    var daysUntilBilling: Int {
        let start = Calendar.current.startOfDay(for: .now)
        let end = Calendar.current.startOfDay(for: nextBillingDate)
        return max(0, Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0)
    }

    var isUpcomingSoon: Bool {
        daysUntilBilling <= 7
    }

    var currencySymbol: String {
        switch currency {
        case "KRW": return "₩"
        case "USD": return "$"
        case "EUR": return "€"
        case "JPY": return "¥"
        default: return currency
        }
    }

    func formattedPrice(_ amount: Double) -> String {
        switch currency {
        case "KRW", "JPY":
            return "\(currencySymbol)\(Int(amount).formatted())"
        default:
            return String(format: "\(currencySymbol)%.2f", amount)
        }
    }

    var displayPrice: String { formattedPrice(price) }
    var displayMonthlyPrice: String { formattedPrice(monthlyPrice) }
    var displayYearlyPrice: String { formattedPrice(yearlyPrice) }
}
