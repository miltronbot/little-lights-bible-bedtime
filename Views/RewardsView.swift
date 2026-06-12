
import SwiftUI

struct RewardsView: View {
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @State private var selectedBadge: SelectedBadge?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Sleep Stars Header
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(systemName: "star.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.yellow)
                    }

                    Text("\(readingStreak.sleepStars)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                    Text("Sleep Stars")
                        .font(.title3)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                    Text("Earn stars by reading stories each night!")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                }
                .padding(.top)

                // Stats Row
                HStack(spacing: 0) {
                    StatBox(
                        icon: "flame.fill",
                        iconColor: .orange,
                        value: "\(readingStreak.currentStreak)",
                        label: "Current Streak"
                    )
                    Divider().frame(height: 50)
                    StatBox(
                        icon: "trophy.fill",
                        iconColor: .yellow,
                        value: "\(readingStreak.longestStreak)",
                        label: "Best Streak"
                    )
                    Divider().frame(height: 50)
                    StatBox(
                        icon: "book.fill",
                        iconColor: AppTheme.accent(for: appSettings.isBedtimeMode),
                        value: "\(readingStreak.totalStoriesRead)",
                        label: "Total Read"
                    )
                }
                .padding()
                .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                // Collectibles Showcase
                CollectiblesShowcaseView()

                // Badges Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Badges")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))

                    Text("Tap any badge to see how to earn it")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))

                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 14) {
                        ForEach(readingStreak.allBadges, id: \.id) { badge in
                            Button {
                                selectedBadge = SelectedBadge(
                                    id: badge.id,
                                    name: badge.info.name,
                                    icon: badge.info.icon,
                                    description: badge.info.description,
                                    earned: badge.earned
                                )
                            } label: {
                                BadgeView(
                                    name: badge.info.name,
                                    icon: badge.info.icon,
                                    description: badge.info.description,
                                    earned: badge.earned
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityHint("Shows how to earn this badge")
                        }
                    }
                }
                .sheet(item: $selectedBadge) { badge in
                    BadgeDetailSheet(badge: badge)
                }

                // Encouragement
                VStack(spacing: 8) {
                    if readingStreak.currentStreak == 0 {
                        Text("Start your reading streak tonight!")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    } else if readingStreak.currentStreak < 7 {
                        Text("Keep going! \(7 - readingStreak.currentStreak) more nights to earn the Week Warrior badge!")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Amazing dedication! You're a faithful reader!")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    }
                }
                .padding()
            }
            .padding()
        }
        .background {
            StarryNightBackground(alwaysStarry: true)
        }
        .navigationTitle("Rewards")
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Badge View

// Card styling matches CollectibleItemView so badges and collectibles
// share one visual language: emoji on a rounded card, dimmed until
// earned, accent ring when earned.
struct BadgeView: View {
    let name: String
    let icon: String
    let description: String
    let earned: Bool
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 36))
                .opacity(earned ? 1.0 : 0.3)

            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .opacity(earned ? 1.0 : 0.3)
        }
        .frame(maxWidth: .infinity, minHeight: 84)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    earned ? AppTheme.accent(for: appSettings.isBedtimeMode) : Color.clear,
                    lineWidth: 2
                )
        )
    }
}
