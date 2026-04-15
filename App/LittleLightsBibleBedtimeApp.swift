
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
                // Sync saved volume settings with audio player
                audioPlayerViewModel.narrationVolume = Float(appSettings.narrationVolume)
                audioPlayerViewModel.ambientVolume = Float(appSettings.ambientVolume)

                // Wire up streak tracking and collectibles when stories finish playing
                audioPlayerViewModel.onStoryFinished = { [weak readingStreakViewModel, weak collectiblesManager] storyID in
                    Task { @MainActor in
                        readingStreakViewModel?.recordStoryRead(storyID: storyID)

                        // Award collectible for this story if not already collected
                        if let manager = collectiblesManager,
                           let collectible = manager.collectibleForStory(storyID) {
                            manager.collect(collectible)
                        }
                    }
                }
            }
            .onDisappear {
                // Clean up closure to prevent memory leaks
                audioPlayerViewModel.onStoryFinished = nil
            }
        }
    }
}
