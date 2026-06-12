import Foundation

// MARK: - Firefly Levels
// Lumi grows brighter as the child earns Sleep Stars — a companion
// progression (the strongest engagement mechanic in faith apps for
// kids: a friend who grows with you, not a score).

struct FireflyLevel {
    let number: Int
    let name: String
    let emoji: String
    let starsRequired: Int

    static let all: [FireflyLevel] = [
        FireflyLevel(number: 1,  name: "Tiny Spark",        emoji: "✨",  starsRequired: 0),
        FireflyLevel(number: 2,  name: "Little Glow",       emoji: "🌟",  starsRequired: 5),
        FireflyLevel(number: 3,  name: "Night Light",       emoji: "🕯️",  starsRequired: 10),
        FireflyLevel(number: 4,  name: "Bright Beam",       emoji: "🔆",  starsRequired: 20),
        FireflyLevel(number: 5,  name: "Star Shine",        emoji: "⭐",  starsRequired: 35),
        FireflyLevel(number: 6,  name: "Moon Glow",         emoji: "🌙",  starsRequired: 55),
        FireflyLevel(number: 7,  name: "Radiant Light",     emoji: "☀️",  starsRequired: 80),
        FireflyLevel(number: 8,  name: "Guiding Star",      emoji: "🌠",  starsRequired: 110),
        FireflyLevel(number: 9,  name: "Dawn Bringer",      emoji: "🌅",  starsRequired: 150),
        FireflyLevel(number: 10, name: "Light of the World", emoji: "🏮", starsRequired: 200),
    ]

    static func level(forStars stars: Int) -> FireflyLevel {
        all.last(where: { stars >= $0.starsRequired }) ?? all[0]
    }

    static func next(after level: FireflyLevel) -> FireflyLevel? {
        all.first(where: { $0.number == level.number + 1 })
    }

    /// 0...1 progress from this level toward the next.
    static func progress(forStars stars: Int) -> Double {
        let current = level(forStars: stars)
        guard let next = next(after: current) else { return 1.0 }
        let span = Double(next.starsRequired - current.starsRequired)
        return min(1.0, Double(stars - current.starsRequired) / span)
    }
}

// MARK: - Tonight's Goals
// Three tiny nightly quests. Completing all three earns a bonus
// Sleep Star ("a Golden Night"). Date-stamped so they reset each day.

@MainActor
final class GoalsTracker: ObservableObject {
    @Published private(set) var versePracticedToday = false
    @Published private(set) var breathedToday = false
    @Published private(set) var bonusAwardedToday = false

    private var dayStamp: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    init() { refresh() }

    func refresh() {
        let d = UserDefaults.standard
        versePracticedToday = d.string(forKey: "goal.verse") == dayStamp
        breathedToday = d.string(forKey: "goal.breathe") == dayStamp
        bonusAwardedToday = d.string(forKey: "goal.bonus") == dayStamp
    }

    func markVersePracticed() {
        UserDefaults.standard.set(dayStamp, forKey: "goal.verse")
        versePracticedToday = true
    }

    func markBreathed() {
        UserDefaults.standard.set(dayStamp, forKey: "goal.breathe")
        breathedToday = true
    }

    /// Returns true the first time all goals complete today (award the bonus).
    func claimBonusIfEarned(storyListenedToday: Bool) -> Bool {
        refresh()
        guard storyListenedToday, versePracticedToday, breathedToday, !bonusAwardedToday else { return false }
        UserDefaults.standard.set(dayStamp, forKey: "goal.bonus")
        bonusAwardedToday = true
        return true
    }
}
