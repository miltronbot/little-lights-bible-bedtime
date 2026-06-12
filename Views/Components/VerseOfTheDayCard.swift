import SwiftUI

// MARK: - Verse of the Day
// A daily-rotating memory verse on Home, drawn from the 45 stories that
// carry one. Deterministic by day-of-year so the whole family sees the
// same verse all day. Tapping opens the verse's story.

struct VerseOfTheDayCard: View {
    @EnvironmentObject private var library: StoryLibraryViewModel
    @EnvironmentObject private var appSettings: AppSettings

    private var todaysStory: Story? {
        let candidates = library.stories.filter { ($0.memoryVerse ?? "").isEmpty == false }
        guard !candidates.isEmpty else { return nil }
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return candidates[day % candidates.count]
    }

    var body: some View {
        if let story = todaysStory, let verse = story.memoryVerse {
            NavigationLink(destination: StoryDetailView(story: story)) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Verse of the Day", systemImage: "sun.and.horizon.fill")
                            .font(.subheadline.bold())
                            .foregroundStyle(.yellow)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }

                    Text(verse)
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                        .fixedSize(horizontal: false, vertical: true)

                    Text("from \u{201C}\(story.title)\u{201D}")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.16, green: 0.22, blue: 0.22), Color(red: 0.08, green: 0.14, blue: 0.16)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.yellow.opacity(0.25), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Story Postcard
// A shareable keepsake image: story artwork, memory verse, and the app
// name — perfect for sending to grandparents. Rendered offscreen with
// ImageRenderer at 1080×1350.

struct PostcardView: View {
    let story: Story

    var body: some View {
        ZStack(alignment: .bottom) {
            if let ui = UIImage(named: story.id) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 1080, height: 1350)
                    .clipped()
            } else {
                Color(red: 0.05, green: 0.13, blue: 0.16)
                    .frame(width: 1080, height: 1350)
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .center, endPoint: .bottom
            )

            VStack(spacing: 22) {
                Text(story.title)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                if let verse = story.memoryVerse, !verse.isEmpty {
                    Text(verse)
                        .font(.system(size: 34, weight: .medium, design: .serif))
                        .italic()
                        .foregroundStyle(.white.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                }

                Text("✨ FireFly: Bible Bedtime Stories")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.yellow.opacity(0.9))
            }
            .padding(.bottom, 70)
        }
        .frame(width: 1080, height: 1350)
    }
}

enum PostcardRenderer {
    @MainActor
    static func render(story: Story) -> UIImage? {
        let renderer = ImageRenderer(content: PostcardView(story: story))
        renderer.scale = 1
        return renderer.uiImage
    }
}

// MARK: - Tonight's Goals
// Three tiny nightly quests; completing all three earns a bonus Sleep
// Star (a "Golden Night"). Resets each day.

struct TonightsGoalsCard: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var goals: GoalsTracker
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel

    private var storyDone: Bool {
        !readingStreak.streak.storiesReadToday.isEmpty && readingStreak.isActiveToday
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Tonight's Goals", systemImage: "checklist")
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                Spacer()
                if goals.bonusAwardedToday {
                    Text("Golden Night! ⭐")
                        .font(.caption.bold())
                        .foregroundStyle(.yellow)
                }
            }

            goalRow(done: storyDone, icon: "headphones", text: "Listen to a story")
            goalRow(done: goals.versePracticedToday, icon: "text.quote", text: "Practice a verse")
            goalRow(done: goals.breathedToday, icon: "wind", text: "Breathe with Lumi")

            if !goals.bonusAwardedToday {
                Text("Finish all three for a bonus Sleep Star!")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onAppear { checkBonus() }
        .onChange(of: goals.versePracticedToday) { checkBonus() }
        .onChange(of: goals.breathedToday) { checkBonus() }
        .onChange(of: readingStreak.totalStoriesRead) { checkBonus() }
    }

    private func checkBonus() {
        if goals.claimBonusIfEarned(storyListenedToday: storyDone) {
            readingStreak.awardBonusStar()
        }
    }

    @ViewBuilder
    private func goalRow(done: Bool, icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? .green : AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            Image(systemName: icon)
                .font(.caption)
                .frame(width: 18)
                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .strikethrough(done, color: .green)
            Spacer()
        }
    }
}

// MARK: - Tonight's Goals screen
// The goals card moved from the Home scroll into the side menu (owner
// request June 2026); this is its destination screen. The card keeps all
// of its own bonus-claim logic, so it works the same from here.

struct TonightsGoalsView: View {
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                TonightsGoalsCard()

                Text("Finish all three quests in one night for a bonus Sleep Star — a Golden Night!")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    .padding(.horizontal)
            }
            .padding()
        }
        .background { StarryNightBackground(alwaysStarry: true) }
        .navigationTitle("Tonight's Goals")
        .navigationBarTitleDisplayMode(.inline)
    }
}
