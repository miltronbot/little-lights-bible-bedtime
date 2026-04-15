
import SwiftUI

struct StoryCardView: View {
    let story: Story

    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        HStack(spacing: 14) {
            StoryArtworkView(story: story, cornerRadius: 18)
                .frame(width: 72, height: 72)

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

                    if let ageGroup = story.ageGroup {
                        Text(ageGroup.shortLabel)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
            }
        }
        .padding()
        .background(AppTheme.cardBackground(for: appSettings.isBedtimeMode))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
