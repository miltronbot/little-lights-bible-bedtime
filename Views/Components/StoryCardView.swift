
import SwiftUI

struct StoryCardView: View {
    let story: Story

    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel

    private var isThisPlaying: Bool {
        audioPlayer.currentStoryID == story.id && audioPlayer.isPlaying
    }

    private var isCompleted: Bool {
        readingStreak.streak.storiesReadDates.keys.contains(story.id)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Navigation covers the artwork + text; the play button is a
            // separate sibling so the two gestures never conflict
            NavigationLink(destination: StoryDetailView(story: story)) {
                cardContent
            }
            .buttonStyle(.plain)

            // Big friendly play button — little fingers can start the
            // story right from the list, no navigation needed
            Button {
                audioPlayer.togglePlayback(for: story)
            } label: {
                Image(systemName: isThisPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 38))
                    .foregroundStyle(AppTheme.accent(for: appSettings.isBedtimeMode))
                    .background(Circle().fill(.white).padding(6))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isThisPlaying ? "Pause \(story.title)" : "Play \(story.title)")
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var cardContent: some View {
        HStack(spacing: 14) {
            StoryArtworkView(story: story, cornerRadius: 18)
                .frame(width: 72, height: 72)
                .overlay(alignment: .topLeading) {
                    // Little star for stories the child has finished
                    if isCompleted {
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.yellow)
                            .padding(4)
                            .background(Circle().fill(Color.black.opacity(0.45)))
                            .offset(x: -5, y: -5)
                    }
                }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(story.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Spacer()

                    if favoritesViewModel.isFavorite(story) {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.pink)
                            .font(.caption)
                    }
                }

                Text(story.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Label(story.category.rawValue, systemImage: story.category.icon)
                    Text("\(story.listenDurationMinutes) min")
                }
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }

        }
    }
}
