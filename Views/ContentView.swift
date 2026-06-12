
import SwiftUI
import Combine
import StoreKit

struct ContentView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var readingStreak: ReadingStreakViewModel
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @Environment(\.requestReview) private var requestReview

    private var dynamicTypeSize: DynamicTypeSize {
        switch appSettings.fontSize {
        case ..<15: return .xSmall
        case 15..<16: return .small
        case 16..<17: return .medium
        case 17..<19: return .large        // System default
        case 19..<21: return .xLarge
        case 21..<23: return .xxLarge
        case 23..<25: return .xxxLarge
        case 25..<27: return .accessibility1
        default: return .accessibility2
        }
    }

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "moon.stars.fill") }

            NavigationStack { LibraryView() }
                .tabItem { Label("Library", systemImage: "books.vertical.fill") }

            // Favorites moved to the side menu — iOS only shows five tabs
            // before hiding extras behind "More", and Games earns the slot
            NavigationStack { GamesView() }
                .tabItem { Label("Games", systemImage: "gamecontroller.fill") }

            NavigationStack { RewardsView() }
                .tabItem { Label("Rewards", systemImage: "star.fill") }

            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .dynamicTypeSize(dynamicTypeSize)
        .tint(AppTheme.accent(for: appSettings.isBedtimeMode))
        .preferredColorScheme(appSettings.isBedtimeMode ? .dark : nil)
        .onChange(of: readingStreak.totalStoriesRead) { _, newCount in
            maybeAskForReview(totalRead: newCount)
        }
        .safeAreaInset(edge: .bottom) {
            SleepTimerBannerContainer()
                .environmentObject(audioPlayer)
                .environmentObject(appSettings)
        }
        .overlay {
            if let level = readingStreak.leveledUpTo {
                LevelUpCelebrationView(level: level) {
                    readingStreak.leveledUpTo = nil
                }
                .transition(.opacity)
            } else if readingStreak.showNewBadgeAlert,
               let badgeID = readingStreak.newBadgeID,
               let badgeInfo = ReadingStreak.badgeInfo[badgeID] {
                BadgeCelebrationView(
                    badgeID: badgeID,
                    badgeName: badgeInfo.name,
                    badgeDescription: badgeInfo.description,
                    onDone: {
                        readingStreak.showNewBadgeAlert = false
                        readingStreak.newBadgeID = nil
                    }
                )
                .transition(.opacity)
            }
        }
    }

    /// Asks for an App Store review at happy milestones (5th, 20th and 60th
    /// finished story), once per milestone, after a short delay so it never
    /// lands on top of the completion celebration. Apple throttles actual
    /// presentation to at most 3 prompts per year — this only nominates
    /// good moments.
    private func maybeAskForReview(totalRead: Int) {
        let milestones: Set<Int> = [5, 20, 60]
        guard milestones.contains(totalRead) else { return }
        let key = "lastReviewMilestone"
        guard UserDefaults.standard.integer(forKey: key) < totalRead else { return }
        UserDefaults.standard.set(totalRead, forKey: key)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 6_000_000_000)
            requestReview()
        }
    }
}


// MARK: - Sleep Timer Banner Container

struct SleepTimerBannerContainer: View {
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        // Directly observe the timer so updates are instant
        Group {
            if audioPlayer.sleepTimer.isActive {
                SleepTimerBanner()
                    .environmentObject(audioPlayer)
                    .environmentObject(appSettings)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: audioPlayer.sleepTimer.isActive)
    }
}

// MARK: - Sleep Timer Banner

struct SleepTimerBanner: View {
    @EnvironmentObject private var audioPlayer: AudioPlayerViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @ObservedObject private var timer: SleepTimerObserver = SleepTimerObserver()

    var body: some View {
        HStack(spacing: 12) {
            // Moon icon
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 16))
                .foregroundStyle(.white)

            // Countdown text — large and readable
            VStack(alignment: .leading, spacing: 2) {
                Text("Sleep in")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.75))
                Text(audioPlayer.sleepTimer.remainingText)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.linear(duration: 0.5), value: audioPlayer.sleepTimer.remainingSeconds)
            }

            Spacer()

            // Progress bar
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(audioPlayer.sleepTimer.remainingSeconds / 60)m \(audioPlayer.sleepTimer.remainingSeconds % 60)s left")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.7))
                    .monospacedDigit()

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.25))
                            .frame(height: 6)
                        Capsule()
                            .fill(.white)
                            .frame(width: max(0, geo.size.width * (1.0 - audioPlayer.sleepTimer.progress)), height: 6)
                            .animation(.linear(duration: 1), value: audioPlayer.sleepTimer.progress)
                    }
                }
                .frame(width: 80, height: 6)
            }

            // Cancel button
            Button {
                audioPlayer.stopSleepTimer()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.indigo, Color.purple.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

// Forces view to refresh every second
class SleepTimerObserver: ObservableObject {
    private var cancellable: AnyCancellable?
    init() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.objectWillChange.send() }
    }
}
