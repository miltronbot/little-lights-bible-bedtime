
import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject private var libraryViewModel: StoryLibraryViewModel
    @EnvironmentObject private var favoritesViewModel: FavoritesViewModel
    @EnvironmentObject private var appSettings: AppSettings

    private var favoriteStories: [Story] {
        libraryViewModel.stories.filter { favoritesViewModel.favoriteStoryIDs.contains($0.id) }
    }

    var body: some View {
        Group {
            if favoriteStories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "heart.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(.pink)
                    Text("No favorites yet")
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.primaryText(for: appSettings.isBedtimeMode))
                    Text("Tap the heart on any bedtime story to save it here for quick access at bedtime.")
                        .foregroundStyle(AppTheme.secondaryText(for: appSettings.isBedtimeMode))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { StarryNightBackground(alwaysStarry: true) }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(favoriteStories) { story in
                            StoryCardView(story: story)
                            .contextMenu {
                                Button(role: .destructive) {
                                    favoritesViewModel.removeFavorite(story)
                                } label: {
                                    Label("Remove Favorite", systemImage: "heart.slash")
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background { StarryNightBackground(alwaysStarry: true) }
            }
        }
        .navigationTitle("Favorites")
    }
}
