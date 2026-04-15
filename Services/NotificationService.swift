import UserNotifications
import SwiftUI

@MainActor
final class NotificationService: ObservableObject {
    @Published var isPermissionGranted = false
    @AppStorage("bedtimeReminderEnabled") var bedtimeReminderEnabled = false
    @AppStorage("bedtimeHour") var bedtimeHour = 19
    @AppStorage("bedtimeMinute") var bedtimeMinute = 30

    private let bedtimeReminderMessages = [
        "Time for a cozy Bible story tonight!",
        "Your bedtime adventure awaits!",
        "Let's snuggle up with a Bible story!",
        "Sweet dreams are calling... story time first!",
        "Settle in for tonight's Bible bedtime tale!",
        "It's time for your favorite Bible stories!"
    ]

    private let notificationIdentifier = "bedtime-reminder"

    func requestPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
                self.isPermissionGranted = granted
            } catch {
                #if DEBUG
                print("Error requesting notification permission: \(error)")
                #endif
                self.isPermissionGranted = false
            }
        }
    }

    func scheduleBedtimeReminder(at hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()

        // Remove any existing bedtime reminder
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Bedtime Story Time!"
        content.body = bedtimeReminderMessages.randomElement() ?? "Time for a cozy Bible story tonight!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "bedtimeReminder"

        // Create repeating trigger
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create request
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        // Schedule notification
        Task {
            do {
                try await center.add(request)
                #if DEBUG
                print("Bedtime reminder scheduled for \(hour):\(String(format: "%02d", minute))")
                #endif
            } catch {
                #if DEBUG
                print("Error scheduling bedtime reminder: \(error)")
                #endif
            }
        }
    }

    func cancelBedtimeReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
        #if DEBUG
        print("Bedtime reminder cancelled")
        #endif
    }

    func checkPermissionStatus() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let isGranted = settings.authorizationStatus == .authorized

        await MainActor.run {
            self.isPermissionGranted = isGranted
        }

        return isGranted
    }
}
