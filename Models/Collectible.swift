import Foundation

struct Collectible: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let storyID: String

    // One collectible per story — 50 total
    static let all: [Collectible] = [
        Collectible(id: "dove", name: "Noah's Dove", emoji: "🕊️", storyID: "noah-big-boat"),
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
        Collectible(id: "gift", name: "Golden Gift", emoji: "🎁", storyID: "the-wise-men"),
        Collectible(id: "angel", name: "Christmas Angel", emoji: "👼", storyID: "christmas-the-birth-of-jesus"),
        Collectible(id: "tree", name: "Sycamore Tree", emoji: "🌳", storyID: "zacchaeus"),
        Collectible(id: "hug", name: "Warm Welcome", emoji: "🤗", storyID: "jesus-loves-the-children"),
        Collectible(id: "ring", name: "Father's Ring", emoji: "💍", storyID: "the-prodigal-son"),
        Collectible(id: "crown", name: "Esther's Crown", emoji: "👑", storyID: "esthers-courage"),
        Collectible(id: "trumpet", name: "Jericho Trumpet", emoji: "🎺", storyID: "joshua-and-jericho"),
        Collectible(id: "breeze", name: "Gentle Breeze", emoji: "🍃", storyID: "elijah-and-the-whisper"),
        Collectible(id: "lamp", name: "Temple Lamp", emoji: "🪔", storyID: "the-boy-samuel"),
        Collectible(id: "stars", name: "Promise Stars", emoji: "🌌", storyID: "abraham-and-the-stars"),
        Collectible(id: "wheat", name: "Golden Wheat", emoji: "🌾", storyID: "ruth-and-naomi"),
        Collectible(id: "bush", name: "Burning Bush", emoji: "🔥", storyID: "moses-and-the-burning-bush"),
        Collectible(id: "wave", name: "Parted Wave", emoji: "🌊", storyID: "the-walls-of-water"),
        Collectible(id: "ladder", name: "Dream Ladder", emoji: "🪜", storyID: "jacobs-ladder-dream"),
        Collectible(id: "candle", name: "Brave Candle", emoji: "🕯️", storyID: "gideons-brave-300"),
        Collectible(id: "raven", name: "Faithful Raven", emoji: "🐦‍⬛", storyID: "elijah-and-the-ravens"),
        Collectible(id: "friends", name: "Brave Friends", emoji: "🤝", storyID: "shadrach-meshach-abednego"),
        Collectible(id: "prayer", name: "Answered Prayer", emoji: "🙏", storyID: "hannahs-prayer"),
        Collectible(id: "blossom", name: "Eden Blossom", emoji: "🌺", storyID: "the-garden-of-eden"),
        Collectible(id: "brothers", name: "Brothers' Hug", emoji: "🫂", storyID: "joseph-forgives-brothers"),
        Collectible(id: "tambourine", name: "Miriam's Tambourine", emoji: "🪘", storyID: "miriams-song"),
        Collectible(id: "brick", name: "Strong Brick", emoji: "🧱", storyID: "nehemiah-builds-wall"),
        Collectible(id: "song", name: "Shepherd's Song", emoji: "🎶", storyID: "david-shepherd-boy"),
        Collectible(id: "scroll", name: "Wisdom Scroll", emoji: "📜", storyID: "solomon-asks-wisdom"),
        Collectible(id: "footprints", name: "Water Footprints", emoji: "👣", storyID: "jesus-walks-on-water"),
        Collectible(id: "seed", name: "Tiny Seed", emoji: "🌱", storyID: "the-mustard-seed"),
        Collectible(id: "sunrise", name: "Morning Light", emoji: "🌅", storyID: "jesus-heals-the-blind-man"),
        Collectible(id: "sunflower", name: "Good Soil", emoji: "🌻", storyID: "the-sower-and-the-seeds"),
        Collectible(id: "teapot", name: "Quiet Moment", emoji: "🫖", storyID: "mary-and-martha"),
        Collectible(id: "thanks", name: "Thankful Heart", emoji: "💛", storyID: "the-ten-lepers"),
        Collectible(id: "olive", name: "Olive Branch", emoji: "🫒", storyID: "jesus-in-the-garden-of-gethsemane"),
        Collectible(id: "dawn", name: "Easter Sunrise", emoji: "🌄", storyID: "the-empty-tomb"),
        Collectible(id: "anchor", name: "Brave Anchor", emoji: "⚓", storyID: "peter-walks-on-water"),
        Collectible(id: "coins", name: "Two Small Coins", emoji: "🪙", storyID: "the-widows-offering"),
        Collectible(id: "water", name: "Living Water", emoji: "💧", storyID: "jesus-and-the-woman-at-the-well"),
        Collectible(id: "treasure", name: "Hidden Treasure", emoji: "💎", storyID: "the-talents"),
        Collectible(id: "basin", name: "Servant's Basin", emoji: "🪣", storyID: "jesus-washes-the-disciples-feet"),
        Collectible(id: "lantern", name: "Glowing Lantern", emoji: "🏮", storyID: "the-light-of-the-world"),
    ]
}

@MainActor
final class CollectiblesManager: ObservableObject {
    @Published private(set) var collectedIDs: Set<String> = []

    // Transient: set when a story is completed for the first time so the
    // detail view can present the celebration overlay. Not persisted.
    @Published var celebrationStoryID: String?

    private var profileName: String = ""
    private var userDefaultsKey: String { ProfileScope.key("CollectiblesManager.collectedIDs", profile: profileName) }

    init() {
        loadCollectedIDs()
    }

    func setProfile(_ name: String) {
        guard name != profileName else { return }
        profileName = name
        celebrationStoryID = nil
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
        CloudSync.mirror(data, forKey: userDefaultsKey)
    }

    /// Re-reads from storage (after a cloud merge).
    func reload() { loadCollectedIDs() }
}
