
import SwiftUI

@main
struct LittleLightsBibleBedtimeApp: App {
    @StateObject private var libraryViewModel = StoryLibraryViewModel()
    @StateObject private var purchaseViewModel = PurchaseViewModel()
    @StateObject private var favoritesViewModel = FavoritesViewModel()
    @StateObject private var appSettings = AppSettings()
    @StateObject private var audioPlayerViewModel = AudioPlayerViewModel()
    @StateObject private var readingStreakViewModel = ReadingStreakViewModel()
    @StateObject private var collectiblesManager = CollectiblesManager()

    init() {
        // Configure audio session once at startup — must happen before any playback attempt
        AudioPlaybackService.configureAudioSession()

        // Customize tab bar appearance for bedtime mode
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appSettings.hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView(hasCompletedOnboarding: $appSettings.hasCompletedOnboarding)
                }
            }
            .environmentObject(libraryViewModel)
            .environmentObject(purchaseViewModel)
            .environmentObject(favoritesViewModel)
            .environmentObject(appSettings)
            .environmentObject(audioPlayerViewModel)
            .environmentObject(readingStreakViewModel)
            .environmentObject(collectiblesManager)
            .onAppear {
                // Restore any iCloud progress, then point stores at the
                // active child
                CloudSync.syncDown()
                // One-time: move pre-profile data under the first child's scope
                migrateLegacyDataToFirstProfileIfNeeded()
                applyActiveProfile()
                reloadStores()

                // Sync saved volume settings with audio player
                audioPlayerViewModel.narrationVolume = Float(appSettings.narrationVolume)
                audioPlayerViewModel.ambientVolume = Float(appSettings.ambientVolume)

                // Wire up streak tracking and collectibles when stories finish playing
                audioPlayerViewModel.onStoryFinished = { [weak readingStreakViewModel, weak collectiblesManager] storyID in
                    Task { @MainActor in
                        let isFirstCompletion = readingStreakViewModel.map {
                            !$0.streak.storiesReadDates.keys.contains(storyID)
                        } ?? false

                        readingStreakViewModel?.recordStoryRead(storyID: storyID)

                        // Award collectible for this story if not already collected
                        if let manager = collectiblesManager,
                           let collectible = manager.collectibleForStory(storyID) {
                            manager.collect(collectible)
                        }

                        // First-ever completion → let the detail view celebrate
                        if isFirstCompletion {
                            collectiblesManager?.celebrationStoryID = storyID
                        }
                    }
                }
            }
            .onDisappear {
                // Clean up closure to prevent memory leaks
                audioPlayerViewModel.onStoryFinished = nil
            }
            .onChange(of: appSettings.activeChildName) {
                applyActiveProfile()
            }
            .onReceive(NotificationCenter.default.publisher(for: .playTonightsStory)) { _ in
                // Siri / Shortcuts: "Play tonight's story"
                if let story = libraryViewModel.tonightsStory {
                    audioPlayerViewModel.loadAndPlay(story: story)
                }
            }
            .onReceive(NotificationCenter.default.publisher(
                for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)) { _ in
                // Another device pushed progress — merge and refresh
                CloudSync.syncDown()
                reloadStores()
            }
        }
    }

    private func reloadStores() {
        favoritesViewModel.reload()
        readingStreakViewModel.reload()
        collectiblesManager.reload()
    }

    /// Points the per-child stores (favorites, streak, collectibles) at the
    /// active child's data. Empty name → legacy unscoped keys.
    private func applyActiveProfile() {
        let name = appSettings.activeChildName
        favoritesViewModel.setProfile(name)
        readingStreakViewModel.setProfile(name)
        collectiblesManager.setProfile(name)
    }

    /// Pre-profile versions stored favorites/streak/collectibles under global
    /// keys. Copy that data to the FIRST child's scoped keys exactly once, so
    /// an existing family keeps their progress after updating.
    private func migrateLegacyDataToFirstProfileIfNeeded() {
        let defaults = UserDefaults.standard
        let migrationFlag = "profileDataMigrated_v1"
        guard !defaults.bool(forKey: migrationFlag) else { return }
        defer { defaults.set(true, forKey: migrationFlag) }

        guard let firstChild = appSettings.childrenNames.first, !firstChild.isEmpty else { return }

        for base in ["favoriteStoryIDs", "readingStreak", "CollectiblesManager.collectedIDs"] {
            let scoped = ProfileScope.key(base, profile: firstChild)
            guard defaults.object(forKey: scoped) == nil,
                  let legacy = defaults.object(forKey: base) else { continue }
            defaults.set(legacy, forKey: scoped)
        }
    }
}
