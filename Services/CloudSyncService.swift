import Foundation

// MARK: - Cloud Sync
// Mirrors the family's progress (children, streaks, collectibles,
// favorites) to iCloud's key-value store so a new phone restores
// everything automatically. No accounts, no servers, COPPA-clean —
// the data rides the family's own iCloud.
//
// Merge policy when local and cloud disagree:
// - favorites & collectibles: UNION (never lose an earned treasure)
// - streak: whichever side shows more total stories read
// - children list: local wins when non-empty, else cloud restores

enum CloudSync {
    private static let store = NSUbiquitousKeyValueStore.default
    private static let syncedBases = ["favoriteStoryIDs", "readingStreak", "CollectiblesManager.collectedIDs", "journeyProgress"]

    // MARK: Mirror up (called from each store's save path)

    static func mirror(_ value: Any?, forKey key: String) {
        guard let value else { store.removeObject(forKey: key); return }
        store.set(value, forKey: key)
        store.synchronize()
    }

    // MARK: Restore / merge down

    /// Merges cloud data into local UserDefaults. Safe to call repeatedly.
    static func syncDown() {
        store.synchronize()
        let defaults = UserDefaults.standard

        // Children list first — it defines the profile-scoped keys
        if let cloudNames = store.data(forKey: "childrenNames"),
           let decoded = try? JSONDecoder().decode([String].self, from: cloudNames),
           !decoded.isEmpty {
            let localNames = (defaults.data(forKey: "childrenNames"))
                .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []
            if localNames.isEmpty {
                defaults.set(cloudNames, forKey: "childrenNames")
            }
        }

        let names = (defaults.data(forKey: "childrenNames"))
            .flatMap { try? JSONDecoder().decode([String].self, from: $0) } ?? []
        let profiles = [""] + names

        for base in syncedBases {
            for profile in profiles {
                let key = ProfileScope.key(base, profile: profile)
                mergeKey(base: base, key: key, defaults: defaults)
            }
        }
    }

    private static func mergeKey(base: String, key: String, defaults: UserDefaults) {
        switch base {
        case "favoriteStoryIDs":
            // [String] — union
            let cloud = Set(store.array(forKey: key) as? [String] ?? [])
            let local = Set(defaults.stringArray(forKey: key) ?? [])
            guard !cloud.isEmpty else { return }
            let merged = cloud.union(local)
            if merged != local {
                defaults.set(Array(merged), forKey: key)
            }

        case "CollectiblesManager.collectedIDs":
            // Data(JSON Set<String>) — union
            let cloudSet: Set<String> = store.data(forKey: key)
                .flatMap { try? JSONDecoder().decode(Set<String>.self, from: $0) } ?? []
            guard !cloudSet.isEmpty else { return }
            let localSet: Set<String> = defaults.data(forKey: key)
                .flatMap { try? JSONDecoder().decode(Set<String>.self, from: $0) } ?? []
            let merged = cloudSet.union(localSet)
            if merged != localSet, let data = try? JSONEncoder().encode(merged) {
                defaults.set(data, forKey: key)
            }

        case "readingStreak":
            // Data(JSON ReadingStreak) — most progress wins
            guard let cloudData = store.data(forKey: key),
                  let cloud = try? JSONDecoder().decode(ReadingStreak.self, from: cloudData) else { return }
            let local: ReadingStreak? = defaults.data(forKey: key)
                .flatMap { try? JSONDecoder().decode(ReadingStreak.self, from: $0) }
            let cloudWins: Bool
            if let local {
                cloudWins = (cloud.totalStoriesRead, cloud.longestStreak) > (local.totalStoriesRead, local.longestStreak)
            } else {
                cloudWins = true
            }
            if cloudWins {
                defaults.set(cloudData, forKey: key)
            }

        case "journeyProgress":
            // Data(JSON [String: Set<Int>]) — union completed days per journey
            let cloudMap: [String: Set<Int>] = store.data(forKey: key)
                .flatMap { try? JSONDecoder().decode([String: Set<Int>].self, from: $0) } ?? [:]
            guard !cloudMap.isEmpty else { return }
            let localMap: [String: Set<Int>] = defaults.data(forKey: key)
                .flatMap { try? JSONDecoder().decode([String: Set<Int>].self, from: $0) } ?? [:]
            var merged = localMap
            for (journeyID, cloudDays) in cloudMap {
                merged[journeyID] = (merged[journeyID] ?? []).union(cloudDays)
            }
            if merged != localMap, let data = try? JSONEncoder().encode(merged) {
                defaults.set(data, forKey: key)
            }

        default:
            break
        }
    }
}
