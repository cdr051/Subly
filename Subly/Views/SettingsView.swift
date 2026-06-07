import SwiftUI
import UserNotifications

struct SettingsView: View {
    @AppStorage("defaultCurrency") private var defaultCurrency = "KRW"
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        NavigationStack {
            List {
                currencySection
                notificationSection
                aboutSection
            }
            .navigationTitle("설정")
            .task { await checkNotificationStatus() }
        }
    }

    // MARK: - Sections

    private var currencySection: some View {
        Section("기본 설정") {
            Picker("기본 통화", selection: $defaultCurrency) {
                Text("₩ 원화 (KRW)").tag("KRW")
                Text("$ 달러 (USD)").tag("USD")
                Text("€ 유로 (EUR)").tag("EUR")
                Text("¥ 엔화 (JPY)").tag("JPY")
            }
        }
    }

    private var notificationSection: some View {
        Section("알림") {
            HStack {
                Label("결제 알림", systemImage: "bell.badge.fill")
                Spacer()
                notificationStatusBadge
            }

            if notificationStatus == .denied {
                Button {
                    openSystemSettings()
                } label: {
                    Label("시스템 설정에서 허용하기", systemImage: "arrow.up.right.square")
                        .font(.subheadline)
                }
            }

            Text("결제 하루 전에 알림을 받아요. 무료체험 종료 하루 전에도 알려드려요.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var aboutSection: some View {
        Section("앱 정보") {
            HStack {
                Label("버전", systemImage: "info.circle")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("개발", systemImage: "hammer.fill")
                Spacer()
                Text("Subly")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Notification Status Badge

    private var notificationStatusBadge: some View {
        Group {
            switch notificationStatus {
            case .authorized:
                Label("허용됨", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            case .denied:
                Label("거부됨", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            default:
                Label("미설정", systemImage: "questionmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run { notificationStatus = settings.authorizationStatus }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
