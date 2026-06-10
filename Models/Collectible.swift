import Foundation

struct Collectible: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let storyID: String

    static let all: [Collectible] = [
        Collectible(id: "rainbow", name: "Rainbow Fragment", emoji: "🌈", storyID: "noah-big-boat"),
        Collectible(id: "sling", name: "David's Sling", emoji: "🪨", storyID: "david-and-goliath"),
        Collectible(id: "heart", name: "Kind Heart", emoji: "💝", storyID: "the-good-samaritan"),
        Collectible(id: "lion", name: "Gentle Lion", emoji: "🦁", storyID: "daniel-and-the-lions"),
        Collectible(id: "flower", name: "First Flower", emoji: "🌸", storyID: "creation-story"),
        Collectible(id: "boat", name: "Little Boat", emoji: "⛵", storyID: "jesus-calms-the-storm"),
        Collectible(id: "sheep", name: "Lost Sheep", emoji: "🐑", storyID: "the-lost-sheep"),
        Collectible(id: "star", name: "Bethlehem Star", emoji: "⭐", storyID: "the-birth-of-jesus"),
        Collectible(id: "fish", name: "Big Fish", emoji: "🐋", storyID: "jonah-and-the-big-fish"),
        Collectible(id: "basket", name: "Baby Basket", emoji: "🧺", storyID: "baby-moses"),
        Collectible(id: "coat", name: "Colorful Coat", emoji: "🧥", storyID: "joseph-and-his-colorful-coat"),
        Collectible(id: "bread", name: "Miracle Bread", emoji: "🍞", storyID: "feeding-the-five-thousand"),
    ]
}

@MainActor
final class CollectiblesManager: ObservableObject {
    @Published private(set) var collectedIDs: Set<String> = []

    // Transient: set when a story is completed for the first time so the
    // detail view can present the celebration overlay. Not persisted.
    @Published var celebrationStoryID: String?

    private let userDefaultsKey = "CollectiblesManager.collectedIDs"

    init() {
        loadCollectedIDs()
    }

    var collectedCount: Int {
        collectedIDs.count
    }

    func collect(_ collectible: Collectible) {
        guard !collectedIDs.contains(collectible.id) else { return }
        collectedIDs.insert(collectible.id)
        saveCollectedIDs()
    }

    func hasCollected(_ id: String) -> Bool {
        collectedIDs.contains(id)
    }

    func collectibleForStory(_ storyID: String) -> Collectible? {
        Collectible.all.first { $0.storyID == storyID }
    }

    func resetAll() {
        collectedIDs = []
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    private func loadCollectedIDs() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            collectedIDs = []
            return
        }
        do {
            let ids = try JSONDecoder().decode(Set<String>.self, from: data)
            collectedIDs = ids
        } catch {
            collectedIDs = []
        }
    }

    private func saveCollectedIDs() {
        guard let data = try? JSONEncoder().encode(collectedIDs) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
}
