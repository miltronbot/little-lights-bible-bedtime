
import Foundation

// Profile-scoped UserDefaults keys: each child keeps their own favorites,
// streak, and collectibles. Empty profile name → legacy unscoped key.
enum ProfileScope {
    static func key(_ base: String, profile: String) -> String {
        profile.isEmpty ? base : "\(base).profile-\(profile)"
    }
}

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favoriteStoryIDs: Set<String> = []

    private var profileName: String = ""
    private var storageKey: String { ProfileScope.key("favoriteStoryIDs", profile: profileName) }

    init() { loadFavorites() }

    func setProfile(_ name: String) {
        guard name != profileName else { return }
        profileName = name
        loadFavorites()
    }

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
