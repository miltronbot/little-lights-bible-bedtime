import SwiftUI

// MARK: - Reward Detail Sheets
// Tap any collectible or badge on the Rewards screen to learn how to earn
// it. Collectibles name the story that unlocks them; badges show their
// requirement and live progress toward it.

// MARK: Collection album

/// Tapping any collectible opens the full collection book: the tapped
/// treasure is featured up top with how-to-earn details, and every
/// collectible in the app is browsable in the grid below.
struct CollectionAlbumView: View {
    @State var selected: Collectible

    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var manager: CollectiblesManager
    @EnvironmentObject private var library: StoryLibraryViewModel
    @Environment(\.dismiss) private var dismiss

    private var isCollected: Bool { manager.hasCollected(selected.id) }

    private var storyTitle: String {
        library.stories.first { $0.id == selected.storyID }?.title ?? "its story"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Featured treasure
                    VStack(spacing: 10) {
                        Text(selected.emoji)
                            .font(.system(size: 64))
                            .opacity(isCollected ? 1.0 : 0.45)

                        Text(selected.name)
                            .font(.title3.bold())
                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                        if isCollected {
                            Label("Collected!", systemImage: "checkmark.seal.fill")
                                .font(.subheadline.bold())
                                .foregroundStyle(.green)
                            Text("You earned this by finishing \u{201C}\(storyTitle)\u{201D}. Well done!")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        } else {
                            Label("How to collect", systemImage: "lightbulb.fill")
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                            Text("Listen to \u{201C}\(storyTitle)\u{201D} all the way to the end, and this treasure is yours.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Every treasure in the collection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(manager.collectedCount) of \(Collectible.all.count) collected")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                            ForEach(Collectible.all) { collectible in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selected = collectible
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        Text(collectible.emoji)
                                            .font(.system(size: 30))
                                            .opacity(manager.hasCollected(collectible.id) ? 1.0 : 0.3)
                                        Text(collectible.name)
                                            .font(.system(size: 9, weight: .medium))
                                            .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                                            .lineLimit(1)
                                            .opacity(manager.hasCollected(collectible.id) ? 1.0 : 0.4)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                collectible.id == selected.id
                                                    ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                                    : (manager.hasCollected(collectible.id)
                                                        ? AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.35)
                                                        : Color.clear),
                                                lineWidth: collectible.id == selected.id ? 2 : 1
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.background(for: appSettings.isBedtimeMode))
            .navigationTitle("My Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: Badge detail

/// Identifiable selection wrapper for the badge grid.
struct SelectedBadge: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let earned: Bool
}

struct BadgeDetailSheet: View {
    let badge: SelectedBadge

    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @Environment(\.dismiss) private var dismiss

    // Progress targets per badge id — mirrors checkBadges() thresholds
    private enum Metric { case stories, streak, stars }
    private static let targets: [String: (target: Int, metric: Metric)] = [
        "first-story": (1, .stories), "little-listener": (3, .stories),
        "bookworm": (5, .stories), "story-explorer": (10, .stories),
        "tale-traveler": (15, .stories), "story-collector": (20, .stories),
        "bible-scholar": (25, .stories), "scripture-star": (30, .stories),
        "wisdom-seeker": (35, .stories), "faith-filled": (40, .stories),
        "almost-home": (45, .stories), "master-reader": (50, .stories),
        "two-night-twinkle": (2, .streak), "3-day-streak": (3, .streak),
        "high-five": (5, .streak), "week-warrior": (7, .streak),
        "perfect-ten": (10, .streak), "faithful-reader": (14, .streak),
        "habit-hero": (21, .streak), "devotion-champion": (30, .streak),
        "diamond-devotion": (60, .streak), "hundred-night-hero": (100, .streak),
        "star-catcher": (10, .stars), "star-gazer": (25, .stars),
        "sky-full-of-stars": (50, .stars),
    ]

    private var progress: (current: Int, target: Int, unit: String)? {
        guard let t = Self.targets[badge.id] else { return nil }
        switch t.metric {
        case .stories: return (readingStreak.totalStoriesRead, t.target, "stories")
        case .streak:  return (readingStreak.currentStreak, t.target, "nights in a row")
        case .stars:   return (readingStreak.sleepStars, t.target, "Sleep Stars")
        }
    }

    var body: some View {
        VStack(spacing: 18) {
            Text(badge.icon)
                .font(.system(size: 72))
                .opacity(badge.earned ? 1.0 : 0.45)
                .padding(.top, 28)

            Text(badge.name)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            if badge.earned {
                Label("Earned!", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
            } else {
                Label("How to earn", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
            }

            Text(badge.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

            if !badge.earned, let p = progress {
                VStack(spacing: 6) {
                    ProgressView(value: Double(min(p.current, p.target)), total: Double(p.target))
                        .tint(AppTheme.accent(for: appSettings.isBedtimeMode))
                    Text("\(min(p.current, p.target)) of \(p.target) \(p.unit)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                .padding(.horizontal, 8)
            }

            Button {
                dismiss()
            } label: {
                Text(badge.earned ? "Yay!" : "Got it")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.top, 6)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 28)
        .presentationDetents([.height(470)])
        .presentationBackground(AppTheme.background(for: appSettings.isBedtimeMode))
    }
}
