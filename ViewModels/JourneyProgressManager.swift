
import Foundation

// MARK: - Journey Progress
// Per-child progress through the 7-Day Journeys. Each child keeps their
// own completed-day set per journey (profile-scoped keys, mirrored to
// iCloud) — same pattern as Favorites / Collectibles.
//
// Storage shape under base key "journeyProgress":
//   [journeyID: [completed day numbers]]   (days are 1...7)

@MainActor
final class JourneyProgressManager: ObservableObject {
    // journeyID -> set of completed day numbers (1...7)
    @Published private(set) var progress: [String: Set<Int>] = [:]

    private var profileName: String = ""
    private var storageKey: String { ProfileScope.key("journeyProgress", profile: profileName) }

    init() { loadProgress() }

    func setProfile(_ name: String) {
        guard name != profileName else { return }
        profileName = name
        loadProgress()
    }

    // MARK: Queries

    func completedDays(forJourney journeyID: String) -> Set<Int> {
        progress[journeyID] ?? []
    }

    /// The next unfinished day (1...7). Returns 8 when every day is done.
    func currentDay(forJourney journeyID: String) -> Int {
        let done = completedDays(forJourney: journeyID)
        for day in 1...7 where !done.contains(day) {
            return day
        }
        return 8
    }

    func isComplete(_ journey: Journey) -> Bool {
        completedDays(forJourney: journey.id).count >= journey.storyIDs.count
    }

    // MARK: Mutations

    func markDayComplete(journeyID: String, day: Int) {
        guard (1...7).contains(day) else { return }
        var days = progress[journeyID] ?? []
        guard !days.contains(day) else { return }
        days.insert(day)
        progress[journeyID] = days
        saveProgress()
    }

    // MARK: Persistence

    private func loadProgress() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            progress = [:]
            return
        }
        do {
            let decoded = try JSONDecoder().decode([String: Set<Int>].self, from: data)
            progress = decoded
        } catch {
            progress = [:]
        }
    }

    private func saveProgress() {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        CloudSync.mirror(data, forKey: storageKey)
    }

    /// Re-reads from storage (after a cloud merge).
    func reload() { loadProgress() }
}
