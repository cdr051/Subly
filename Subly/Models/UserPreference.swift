import Foundation
import SwiftData

@Model
final class UserPreference {
    var interestKeys: [String]
    var monthlyBudget: Double

    init(interestKeys: [String] = [], monthlyBudget: Double = 0) {
        self.interestKeys = interestKeys
        self.monthlyBudget = monthlyBudget
    }

    var interests: [Interest] {
        interestKeys.compactMap { Interest(rawValue: $0) }
    }

    func isSelected(_ interest: Interest) -> Bool {
        interestKeys.contains(interest.rawValue)
    }

    func toggle(_ interest: Interest) {
        let key = interest.rawValue
        if let idx = interestKeys.firstIndex(of: key) {
            interestKeys.remove(at: idx)
        } else {
            interestKeys.append(key)
        }
    }
}
