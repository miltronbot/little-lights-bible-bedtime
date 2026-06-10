
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
        // Story-count milestones
        if totalStoriesRead >= 1 { earnedBadges.insert("first-story") }
        if totalStoriesRead >= 3 { earnedBadges.insert("little-listener") }
        if totalStoriesRead >= 5 { earnedBadges.insert("bookworm") }
        if totalStoriesRead >= 10 { earnedBadges.insert("story-explorer") }
        if totalStoriesRead >= 15 { earnedBadges.insert("tale-traveler") }
        if totalStoriesRead >= 20 { earnedBadges.insert("story-collector") }
        if totalStoriesRead >= 25 { earnedBadges.insert("bible-scholar") }
        if totalStoriesRead >= 30 { earnedBadges.insert("scripture-star") }
        if totalStoriesRead >= 35 { earnedBadges.insert("wisdom-seeker") }
        if totalStoriesRead >= 40 { earnedBadges.insert("faith-filled") }
        if totalStoriesRead >= 45 { earnedBadges.insert("almost-home") }
        if totalStoriesRead >= 50 { earnedBadges.insert("master-reader") }

        // Streak milestones
        if currentStreak >= 2 { earnedBadges.insert("two-night-twinkle") }
        if currentStreak >= 3 { earnedBadges.insert("3-day-streak") }
        if currentStreak >= 5 { earnedBadges.insert("high-five") }
        if currentStreak >= 7 { earnedBadges.insert("week-warrior") }
        if currentStreak >= 10 { earnedBadges.insert("perfect-ten") }
        if currentStreak >= 14 { earnedBadges.insert("faithful-reader") }
        if currentStreak >= 21 { earnedBadges.insert("habit-hero") }
        if currentStreak >= 30 { earnedBadges.insert("devotion-champion") }
        if currentStreak >= 60 { earnedBadges.insert("diamond-devotion") }
        if currentStreak >= 100 { earnedBadges.insert("hundred-night-hero") }

        // Sleep Star milestones
        if totalSleepStars >= 10 { earnedBadges.insert("star-catcher") }
        if totalSleepStars >= 25 { earnedBadges.insert("star-gazer") }
        if totalSleepStars >= 50 { earnedBadges.insert("sky-full-of-stars") }

        // Moment badges — earned for when the reading happens
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 18 || hour < 5 { earnedBadges.insert("bedtime-believer") }
        if Calendar.current.isDateInWeekend(Date()) { earnedBadges.insert("weekend-wonder") }
    }

    static let badgeInfo: [String: (name: String, icon: String, description: String)] = [
        // Story-count milestones (12)
        "first-story": ("First Light", "star.fill", "Read your first story"),
        "little-listener": ("Little Listener", "headphones", "Read 3 stories"),
        "bookworm": ("Bookworm", "book.fill", "Read 5 stories"),
        "story-explorer": ("Story Explorer", "map.fill", "Read 10 stories"),
        "tale-traveler": ("Tale Traveler", "backpack.fill", "Read 15 stories"),
        "story-collector": ("Story Collector", "books.vertical.fill", "Read 20 stories"),
        "bible-scholar": ("Bible Scholar", "graduationcap.fill", "Read 25 stories"),
        "scripture-star": ("Scripture Star", "sparkles", "Read 30 stories"),
        "wisdom-seeker": ("Wisdom Seeker", "lightbulb.fill", "Read 35 stories"),
        "faith-filled": ("Faith Filled", "heart.circle.fill", "Read 40 stories"),
        "almost-home": ("Almost Home", "house.fill", "Read 45 stories"),
        "master-reader": ("Master Reader", "crown.fill", "Read all 50 stories"),

        // Streak milestones (10)
        "two-night-twinkle": ("Two-Night Twinkle", "moon.stars.fill", "2-day reading streak"),
        "3-day-streak": ("Getting Started", "flame.fill", "3-day reading streak"),
        "high-five": ("High Five", "hand.wave.fill", "5-day reading streak"),
        "week-warrior": ("Week Warrior", "bolt.fill", "7-day reading streak"),
        "perfect-ten": ("Perfect Ten", "10.circle.fill", "10-day reading streak"),
        "faithful-reader": ("Faithful Reader", "hands.sparkles.fill", "14-day reading streak"),
        "habit-hero": ("Habit Hero", "calendar", "21-day reading streak"),
        "devotion-champion": ("Devotion Champion", "trophy.fill", "30-day reading streak"),
        "diamond-devotion": ("Diamond Devotion", "diamond.fill", "60-day reading streak"),
        "hundred-night-hero": ("Hundred-Night Hero", "100.circle.fill", "100-day reading streak"),

        // Sleep Star milestones (3)
        "star-catcher": ("Star Catcher", "star.circle.fill", "Earn 10 Sleep Stars"),
        "star-gazer": ("Star Gazer", "binoculars.fill", "Earn 25 Sleep Stars"),
        "sky-full-of-stars": ("Sky Full of Stars", "sparkle", "Earn 50 Sleep Stars"),

        // Moment badges (2)
        "bedtime-believer": ("Bedtime Believer", "moon.zzz.fill", "Read a story at bedtime"),
        "weekend-wonder": ("Weekend Wonder", "sun.max.fill", "Read a story on the weekend"),
    ]
}
