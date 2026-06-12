
import Foundation

@MainActor
final class ReadingStreakViewModel: ObservableObject {
    @Published private(set) var streak: ReadingStreak = ReadingStreak()
    @Published var showNewBadgeAlert: Bool = false
    @Published var newBadgeID: String?

    private var profileName: String = ""
    private var storageKey: String { ProfileScope.key("readingStreak", profile: profileName) }

    init() {
        loadStreak()
    }

    func setProfile(_ name: String) {
        guard name != profileName else { return }
        profileName = name
        showNewBadgeAlert = false
        newBadgeID = nil
        loadStreak()
    }

    var sleepStars: Int { streak.totalSleepStars }
    var currentStreak: Int { streak.currentStreak }
    var longestStreak: Int { streak.longestStreak }
    var totalStoriesRead: Int { streak.totalStoriesRead }

    var isActiveToday: Bool {
        guard let lastDate = streak.lastReadDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }

    var earnedBadges: [(id: String, info: (name: String, icon: String, description: String))] {
        streak.earnedBadges.compactMap { badgeID in
            guard let info = ReadingStreak.badgeInfo[badgeID] else { return nil }
            return (id: badgeID, info: info)
        }.sorted { $0.id < $1.id }
    }

    var allBadges: [(id: String, info: (name: String, icon: String, description: String), earned: Bool)] {
        ReadingStreak.badgeInfo.map { (id, info) in
            (id: id, info: info, earned: streak.earnedBadges.contains(id))
        }.sorted { $0.id < $1.id }
    }

    func recordStoryRead(storyID: String) {
        let previousBadges = streak.earnedBadges
        streak.recordStoryRead(storyID: storyID)
        saveStreak()

        // Check for newly earned badges
        let newBadges = streak.earnedBadges.subtracting(previousBadges)
        if let firstNew = newBadges.first {
            newBadgeID = firstNew
            showNewBadgeAlert = true
        }
    }

    func resetAll() {
        streak = ReadingStreak()
        showNewBadgeAlert = false
        newBadgeID = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func loadStreak() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(ReadingStreak.self, from: data) else {
            streak = ReadingStreak()
            return
        }
        streak = decoded
    }

    private func saveStreak() {
        guard let data = try? JSONEncoder().encode(streak) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        CloudSync.mirror(data, forKey: storageKey)
    }

    /// Re-reads from storage (after a cloud merge).
    func reload() { loadStreak() }
}
