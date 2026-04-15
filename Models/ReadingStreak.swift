
import Foundation

struct ReadingStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var totalStoriesRead: Int = 0
    var totalSleepStars: Int = 0
    var lastReadDate: Date?
    var storiesReadToday: Set<String> = []
    var storiesReadDates: [String: Date] = [:]

    // Sleep Stars earned for milestones
    var earnedBadges: Set<String> = []

    mutating func recordStoryRead(storyID: String) {
        let today = Calendar.current.startOfDay(for: Date())

        // Reset today's stories first so isNewStoryToday reflects the correct day
        if let lastDate = lastReadDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            if lastDay != today {
                storiesReadToday = []
            }
        }

        let isNewStoryToday = !storiesReadToday.contains(storyID)
        storiesReadToday.insert(storyID)
        storiesReadDates[storyID] = Date()

        if isNewStoryToday {
            totalStoriesRead += 1
            totalSleepStars += 1
        }

        // Update streak
        if let lastDate = lastReadDate {
            let lastDay = Calendar.current.startOfDay(for: lastDate)
            guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) else { return }
            let yesterdayStart = Calendar.current.startOfDay(for: yesterday)

            if lastDay == today {
                // Same day, streak unchanged
            } else if lastDay == yesterdayStart {
                // Consecutive day
                currentStreak += 1
            } else {
                // Streak broken
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }

        longestStreak = max(longestStreak, currentStreak)
        lastReadDate = Date()

        // Check for milestone badges
        checkBadges()
    }

    private mutating func checkBadges() {
        if totalStoriesRead >= 1 { earnedBadges.insert("first-story") }
        if totalStoriesRead >= 5 { earnedBadges.insert("bookworm") }
        if totalStoriesRead >= 10 { earnedBadges.insert("story-explorer") }
        if totalStoriesRead >= 25 { earnedBadges.insert("bible-scholar") }
        if totalStoriesRead >= 50 { earnedBadges.insert("master-reader") }
        if currentStreak >= 3 { earnedBadges.insert("3-day-streak") }
        if currentStreak >= 7 { earnedBadges.insert("week-warrior") }
        if currentStreak >= 14 { earnedBadges.insert("faithful-reader") }
        if currentStreak >= 30 { earnedBadges.insert("devotion-champion") }
    }

    static let badgeInfo: [String: (name: String, icon: String, description: String)] = [
        "first-story": ("First Light", "star.fill", "Read your first story"),
        "bookworm": ("Bookworm", "book.fill", "Read 5 stories"),
        "story-explorer": ("Story Explorer", "map.fill", "Read 10 stories"),
        "bible-scholar": ("Bible Scholar", "graduationcap.fill", "Read 25 stories"),
        "master-reader": ("Master Reader", "crown.fill", "Read all 50 stories"),
        "3-day-streak": ("Getting Started", "flame.fill", "3-day reading streak"),
        "week-warrior": ("Week Warrior", "bolt.fill", "7-day reading streak"),
        "faithful-reader": ("Faithful Reader", "hands.sparkles.fill", "14-day reading streak"),
        "devotion-champion": ("Devotion Champion", "trophy.fill", "30-day reading streak"),
    ]
}
