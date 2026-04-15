
import SwiftUI

// MARK: - Parent Dashboard
// Sleep insights, reading history, and weekly summary for parents

struct ParentDashboardView: View {
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var viewModel: StoryLibraryViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Parent Dashboard")
                        .font(.title.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("Track your child's reading journey")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }

                // Weekly Summary Card
                WeeklySummaryCard()

                // Reading Consistency
                ConsistencyCard()

                // Favorite Categories
                FavoriteCategoriesCard()

                // Sleep Tips
                SleepTipsCard()

                // Reading History
                ReadingHistoryCard()
            }
            .padding()
        }
        .background(AppTheme.background(for: appSettings.isBedtimeMode))
        .navigationTitle("Parent Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Weekly Summary

struct WeeklySummaryCard: View {
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("This Week", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            HStack(spacing: 0) {
                WeekStatItem(
                    value: "\(readingStreak.currentStreak)",
                    label: "Day Streak",
                    icon: "flame.fill",
                    color: .orange
                )
                Divider().frame(height: 44)
                WeekStatItem(
                    value: "\(readingStreak.totalStoriesRead)",
                    label: "Stories Read",
                    icon: "book.fill",
                    color: AppTheme.accent(for: appSettings.isBedtimeMode)
                )
                Divider().frame(height: 44)
                WeekStatItem(
                    value: "\(readingStreak.sleepStars)",
                    label: "Sleep Stars",
                    icon: "star.fill",
                    color: .yellow
                )
            }

            // Weekly reading days indicator
            HStack(spacing: 6) {
                ForEach(weekdayLabels, id: \.self) { day in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(isActiveDay(day)
                                  ? AppTheme.accent(for: appSettings.isBedtimeMode)
                                  : AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.15))
                            .frame(width: 28, height: 28)
                            .overlay {
                                if isActiveDay(day) {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.white)
                                }
                            }
                        Text(day)
                            .font(.system(size: 10))
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var weekdayLabels: [String] {
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    }

    private func isActiveDay(_ day: String) -> Bool {
        // Show today and any previous days in the streak as active
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        guard let dayIndex = weekdayLabels.firstIndex(of: day) else { return false }
        let dayNumber = dayIndex + 1 // Calendar weekday is 1-indexed (Sun = 1)

        if dayNumber == today && readingStreak.isActiveToday {
            return true
        }

        // Show streak days
        if dayNumber < today {
            let daysBack = today - dayNumber
            return daysBack < readingStreak.currentStreak
        }

        return false
    }
}

struct WeekStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Consistency Card

struct ConsistencyCard: View {
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Reading Consistency", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            let consistency = calculateConsistency()

            VStack(spacing: 8) {
                HStack {
                    Text("Overall")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    Spacer()
                    Text("\(Int(consistency * 100))%")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AppTheme.accent(for: appSettings.isBedtimeMode).opacity(0.15))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.green, AppTheme.accent(for: appSettings.isBedtimeMode)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * consistency, height: 12)
                    }
                }
                .frame(height: 12)
            }

            Text(consistencyMessage(consistency))
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func calculateConsistency() -> Double {
        // Use current streak vs a 7-day window as simple consistency
        let streak = readingStreak.currentStreak
        return min(Double(streak) / 7.0, 1.0)
    }

    private func consistencyMessage(_ value: Double) -> String {
        if value >= 0.85 { return "Incredible! Your family has a wonderful bedtime routine." }
        if value >= 0.5 { return "Great progress! Consistency helps build healthy sleep habits." }
        if value > 0 { return "Keep it up! Try to read together every night this week." }
        return "Start a bedtime story tonight to build a reading habit!"
    }
}

// MARK: - Favorite Categories

struct FavoriteCategoriesCard: View {
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var viewModel: StoryLibraryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Favorite Themes", systemImage: "heart.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            // Show category distribution based on available stories
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(StoryCategory.allCases) { category in
                    let count = viewModel.stories.filter { $0.category == category }.count
                    HStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                            .frame(width: 24)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(category.rawValue)
                                .font(.caption.bold())
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            Text("\(count) stories")
                                .font(.caption2)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode).opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Sleep Tips

struct SleepTipsCard: View {
    @EnvironmentObject private var appSettings: AppSettings

    private let tips = [
        (icon: "moon.fill", tip: "Try to start bedtime stories at the same time each night for better sleep patterns."),
        (icon: "iphone.slash", tip: "Reduce screen brightness 30 minutes before bed — use Bedtime Mode for a warmer display."),
        (icon: "wind", tip: "Try the breathing exercise before the story to help your child relax."),
        (icon: "speaker.wave.2.fill", tip: "Ambient sounds like rain or ocean waves help children fall asleep faster."),
        (icon: "timer", tip: "The sleep timer gently fades audio so your child drifts off naturally."),
    ]

    @State private var currentTipIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Sleep Tip", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            let tip = tips[currentTipIndex % tips.count]
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: tip.icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .frame(width: 28)

                Text(tip.tip)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                withAnimation {
                    currentTipIndex += 1
                }
            } label: {
                Text("Next Tip")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            // Rotate tip based on day
            currentTipIndex = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) % tips.count
        }
    }
}

// MARK: - Reading History

struct ReadingHistoryCard: View {
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Milestones", systemImage: "trophy.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

            if readingStreak.earnedBadges.isEmpty {
                Text("Read your first story tonight to start earning milestones!")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    .padding(.vertical, 8)
            } else {
                ForEach(readingStreak.earnedBadges, id: \.id) { badge in
                    HStack(spacing: 12) {
                        Image(systemName: badge.info.icon)
                            .font(.title3)
                            .foregroundStyle(.yellow)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(badge.info.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                            Text(badge.info.description)
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        }

                        Spacer()

                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
