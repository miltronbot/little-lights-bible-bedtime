
import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favoriteStoryIDs: Set<String> = []

    private let storageKey = "favoriteStoryIDs"

    init() { loadFavorites() }

    func isFavorite(_ story: Story) -> Bool {
        favoriteStoryIDs.contains(story.id)
    }

    func toggleFavorite(_ story: Story) {
        if favoriteStoryIDs.contains(story.id) {
            favoriteStoryIDs.remove(story.id)
        } else {
            favoriteStoryIDs.insert(story.id)
        }
        saveFavorites()
    }

    func removeFavorite(_ story: Story) {
        favoriteStoryIDs.remove(story.id)
        saveFavorites()
    }

    private func loadFavorites() {
        let savedIDs = UserDefaults.standard.stringArray(forKey: storageKey) ?? []
        favoriteStoryIDs = Set(savedIDs)
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteStoryIDs), forKey: storageKey)
    }
}
