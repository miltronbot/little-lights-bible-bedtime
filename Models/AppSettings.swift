
import SwiftUI

@MainActor
final class AppSettings: ObservableObject {
    @AppStorage("isBedtimeMode") var isBedtimeMode: Bool = false
    @AppStorage("sleepTimerMinutes") var sleepTimerMinutes: Int = 0
    @AppStorage("selectedAmbientSound") var selectedAmbientSound: String = "none"
    @AppStorage("ambientVolume") var ambientVolume: Double = 0.3
    @AppStorage("narrationVolume") var narrationVolume: Double = 1.0
    @AppStorage("selectedAgeGroup") var selectedAgeGroup: String = ""
    @AppStorage("autoPlayNarration") var autoPlayNarration: Bool = false
    @AppStorage("fontSize") var fontSize: Double = 19.0
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("activeChildIndex") var activeChildIndex: Int = 0

    // ElevenLabs
    @AppStorage("elevenLabsAPIKey") var elevenLabsAPIKey: String = ""
    @AppStorage("selectedVoiceID") var selectedVoiceID: String = ElevenLabsVoice.defaultVoiceID

    var currentAgeGroup: AgeGroup? {
        get { AgeGroup(rawValue: selectedAgeGroup) }
        set { selectedAgeGroup = newValue?.rawValue ?? "" }
    }

    // MARK: - Children Names

    var childrenNames: [String] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "childrenNames"),
                  let names = try? JSONDecoder().decode([String].self, from: data) else {
                // Migrate from old single-name key
                if let oldName = UserDefaults.standard.string(forKey: "childName"), !oldName.isEmpty {
                    let names = [oldName]
                    saveChildrenNames(names)
                    return names
                }
                return []
            }
            return names
        }
        set {
            saveChildrenNames(newValue)
            // Also keep "childName" in sync for backward compatibility
            let active = activeChildName
            UserDefaults.standard.set(active, forKey: "childName")
            objectWillChange.send()
        }
    }

    var activeChildName: String {
        let names = childrenNames
        guard !names.isEmpty else { return "" }
        let index = min(activeChildIndex, names.count - 1)
        return names[max(0, index)]
    }

    func addChild(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var names = childrenNames
        guard names.count < 4 else { return }
        names.append(name.trimmingCharacters(in: .whitespaces))
        childrenNames = names
    }

    func removeChild(at index: Int) {
        var names = childrenNames
        guard index >= 0, index < names.count else { return }
        names.remove(at: index)
        childrenNames = names
        if activeChildIndex >= names.count {
            activeChildIndex = max(0, names.count - 1)
        }
    }

    func switchToChild(at index: Int) {
        guard index >= 0, index < childrenNames.count else { return }
        activeChildIndex = index
        UserDefaults.standard.set(activeChildName, forKey: "childName")
        objectWillChange.send()
    }

    private func saveChildrenNames(_ names: [String]) {
        guard let data = try? JSONEncoder().encode(names) else { return }
        UserDefaults.standard.set(data, forKey: "childrenNames")
    }
}
