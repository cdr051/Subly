//
//  SublyApp.swift
//  Subly
//
//  Created by Choi Dongryeol on 6/7/26.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct SublyApp: App {
    init() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [Subscription.self, UserPreference.self])
    }
}
