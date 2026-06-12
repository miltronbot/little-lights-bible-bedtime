import AppIntents
import Foundation

// MARK: - Siri / Shortcuts / Spotlight
// "Hey Siri, play tonight's story in Firefly" — opens the app and starts
// Tonight's Story immediately. Also surfaces in Spotlight and the
// Shortcuts app automatically via the AppShortcutsProvider.

extension Notification.Name {
    static let playTonightsStory = Notification.Name("playTonightsStory")
}

struct PlayTonightsStoryIntent: AppIntent {
    static let title: LocalizedStringResource = "Play Tonight's Story"
    static let description = IntentDescription("Starts reading tonight's bedtime Bible story aloud.")
    static let openAppWhenRun = true

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .playTonightsStory, object: nil)
        return .result()
    }
}

struct FireflyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: PlayTonightsStoryIntent(),
            phrases: [
                "Play tonight's story in \(.applicationName)",
                "Start bedtime story in \(.applicationName)",
                "Read me a story in \(.applicationName)",
            ],
            shortTitle: "Tonight's Story",
            systemImageName: "moon.stars.fill"
        )
    }
}
