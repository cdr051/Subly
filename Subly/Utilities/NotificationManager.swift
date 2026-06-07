import Foundation
import UserNotifications

struct NotificationManager {
    static func schedule(for subscription: Subscription) {
        cancel(for: subscription)
        scheduleBillingAlert(for: subscription)
        if subscription.isTrial, let trialEnd = subscription.trialEndDate {
            scheduleTrialAlert(for: subscription, on: trialEnd)
        }
    }

    static func cancel(for subscription: Subscription) {
        let ids = [billingID(subscription), trialID(subscription)]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    private static func billingID(_ sub: Subscription) -> String { sub.id.uuidString + "_billing" }
    private static func trialID(_ sub: Subscription) -> String { sub.id.uuidString + "_trial" }

    private static func scheduleBillingAlert(for subscription: Subscription) {
        guard
            let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: subscription.nextBillingDate),
            dayBefore > .now
        else { return }

        let content = UNMutableNotificationContent()
        content.title = "내일 결제 예정"
        content.body = "\(subscription.name) \(subscription.displayPrice)이(가) 내일 결제됩니다."
        content.sound = .default

        scheduleNotification(id: billingID(subscription), content: content, on: dayBefore)
    }

    private static func scheduleTrialAlert(for subscription: Subscription, on trialEnd: Date) {
        guard
            let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: trialEnd),
            dayBefore > .now
        else { return }

        let content = UNMutableNotificationContent()
        content.title = "무료체험 종료 임박"
        content.body = "\(subscription.name) 무료체험이 내일 종료됩니다."
        content.sound = .default

        scheduleNotification(id: trialID(subscription), content: content, on: dayBefore)
    }

    private static func scheduleNotification(id: String, content: UNMutableNotificationContent, on date: Date) {
        let dc = Calendar.current.dateComponents([.year, .month, .day], from: date)
        var trigger = DateComponents()
        trigger.year = dc.year
        trigger.month = dc.month
        trigger.day = dc.day
        trigger.hour = 9
        trigger.minute = 0

        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }
}
