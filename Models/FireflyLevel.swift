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

// MARK: - Level-Up Celebration

import SwiftUI

struct LevelUpCelebrationView: View {
    let level: FireflyLevel
    let onDone: () -> Void

    @State private var shown = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.65).ignoresSafeArea()
                .onTapGesture { onDone() }
            ConfettiView()

            VStack(spacing: 18) {
                LumiMascotView(size: 72, message: nil)
                    .scaleEffect(shown ? 1.0 : 0.4)

                Text("Lumi grew brighter!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Level \(level.number) · \(level.name) \(level.emoji)")
                    .font(.title3.bold())
                    .foregroundStyle(.yellow)

                Text("Keep collecting Sleep Stars to help her shine.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .opacity(shown ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) { shown = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { onDone() }
        }
    }
}

// MARK: - Weekly Challenge
// Rotates by ISO week through the 7 themes: "Listen to 3 <Theme>
// stories this week." Progress computes straight from existing
// storiesReadDates — no new tracking needed. Completing it earns a
// bonus Sleep Star (once per week).

struct WeeklyChallenge {
    let category: StoryCategory
    let target = 3

    static var current: WeeklyChallenge {
        let week = Calendar.current.component(.weekOfYear, from: Date())
        let cats = StoryCategory.allCases
        return WeeklyChallenge(category: cats[week % cats.count])
    }

    static var weekStamp: String {
        let c = Calendar.current
        return "\(c.component(.yearForWeekOfYear, from: Date()))-w\(c.component(.weekOfYear, from: Date()))"
    }

    /// Stories of this week's theme finished since the week began.
    func progress(streak: ReadingStreak, stories: [Story]) -> Int {
        let cal = Calendar.current
        guard let weekStart = cal.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        let themed = Set(stories.filter { $0.category == category }.map(\.id))
        return streak.storiesReadDates.filter { themed.contains($0.key) && $0.value >= weekStart }.count
    }
}

struct WeeklyChallengeCard: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var library: StoryLibraryViewModel

    private var challenge: WeeklyChallenge { WeeklyChallenge.current }

    private var done: Int {
        min(challenge.progress(streak: readingStreak.streak, stories: library.stories), challenge.target)
    }

    private var rewardClaimed: Bool {
        UserDefaults.standard.string(forKey: "weeklyChallenge.claimed") == WeeklyChallenge.weekStamp
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("This Week's Challenge", systemImage: "flag.checkered")
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Spacer()
                if done >= challenge.target {
                    Text("Done! 🏆")
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                }
            }

            Text("Listen to \(challenge.target) \(challenge.category.rawValue) stories")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

            HStack(spacing: 8) {
                ForEach(0..<challenge.target, id: \.self) { i in
                    Image(systemName: i < done ? "star.fill" : "star")
                        .foregroundStyle(i < done ? .yellow : AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                Spacer()
                NavigationLink(destination: LibraryView(initialCategory: challenge.category)) {
                    Text("Find \(challenge.category.rawValue) stories →")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { claimIfDone() }
        .onChange(of: readingStreak.totalStoriesRead) { claimIfDone() }
    }

    private func claimIfDone() {
        guard done >= challenge.target, !rewardClaimed else { return }
        UserDefaults.standard.set(WeeklyChallenge.weekStamp, forKey: "weeklyChallenge.claimed")
        readingStreak.awardBonusStar()
    }
}
