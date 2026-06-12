
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
    @StateObject private var goalsTracker = GoalsTracker()
    @StateObject private var journeyProgress = JourneyProgressManager()

    @Environment(\.scenePhase) private var scenePhase

    // Bedtime reminder time (shared via UserDefaults with NotificationService).
    @AppStorage("bedtimeHour") private var bedtimeHour = 19
    @AppStorage("bedtimeMinute") private var bedtimeMinute = 30

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
            .environmentObject(goalsTracker)
            .environmentObject(journeyProgress)
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

                // Wind-Down also checks on cold launch — the scenePhase
                // onChange below only catches later background→foreground
                // transitions, not the initial activation.
                triggerWindDownIfNeeded()

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

                        // Completion rewards (all treasures / all badges / grand)
                        if let manager = collectiblesManager {
                            readingStreakViewModel?.refreshCompletionBadges(collectibleCount: manager.collectedCount)
                        }

                        // Shooting star! Rare surprise bonus (about 1 night in 7)
                        if Int.random(in: 0..<7) == 0 {
                            readingStreakViewModel?.awardBonusStar()
                            collectiblesManager?.shootingStarTonight = true
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
            .onChange(of: scenePhase) { _, newPhase in
                // Wind-Down auto mode: when the app comes to the foreground
                // at/after the set bedtime, gently dim into bedtime mode and
                // stage Tonight's Story. Stage only — never auto-play.
                if newPhase == .active {
                    triggerWindDownIfNeeded()
                }
            }
        }
    }

    /// Flips into bedtime mode and stages Tonight's Story once per night if the
    /// app is opened at/after the family's set bedtime. iOS cannot wake a
    /// suspended app at a clock time, so this runs on the next foreground.
    private func triggerWindDownIfNeeded() {
        guard appSettings.windDownAutoEnabled else { return }
        guard WindDownService.shouldTrigger(
            now: Date(),
            lastFiredDayStamp: appSettings.windDownLastFired,
            hour: bedtimeHour,
            minute: bedtimeMinute
        ) else {
            // A new day before bedtime — clear last night's staged story so
            // the wind-down banner doesn't linger into the morning.
            if WindDownService.dayStamp() != appSettings.windDownLastFired {
                libraryViewModel.pendingTonightsStory = nil
            }
            return
        }

        // Stamp first so we fire at most once tonight, even if a story is nil.
        appSettings.windDownLastFired = WindDownService.dayStamp()
        appSettings.isBedtimeMode = true
        // Stage Tonight's Story for one-tap start — never auto-play (COPPA).
        libraryViewModel.pendingTonightsStory = libraryViewModel.tonightsStory
    }

    private func reloadStores() {
        favoritesViewModel.reload()
        readingStreakViewModel.reload()
        collectiblesManager.reload()
        journeyProgress.reload()
    }

    /// Points the per-child stores (favorites, streak, collectibles) at the
    /// active child's data. Empty name → legacy unscoped keys.
    private func applyActiveProfile() {
        let name = appSettings.activeChildName
        favoritesViewModel.setProfile(name)
        readingStreakViewModel.setProfile(name)
        collectiblesManager.setProfile(name)
        journeyProgress.setProfile(name)
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
